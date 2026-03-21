import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

/// Paints a perfect circular dot grid — life-calendar style.
/// Past = bright, future = dim, today = accent color.
class DotGridPainter extends CustomPainter {
  final WallpaperSettings settings;
  final int dayOfYear;
  final int totalDays;

  DotGridPainter({
    required this.settings,
    required this.dayOfYear,
    required this.totalDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cols = settings.columns;
    final r = settings.dotRadius;
    final gap = settings.dotSpacing;
    final cell = r * 2 + gap; // full cell size

    final rows = (totalDays / cols).ceil();

    // Center the grid
    final gridW = cols * cell - gap;
    final gridH = rows * cell - gap;
    final ox = (size.width - gridW) / 2;
    final oy = (size.height - gridH) / 2;

    final pastPaint = Paint()
      ..color = settings.pastDotColor
      ..isAntiAlias = true;

    final futurePaint = Paint()
      ..color = settings.futureDotColor
      ..isAntiAlias = true;

    final todayPaint = Paint()
      ..color = settings.todayDotColor
      ..isAntiAlias = true;

    for (int i = 0; i < totalDays; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final cx = ox + col * cell + r;
      final cy = oy + row * cell + r;

      final isToday = i + 1 == dayOfYear;
      final isPast  = i + 1 < dayOfYear;

      if (isToday) {
        canvas.drawCircle(Offset(cx, cy), r, todayPaint);
      } else if (isPast) {
        canvas.drawCircle(Offset(cx, cy), r, pastPaint);
      } else {
        canvas.drawCircle(Offset(cx, cy), r, futurePaint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) =>
      old.settings != settings ||
      old.dayOfYear != dayOfYear ||
      old.totalDays != totalDays;
}

/// Full-screen wallpaper widget — pure black with dot grid.
class DotGridWallpaper extends StatelessWidget {
  final WallpaperSettings settings;
  final double? forceWidth;
  final double? forceHeight;

  const DotGridWallpaper({
    super.key,
    required this.settings,
    this.forceWidth,
    this.forceHeight,
  });

  @override
  Widget build(BuildContext context) {
    final dayOfYear = WallpaperSettings.dayOfYear;
    final totalDays = WallpaperSettings.daysInYear;
    final progress   = WallpaperSettings.yearProgress;
    final daysLeft   = totalDays - dayOfYear;

    return Container(
      width: forceWidth,
      height: forceHeight,
      color: settings.backgroundColor,
      child: Stack(
        children: [
          // Full-screen dot grid
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(
                settings: settings,
                dayOfYear: dayOfYear,
                totalDays: totalDays,
              ),
            ),
          ),

          // Bottom label — "0 left · 100%"
          if (settings.showProgressLabel)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    '$daysLeft left  ·  ${(progress * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: settings.pastDotColor.withOpacity(0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
