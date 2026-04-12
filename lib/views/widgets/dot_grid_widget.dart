import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

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

    final int effectiveCols;
    if (settings.mode == CalendarMode.life && total > 1000) {
      final ideal = Math.sqrt(total * size.width / size.height).truncate();
      effectiveCols = ideal.clamp(30, 150);
    } else {
      effectiveCols = cols;
    }

    double r = availW / (effectiveCols * 2.5 - 0.5);

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

    final ox = (size.width  - gridW) / 2;
    final oy = (size.height - gridH) / 2;

    // ── FIX: ARRAY BOUNDS SAFETY ──
    final safePast = past.clamp(0, total);
    final safeFutureCount = (total - safePast - 1).clamp(0, total);

    final pastPts = Float32List(safePast * 2);
    final todayPts = Float32List(2);
    final futurePts = Float32List(safeFutureCount * 2);

    int pIdx = 0, fIdx = 0;
    bool drewToday = false;

    for (int i = 0; i < total; i++) {
      final col = i % effectiveCols;
      final row = i ~/ effectiveCols;
      final cx  = ox + col * cell + r;
      final cy  = oy + row * cell + r;

      if (i < safePast) {
        pastPts[pIdx++] = cx;
        pastPts[pIdx++] = cy;
      } else if (i == safePast) {
        todayPts[0] = cx;
        todayPts[1] = cy;
        drewToday = true; // Marks if we actually hit the "today" dot
      } else {
        futurePts[fIdx++] = cx;
        futurePts[fIdx++] = cy;
      }
    }

    final strokeWidth = r * 2;
    final paintPast = Paint()
      ..color = settings.pastDotColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
      
    final paintToday = Paint()
      ..color = settings.todayDotColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final paintFuture = Paint()
      ..color = settings.futureDotColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    if (pastPts.isNotEmpty) {
      canvas.drawRawPoints(PointMode.points, pastPts, paintPast);
    }
    if (drewToday) {
      canvas.drawRawPoints(PointMode.points, todayPts, paintToday);
    }
    if (futurePts.isNotEmpty) {
      canvas.drawRawPoints(PointMode.points, futurePts, paintFuture);
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) => old.settings != settings;
}