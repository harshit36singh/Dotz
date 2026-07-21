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

  // Date-numbers sizing: grow dots only as much as needed for a legible
  // 1-2 digit number, capped so a sparse setting doesn't balloon into
  // oversized dots — a small tight number in a modestly-sized dot, not a
  // big dot built around a big number.
  static const double _minRadiusForNumbers = 8.5;
  static const double _maxGrowthFactorForNumbers = 1.6;

  /// The calendar date dot index 0 corresponds to, for modes whose dots map
  /// to a real date. Null disables number rendering (Life mode, or numbers
  /// toggled off).
  DateTime? get _numberBaseDate {
    if (!settings.showDateNumbers || !settings.supportsDateNumbers) return null;
    switch (settings.mode) {
      case CalendarMode.year:
        return DateTime(DateTime.now().year, 1, 1);
      case CalendarMode.goal:
        return settings.effectiveGoalStart;
      default:
        return null;
    }
  }

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
    final markedPts = Float32List(366 * 2);

    int pIdx = 0, fIdx = 0, mIdx = 0;
    bool drewToday = false;

    final showNumbers = settings.showDateNumbers && settings.supportsDateNumbers;
    final pastDayNums = <int>[];
    final futureDayNums = <int>[];
    final markedDayNums = <int>[];
    int todayDayNum = 0;

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

        if (monthIndex == currentMonth && d == currentDay) {
          todayPts[0] = cx;
          todayPts[1] = cy;
          drewToday = true;
          todayDayNum = d;
        } else if (settings.markedDateFor(monthIndex, d) != null) {
          markedPts[mIdx++] = cx;
          markedPts[mIdx++] = cy;
          if (showNumbers) markedDayNums.add(d);
        } else if (monthIndex < currentMonth || (monthIndex == currentMonth && d < currentDay)) {
          pastPts[pIdx++] = cx;
          pastPts[pIdx++] = cy;
          if (showNumbers) pastDayNums.add(d);
        } else {
          futurePts[fIdx++] = cx;
          futurePts[fIdx++] = cy;
          if (showNumbers) futureDayNums.add(d);
        }
      }
    }

    _drawShapes(canvas, pastPts, pIdx, todayPts, drewToday, futurePts, fIdx, markedPts, mIdx, r);
    if (showNumbers) {
      _drawDayNumbers(
        canvas, r,
        pastPts, pastDayNums,
        todayPts, drewToday, todayDayNum,
        futurePts, futureDayNums,
        markedPts, markedDayNums,
      );
    }
  }

  void _drawStandardGrid(Canvas canvas, Size size) {
    int total = settings.totalDots;
    int past  = settings.pastDots;
    int cols  = settings.columns;

    const int maxPreviewDots = 1200;
    bool downsampled = false;
    if (total > maxPreviewDots) {
      final double ratio = maxPreviewDots / total;
      total = maxPreviewDots;
      past = (past * ratio).round();
      downsampled = true;
    }

    final availW = size.width  * 0.90 * settings.gridScale;
    final availH = size.height * 0.88 * settings.gridScale;

    int effectiveCols;
    if (settings.mode == CalendarMode.life || total > 1000) {
      final ideal = Math.sqrt(total * size.width / size.height).truncate();
      effectiveCols = ideal.clamp(15, 60);
    } else {
      effectiveCols = cols;
    }

    // Downsampling remaps dot index -> day nonlinearly, so numbers would be
    // wrong; only show them on an undownsampled (i.e. accurate) grid.
    final baseDate = downsampled ? null : _numberBaseDate;

    if (baseDate != null) {
      final naturalR = availW / (effectiveCols * 2.5 - 0.5);
      if (naturalR < _minRadiusForNumbers) {
        final target = Math.min(_minRadiusForNumbers, naturalR * _maxGrowthFactorForNumbers);
        final neededCols = ((availW / target + 0.5) / 2.5).floor();
        effectiveCols = neededCols.clamp(3, effectiveCols);
      }
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
    // Marked dates only correspond to real calendar dates in Year/Settings
    // mode (dot index == day-of-year); Goal/Life dots count "days since X",
    // not a calendar date, so marking never applies there.
    final canMark = settings.markedDates.isNotEmpty &&
        (settings.mode == CalendarMode.year || settings.mode == CalendarMode.settings) &&
        total == WallpaperSettings.daysInYear;
    final markedPts = Float32List(canMark ? total * 2 : 0);
    final yearStart = DateTime(DateTime.now().year, 1, 1);

    int pIdx = 0, fIdx = 0, mIdx = 0;
    bool drewToday = false;

    final pastDayNums = <int>[];
    final futureDayNums = <int>[];
    final markedDayNums = <int>[];
    int todayDayNum = 0;

    for (int i = 0; i < total; i++) {
      final col = i % effectiveCols;
      final row = i ~/ effectiveCols;
      final cx  = ox + col * cell + r;
      final cy  = oy + row * cell + r;

      final marked = canMark
          ? () {
              final date = yearStart.add(Duration(days: i));
              return settings.markedDateFor(date.month, date.day) != null;
            }()
          : false;
      final dayNum = baseDate != null ? baseDate.add(Duration(days: i)).day : 0;

      if (i == safePast) {
        todayPts[0] = cx;
        todayPts[1] = cy;
        drewToday = true;
        todayDayNum = dayNum;
      } else if (marked) {
        markedPts[mIdx++] = cx;
        markedPts[mIdx++] = cy;
        if (baseDate != null) markedDayNums.add(dayNum);
      } else if (i < safePast) {
        pastPts[pIdx++] = cx;
        pastPts[pIdx++] = cy;
        if (baseDate != null) pastDayNums.add(dayNum);
      } else {
        futurePts[fIdx++] = cx;
        futurePts[fIdx++] = cy;
        if (baseDate != null) futureDayNums.add(dayNum);
      }
    }

    _drawShapes(canvas, pastPts, pIdx, todayPts, drewToday, futurePts, fIdx, markedPts, mIdx, r);
    if (baseDate != null) {
      _drawDayNumbers(
        canvas, r,
        pastPts, pastDayNums,
        todayPts, drewToday, todayDayNum,
        futurePts, futureDayNums,
        markedPts, markedDayNums,
      );
    }
  }

  void _drawShapes(Canvas canvas, Float32List pastPts, int pIdx, Float32List todayPts, bool drewToday, Float32List futurePts, int fIdx, Float32List markedPts, int mIdx, double r) {
    final strokeWidth = r * 2;

    final paintPast = Paint()..color = settings.pastDotColor..isAntiAlias = true;
    final paintToday = Paint()..color = settings.todayDotColor..isAntiAlias = true;
    final paintFuture = Paint()..color = settings.futureDotColor..isAntiAlias = true;
    final paintMarked = Paint()..color = settings.milestoneColor..isAntiAlias = true;

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
    drawShape(canvas, markedPts, mIdx, paintMarked);
    if (drewToday) drawShape(canvas, todayPts, 2, paintToday);
    drawShape(canvas, futurePts, fIdx, paintFuture);
  }

  /// Draws the day-of-month number centered on each dot, in black or white
  /// depending on that dot's fill color so it stays readable either way.
  void _drawDayNumbers(
    Canvas canvas,
    double r,
    Float32List pastPts, List<int> pastDayNums,
    Float32List todayPts, bool drewToday, int todayDayNum,
    Float32List futurePts, List<int> futureDayNums,
    Float32List markedPts, List<int> markedDayNums,
  ) {
    final fontSize = (r * 0.95).clamp(6.0, 20.0);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawNumber(double cx, double cy, int day, Color bgColor) {
      final textColor = bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      textPainter.text = TextSpan(
        text: '$day',
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
          height: 1.0,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
    }

    for (int i = 0; i < pastDayNums.length; i++) {
      drawNumber(pastPts[i * 2], pastPts[i * 2 + 1], pastDayNums[i], settings.pastDotColor);
    }
    for (int i = 0; i < markedDayNums.length; i++) {
      drawNumber(markedPts[i * 2], markedPts[i * 2 + 1], markedDayNums[i], settings.milestoneColor);
    }
    if (drewToday) {
      drawNumber(todayPts[0], todayPts[1], todayDayNum, settings.todayDotColor);
    }
    for (int i = 0; i < futureDayNums.length; i++) {
      drawNumber(futurePts[i * 2], futurePts[i * 2 + 1], futureDayNums[i], settings.futureDotColor);
    }
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