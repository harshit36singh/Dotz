import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

class DotGridPainter extends CustomPainter {
  final WallpaperSettings settings;
  DotGridPainter(this.settings);

  @override
  void paint(Canvas canvas, Size size) {
    final total = settings.totalDots;
    final past  = settings.pastDots;
    final cols  = settings.columns;

    final availW = size.width  * 0.90;
    final availH = size.height * 0.88;

    // For life calendar in days (~29,200 dots): auto-pick columns
    // so dots are small & dense, filling the space like the reference image.
    // Formula: ideal cols = sqrt(total * screenW/screenH) → proportional grid
    final int effectiveCols;
    if (settings.mode == CalendarMode.life && total > 1000) {
      final ideal = Math.sqrt(total * size.width / size.height).truncate();
      effectiveCols = ideal.clamp(30, 150);
    } else {
      effectiveCols = cols;
    }

    // Solve r from width
    double r = availW / (effectiveCols * 2.5 - 0.5);

    // Also solve from height — take the smaller so grid fits both axes
    final rows0  = (total / effectiveCols).ceil();
    final gridH0 = rows0 * (r * 2.5) - r * 0.5;
    if (gridH0 > availH) {
      final rH = availH / (rows0 * 2.5 - 0.5);
      if (rH < r) r = rH;
    }
    r = r.clamp(1.5, 28.0);

    final gap  = r * 0.5;
    final cell = r * 2 + gap;
    final rows  = (total / effectiveCols).ceil();
    final gridW = effectiveCols * cell - gap;
    final gridH = rows * cell - gap;

    // Center on canvas
    final ox = (size.width  - gridW) / 2;
    final oy = (size.height - gridH) / 2;

    for (int i = 0; i < total; i++) {
      final col = i % effectiveCols;
      final row = i ~/ effectiveCols;
      final cx  = ox + col * cell + r;
      final cy  = oy + row * cell + r;

      final Color dotColor;
      if (i == past) {
        dotColor = settings.todayDotColor;
      } else if (i < past) {
        dotColor = settings.pastDotColor;
      } else {
        dotColor = settings.futureDotColor;
      }

      canvas.drawCircle(Offset(cx, cy), r,
          Paint()..color = dotColor..isAntiAlias = true);
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
    final daysLeft = settings.totalDots - settings.pastDots;
    final pct = settings.mode == CalendarMode.life
        ? settings.lifeProgress
        : settings.mode == CalendarMode.goal
            ? (settings.pastDots / settings.totalDots)
            : WallpaperSettings.yearProgress;

    return Container(
      color: settings.backgroundColor,
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(painter: DotGridPainter(settings)),
        ),
        if (settings.showProgressLabel)
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Text(
              settings.progressLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: settings.pastDotColor.withOpacity(0.45),
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ]),
    );
  }
}
