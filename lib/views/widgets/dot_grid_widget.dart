import 'dart:math' as Math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

class DotGridPainter extends CustomPainter {
  final WallpaperSettings settings;
  
  DotGridPainter(this.settings, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    // If we are in the new 12-Month "Weekly/Monthly" mode, draw the calendar grid
    if (settings.mode == CalendarMode.weekly) {
      _drawMonthlyGrid(canvas, size);
    } else {
      // Otherwise, draw the standard continuous grid (Year, Goal, Life)
      _drawStandardGrid(canvas, size);
    }
  }

  // ── 12-Month Grid Logic (Matches your image) ──────────────────────
  void _drawMonthlyGrid(Canvas canvas, Size size) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;

    // Leave a little room at the bottom so it doesn't overlap the lockscreen icons
    final availW = size.width * 0.85;
    final availH = size.height * 0.75; 
    
    // 3 columns, 4 rows for the months
    final blockW = availW / 3;
    final blockH = availH / 4;

    // 7 days a week per month block
    final cell = (blockW * 0.80) / 7;
    final r = (cell * 0.8) / 2;

    // Center the whole 3x4 grid inside the canvas
    final startX = (size.width - availW) / 2 + (blockW * 0.05);
    final startY = (size.height - availH) / 2 + (size.height * 0.05);

    // Pre-allocate arrays for maximum performance
    final pastPts = Float32List(366 * 2);
    final todayPts = Float32List(2);
    final futurePts = Float32List(366 * 2);
    
    int pIdx = 0, fIdx = 0;
    bool drewToday = false;

    // Setup text painter for month labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int m = 0; m < 12; m++) {
      final monthIndex = m + 1;
      // Get the total days in this specific month
      final daysInMonth = DateTime(currentYear, monthIndex + 1, 0).day;
      
      // Calculate which day of the week the 1st falls on.
      // DateTime.weekday returns 1 (Mon) to 7 (Sun). 
      // We subtract 1 to get 0 (Mon) to 6 (Sun) to easily offset our grid.
      final firstDayOffset = DateTime(currentYear, monthIndex, 1).weekday - 1;

      // X and Y coordinates for the top-left of this specific month block
      final bx = startX + (m % 3) * blockW;
      final by = startY + (m ~/ 3) * blockH;

      // 1. Draw the Month Label
      textPainter.text = TextSpan(
        text: monthNames[m],
        style: TextStyle(
          color: settings.textColor.withOpacity(0.9),
          fontSize: r * 3.5,
          fontWeight: FontWeight.w600,
          fontFamily: 'Glass Antiqua', // Matches your theme
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(bx, by));

      // Push the dots down slightly below the text
      final gridStartY = by + textPainter.height + (r * 1.5);

      // 2. Draw the Dots for this month
      for (int d = 1; d <= daysInMonth; d++) {
        // Shift the dot position by the starting day of the week
        final pos = firstDayOffset + d - 1;
        final col = pos % 7;
        final row = pos ~/ 7;

        final cx = bx + col * cell + r;
        final cy = gridStartY + row * cell + r;

        // Categorize into Past, Today, or Future
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

  // ── Standard Continuous Grid Logic ─────────────────────────────────
  void _drawStandardGrid(Canvas canvas, Size size) {
    int total = settings.totalDots;
    int past  = settings.pastDots;
    int cols  = settings.columns;

    // PREVIEW OPTIMIZATION for Life mode to avoid microscopic dots
    const int maxPreviewDots = 1200; 
    if (total > maxPreviewDots) {
      final double ratio = maxPreviewDots / total;
      total = maxPreviewDots;
      past = (past * ratio).round();
    }

    final availW = size.width  * 0.90;
    final availH = size.height * 0.88;

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

    final ox = (size.width  - gridW) / 2;
    final oy = (size.height - gridH) / 2;

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

  // ── Shape Drawing Helper ─────────────────────────────────────────
  void _drawShapes(Canvas canvas, Float32List pastPts, int pIdx, Float32List todayPts, bool drewToday, Float32List futurePts, int fIdx, double r) {
    final strokeWidth = r * 2;
    
    final paintPast = Paint()..color = settings.pastDotColor..isAntiAlias = true;
    final paintToday = Paint()..color = settings.todayDotColor..isAntiAlias = true;
    final paintFuture = Paint()..color = settings.futureDotColor..isAntiAlias = true;

    void drawShape(Canvas c, Float32List pts, int count, Paint p) {
      if (count == 0) return;
      
      if (settings.shape == DotShape.circle || settings.shape == DotShape.square) {
        // Fast path for simple geometry
        p.strokeWidth = strokeWidth;
        p.strokeCap = settings.shape == DotShape.circle ? StrokeCap.round : StrokeCap.square;
        c.drawRawPoints(PointMode.points, Float32List.sublistView(pts, 0, count), p);
      } else if (settings.shape == DotShape.star) {
        // Draw Stars
        for (int i = 0; i < count; i += 2) {
          final cx = pts[i];
          final cy = pts[i + 1];
          final path = _createStarPath(cx, cy, r, r * 0.45, 5);
          c.drawPath(path, p);
        }
      } else if (settings.shape == DotShape.glass) {
        // Draw "Glass" Dots
        final glassInnerPaint = Paint()..color = p.color.withOpacity(0.5)..isAntiAlias = true;
        final glassBorderPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..isAntiAlias = true;

        for (int i = 0; i < count; i += 2) {
          final cx = pts[i];
          final cy = pts[i + 1];
          c.drawCircle(Offset(cx, cy), r, glassInnerPaint); 
          c.drawCircle(Offset(cx, cy), r, glassBorderPaint); 
        }
      }
    }

    drawShape(canvas, pastPts, pIdx, paintPast);
    if (drewToday) drawShape(canvas, todayPts, 2, paintToday);
    drawShape(canvas, futurePts, fIdx, paintFuture);
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