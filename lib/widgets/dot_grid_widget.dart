import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

class DotGridPainter extends CustomPainter {
  final WallpaperSettings settings;

  DotGridPainter(this.settings);

  @override
  void paint(Canvas canvas, Size size) {
    final cols      = settings.columns;
    final total     = settings.totalDots;
    final pastCount = settings.pastDots;

    final availW = size.width * 0.88;
    final r      = (availW / (cols * 2.5 - 0.5)).clamp(3.0, 28.0);
    final gap    = r * 0.5;
    final cell   = r * 2 + gap;

    final rows  = (total / cols).ceil();
    final gridW = cols * cell - gap;
    final gridH = rows * cell - gap;
    final ox = (size.width  - gridW) / 2;
    final oy = (size.height - gridH) / 2;

    for (int i = 0; i < total; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final cx  = ox + col * cell + r;
      final cy  = oy + row * cell + r;

      final isToday = i == pastCount;
      final isPast  = i < pastCount;

      if (isToday) {
        canvas.drawCircle(Offset(cx, cy), r * 1.55,
          Paint()
            ..color = settings.todayDotColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.65
            ..isAntiAlias = true);
        canvas.drawCircle(Offset(cx, cy), r,
          Paint()..color = settings.todayDotColor..isAntiAlias = true);
      } else if (isPast) {
        canvas.drawCircle(Offset(cx, cy), r,
          Paint()..color = settings.pastDotColor..isAntiAlias = true);
      } else {
        canvas.drawCircle(Offset(cx, cy), r,
          Paint()..color = settings.futureDotColor..isAntiAlias = true);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) => old.settings != settings;
}

class DotGridWallpaper extends StatelessWidget {
  final WallpaperSettings settings;
  const DotGridWallpaper({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: settings.backgroundColor,
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(painter: DotGridPainter(settings)),
        ),
        if (settings.showProgressLabel)
          Positioned(
            bottom: 24, left: 0, right: 0,
            child: Text(
              settings.progressLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settings.pastDotColor.withOpacity(0.5),
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
      ]),
    );
  }
}
