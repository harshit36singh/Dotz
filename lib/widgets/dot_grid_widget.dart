import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

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

    // Auto-size: fill 88% of width — SAME formula as Kotlin WallpaperService
    // gridWidth = r*(2.5*cols - 0.5)  →  r = availW / (2.5*cols - 0.5)
    final availW = size.width * 0.88;
    final r      = (availW / (cols * 2.5 - 0.5)).clamp(4.0, 32.0);
    final gap    = r * 0.5;
    final cell   = r * 2 + gap;

    final rows  = (totalDays / cols).ceil();
    final gridW = cols * cell - gap;
    final gridH = rows * cell - gap;

    // Center on canvas
    final ox = (size.width  - gridW) / 2;
    final oy = (size.height - gridH) / 2;

    for (int i = 0; i < totalDays; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final cx  = ox + col * cell + r;
      final cy  = oy + row * cell + r;

      final isToday = i + 1 == dayOfYear;
      final isPast  = i + 1 <  dayOfYear;

      if (isToday) {
        // Pulsing ring
        canvas.drawCircle(Offset(cx, cy), r * 1.6,
          Paint()
            ..color = settings.todayDotColor.withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.7
            ..isAntiAlias = true);
        // Solid dot
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
  bool shouldRepaint(DotGridPainter old) =>
      old.settings != settings ||
      old.dayOfYear != dayOfYear ||
      old.totalDays != totalDays;
}

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
    final daysLeft  = totalDays - dayOfYear;
    final progress  = WallpaperSettings.yearProgress;

    return Container(
      width: forceWidth,
      height: forceHeight,
      color: settings.backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DotGridPainter(
                settings: settings,
                dayOfYear: dayOfYear,
                totalDays: totalDays,
              ),
            ),
          ),
          if (settings.showProgressLabel)
            Positioned(
              bottom: 28, left: 0, right: 0,
              child: Text(
                '$daysLeft left  ·  ${(progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: settings.pastDotColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
