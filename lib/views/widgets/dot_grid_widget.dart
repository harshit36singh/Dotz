import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

// NOTE: This is a preview-only reimplementation of the grid layout math that
// actually runs on-device in
// android/app/src/main/kotlin/com/example/dotz/DotzLiveWallpaper.kt. The two
// are not derived from a shared source — if you change column count, dot
// radius/spacing, offset handling, or per-shape drawing here, mirror the
// change in the Kotlin engine too, or this preview will drift from the
// applied wallpaper.
class DotGridPainter extends CustomPainter {
  final WallpaperSettings settings;
  
  DotGridPainter(this.settings, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (settings.mode == CalendarMode.weekly) {
      _drawMonthlyGrid(canvas, size);
    } else {
      _drawStandardGrid(canvas, size);
    }
  }

  void _drawMonthlyGrid(Canvas canvas, Size size) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;

    final availW = size.width * 0.85 * settings.gridScale;
    final availH = size.height * 0.75 * settings.gridScale; 
    
    final blockW = availW / 3;
    final blockH = availH / 4;

    final cell = (blockW * 0.80) / 7;
    final r = (cell * 0.8) / 2;

    // ── CALC THE OFFSETS ──
    final shiftX = settings.offsetX * size.width;
    final shiftY = settings.offsetY * size.height;

    // ── APPLY OFFSET TO THE STARTING POINT ──
    final startX = (size.width - availW) / 2 + (blockW * 0.05) + shiftX;
    final startY = (size.height - availH) / 2 + (size.height * 0.05) + shiftY;

    final pastPts = Float32List(366 * 2);
    final todayPts = Float32List(2);
    final futurePts = Float32List(366 * 2);
    
    int pIdx = 0, fIdx = 0;
    bool drewToday = false;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int m = 0; m < 12; m++) {
      final monthIndex = m + 1;
      final daysInMonth = DateTime(currentYear, monthIndex + 1, 0).day;
      final firstDayOffset = DateTime(currentYear, monthIndex, 1).weekday - 1;

      final bx = startX + (m % 3) * blockW;
      final by = startY + (m ~/ 3) * blockH;

      textPainter.text = TextSpan(
        text: monthNames[m],
        style: TextStyle(
          color: settings.textColor.withOpacity(0.9),
          fontSize: r * 3.5, 
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat', 
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(bx, by));

      final gridStartY = by + textPainter.height + (r * 1.5);

      for (int d = 1; d <= daysInMonth; d++) {
        final pos = firstDayOffset + d - 1;
        final col = pos % 7;
        final row = pos ~/ 7;

        final cx = bx + col * cell + r;
        final cy = gridStartY + row * cell + r;

        if (monthIndex < currentMonth || (monthIndex == currentMonth && d < currentDay)) {
          pastPts[pIdx++] = cx;
          pastPts[pIdx++] = cy;
        } else if (monthIndex == currentMonth && d == currentDay) {
          todayPts[0] = cx;
          todayPts[1] = cy;
          drewToday = true;
        } else {
          futurePts[fIdx++] = cx;
          futurePts[fIdx++] = cy;
        }
      }
    }

    _drawShapes(canvas, pastPts, pIdx, todayPts, drewToday, futurePts, fIdx, r);
  }

  void _drawStandardGrid(Canvas canvas, Size size) {
    int total = settings.totalDots;
    int past  = settings.pastDots;
    int cols  = settings.columns;

    const int maxPreviewDots = 1200; 
    if (total > maxPreviewDots) {
      final double ratio = maxPreviewDots / total;
      total = maxPreviewDots;
      past = (past * ratio).round();
    }

    final availW = size.width  * 0.90 * settings.gridScale;
    final availH = size.height * 0.88 * settings.gridScale;

    final int effectiveCols;
    if (settings.mode == CalendarMode.life || total > 1000) {
      final ideal = Math.sqrt(total * size.width / size.height).truncate();
      effectiveCols = ideal.clamp(15, 60); 
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

    // ── CALC THE OFFSETS ──
    final shiftX = settings.offsetX * size.width;
    final shiftY = settings.offsetY * size.height;

    // ── APPLY OFFSET TO THE STARTING POINT ──
    final ox = (size.width  - gridW) / 2 + shiftX;
    final oy = (size.height - gridH) / 2 + shiftY;

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
        drewToday = true;
      } else {
        futurePts[fIdx++] = cx;
        futurePts[fIdx++] = cy;
      }
    }

    _drawShapes(canvas, pastPts, pIdx, todayPts, drewToday, futurePts, fIdx, r);
  }

  void _drawShapes(Canvas canvas, Float32List pastPts, int pIdx, Float32List todayPts, bool drewToday, Float32List futurePts, int fIdx, double r) {
    final strokeWidth = r * 2;
    
    final paintPast = Paint()..color = settings.pastDotColor..isAntiAlias = true;
    final paintToday = Paint()..color = settings.todayDotColor..isAntiAlias = true;
    final paintFuture = Paint()..color = settings.futureDotColor..isAntiAlias = true;

    void drawShape(Canvas c, Float32List pts, int count, Paint p) {
      if (count == 0) return;
      
      if (settings.shape == DotShape.circle) {
        p.strokeWidth = strokeWidth;
        p.strokeCap = StrokeCap.round;
        c.drawRawPoints(PointMode.points, Float32List.sublistView(pts, 0, count), p);
      } 
      else if (settings.shape == DotShape.square) {
        final radius = Radius.circular(r * 0.4); 
        for (int i = 0; i < count; i += 2) {
          final rect = Rect.fromCircle(center: Offset(pts[i], pts[i + 1]), radius: r);
          c.drawRRect(RRect.fromRectAndRadius(rect, radius), p);
        }
      } 
      else if (settings.shape == DotShape.star) {
        for (int i = 0; i < count; i += 2) {
          final cx = pts[i];
          final cy = pts[i + 1];
          final path = _createStarPath(cx, cy, r, r * 0.45, 5);
          c.drawPath(path, p);
        }
      } 
      else if (settings.shape == DotShape.glass) {
        final glassInnerPaint = Paint()..color = p.color.withOpacity(0.5)..isAntiAlias = true;
        final glassBorderPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..isAntiAlias = true;

        for (int i = 0; i < count; i += 2) {
          final cx = pts[i];
          final cy = pts[i + 1];
          c.drawCircle(Offset(cx, cy), r, glassInnerPaint);
          c.drawCircle(Offset(cx, cy), r, glassBorderPaint);
        }
      }
      else if (settings.shape == DotShape.hexagon) {
        for (int i = 0; i < count; i += 2) {
          final path = _createPolygonPath(pts[i], pts[i + 1], r, 6);
          c.drawPath(path, p);
        }
      }
      else if (settings.shape == DotShape.diamond) {
        for (int i = 0; i < count; i += 2) {
          final path = _createPolygonPath(pts[i], pts[i + 1], r, 4);
          c.drawPath(path, p);
        }
      }
    }

    drawShape(canvas, pastPts, pIdx, paintPast);
    if (drewToday) drawShape(canvas, todayPts, 2, paintToday);
    drawShape(canvas, futurePts, fIdx, paintFuture);
  }

  /// Regular polygon (e.g. sides=6 -> hexagon, sides=4 -> diamond) inscribed
  /// in radius [r], point-up.
  Path _createPolygonPath(double cx, double cy, double r, int sides) {
    final path = Path();
    final step = 2 * Math.pi / sides;
    double angle = -Math.pi / 2;

    for (int i = 0; i < sides; i++) {
      final dx = cx + Math.cos(angle) * r;
      final dy = cy + Math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  Path _createStarPath(double cx, double cy, double outerRadius, double innerRadius, int numPoints) {
    final path = Path();
    final step = Math.pi / numPoints;
    double angle = -Math.pi / 2; 

    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final dx = cx + Math.cos(angle) * radius;
      final dy = cy + Math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(DotGridPainter old) => true; 
}