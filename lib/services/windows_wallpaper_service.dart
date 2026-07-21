import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/wallpaper_settings.dart';
import '../views/widgets/dot_grid_widget.dart';

/// Windows has no equivalent of Android's live wallpaper service — desktop
/// wallpaper is always a static image. This renders the current grid to a
/// PNG at the primary monitor's resolution and sets it via the Win32
/// SystemParametersInfoW API. There's no background auto-refresh: calling
/// [apply] is the only way the wallpaper updates, mirroring the "Apply"
/// button's Android behavior as closely as the platform allows.
class WindowsWallpaperService {
  static const int _spiSetDeskWallpaper = 0x0014;
  static const int _spifUpdateIniFile = 0x01;
  static const int _spifSendChange = 0x02;
  static const int _smCxScreen = 0;
  static const int _smCyScreen = 1;

  /// Renders [settings] (plus the current background image/color) to a PNG
  /// sized for the primary monitor, saves it, and sets it as the desktop
  /// wallpaper. Returns false on any failure.
  static Future<bool> apply({
    required WallpaperSettings settings,
    required String bgImagePath,
    required Color bgColor,
  }) async {
    if (!Platform.isWindows) return false;
    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final getSystemMetrics = user32
          .lookupFunction<Int32 Function(Int32), int Function(int)>('GetSystemMetrics');

      final screenW = getSystemMetrics(_smCxScreen);
      final screenH = getSystemMetrics(_smCyScreen);
      if (screenW <= 0 || screenH <= 0) return false;

      final pngBytes = await _renderPng(settings, bgImagePath, bgColor, screenW, screenH);

      final dir = await getApplicationDocumentsDirectory();
      // Fixed filename — same reasoning as the picked background image: only
      // one wallpaper is ever active, and SystemParametersInfoW needs a
      // stable absolute path.
      final file = File(p.join(dir.path, 'dotz_wallpaper.png'));
      await file.writeAsBytes(pngBytes, flush: true);

      final systemParametersInfo = user32.lookupFunction<
          Int32 Function(Uint32, Uint32, Pointer<Utf16>, Uint32),
          int Function(int, int, Pointer<Utf16>, int)>('SystemParametersInfoW');

      final pathPtr = file.path.toNativeUtf16();
      try {
        final result = systemParametersInfo(
          _spiSetDeskWallpaper,
          0,
          pathPtr,
          _spifUpdateIniFile | _spifSendChange,
        );
        return result != 0;
      } finally {
        calloc.free(pathPtr);
      }
    } catch (e) {
      debugPrint('WindowsWallpaperService.apply failed: $e');
      return false;
    }
  }

  static Future<Uint8List> _renderPng(
    WallpaperSettings settings,
    String bgImagePath,
    Color bgColor,
    int w,
    int h,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(w.toDouble(), h.toDouble());
    final rect = Offset.zero & size;

    // ── Background ── mirrors DotzLiveWallpaper.kt's buildCache exactly:
    // cover-fit image + a 120/255 black scrim, or a flat color otherwise.
    var drewImage = false;
    if (bgImagePath.isNotEmpty && await File(bgImagePath).exists()) {
      try {
        final bytes = await File(bgImagePath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes, targetWidth: w, targetHeight: h);
        final frame = await codec.getNextFrame();
        final img = frame.image;

        final scale = math.max(w / img.width, h / img.height);
        final dx = (w - img.width * scale) / 2;
        final dy = (h - img.height * scale) / 2;

        canvas.save();
        canvas.translate(dx, dy);
        canvas.scale(scale, scale);
        canvas.drawImage(img, Offset.zero, Paint());
        canvas.restore();

        canvas.drawRect(rect, Paint()..color = const Color.fromARGB(120, 0, 0, 0));
        drewImage = true;
      } catch (_) {
        drewImage = false;
      }
    }
    if (!drewImage) {
      canvas.drawRect(rect, Paint()..color = bgColor);
    }

    DotGridPainter(settings).paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
