import 'package:flutter/material.dart';

enum CalendarMode { year, goal, life, settings }
enum WallpaperTarget { lockscreen, homescreen, both }

class WallpaperSettings {
  Color backgroundColor;
  Color pastDotColor;
  Color futureDotColor;
  Color todayDotColor;
  Color textColor;        // label / quote text colour
  double labelFontSize;   // 0 = auto; >0 = explicit sp size (8–32)
  int columns;
  bool showProgressLabel;
  bool isDark;
  WallpaperTarget target;
  CalendarMode mode;

  // Goal calendar
  String goalName;
  DateTime? goalDate;

  // Life calendar (days-based)
  int lifeExpectancyYears;
  DateTime? birthDate;

  WallpaperSettings({
    this.backgroundColor   = const Color(0xFF000000),
    this.pastDotColor      = const Color(0xFFFFFFFF),
    this.futureDotColor    = const Color(0xFF2A2A2A),
    this.todayDotColor     = const Color(0xFFFF4500),
    this.textColor         = const Color(0xFFFFFFFF),
    this.labelFontSize     = 0,          // 0 = auto
    this.columns           = 20,
    this.showProgressLabel = true,
    this.isDark            = true,
    this.target            = WallpaperTarget.lockscreen,
    this.mode              = CalendarMode.year,
    this.goalName          = 'My Goal',
    this.goalDate,
    this.lifeExpectancyYears = 80,
    this.birthDate,
  });

  WallpaperSettings copyWith({
    Color? backgroundColor, Color? pastDotColor, Color? futureDotColor,
    Color? todayDotColor, Color? textColor, double? labelFontSize,
    int? columns, bool? showProgressLabel, bool? isDark,
    WallpaperTarget? target, CalendarMode? mode,
    String? goalName, DateTime? goalDate,
    int? lifeExpectancyYears, DateTime? birthDate,
  }) => WallpaperSettings(
    backgroundColor:     backgroundColor     ?? this.backgroundColor,
    pastDotColor:        pastDotColor        ?? this.pastDotColor,
    futureDotColor:      futureDotColor      ?? this.futureDotColor,
    todayDotColor:       todayDotColor       ?? this.todayDotColor,
    textColor:           textColor           ?? this.textColor,
    labelFontSize:       labelFontSize       ?? this.labelFontSize,
    columns:             columns             ?? this.columns,
    showProgressLabel:   showProgressLabel   ?? this.showProgressLabel,
    isDark:              isDark              ?? this.isDark,
    target:              target              ?? this.target,
    mode:                mode                ?? this.mode,
    goalName:            goalName            ?? this.goalName,
    goalDate:            goalDate            ?? this.goalDate,
    lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
    birthDate:           birthDate           ?? this.birthDate,
  );

  // ── Year helpers ──────────────────────────────────────────────
  static int get dayOfYear {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
  }

  static int get daysInYear {
    final y = DateTime.now().year;
    return ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 366 : 365;
  }

  static double get yearProgress => dayOfYear / daysInYear;

  // ── Goal helpers ──────────────────────────────────────────────
  int get goalTotalDays {
    if (goalDate == null) return 100;
    final now  = DateTime.now();
    final diff = goalDate!
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (diff <= 0) return 1;
    return diff + 1;
  }

  int get goalDaysLeft {
    if (goalDate == null) return 100;
    final now  = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final diff = goalDate!.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  // ── Life helpers (days) ───────────────────────────────────────
  int get lifeTotalDays => lifeExpectancyYears * 365;

  int get lifeDaysLived {
    if (birthDate == null) return 0;
    final days = DateTime.now().difference(birthDate!).inDays;
    return days.clamp(0, lifeTotalDays);
  }

  int get lifeDaysLeft =>
      (lifeTotalDays - lifeDaysLived).clamp(0, lifeTotalDays);

  double get lifeProgress =>
      lifeTotalDays > 0 ? lifeDaysLived / lifeTotalDays : 0;

  // ── Computed dot counts ───────────────────────────────────────
  int get totalDots {
    switch (mode) {
      case CalendarMode.year:     return daysInYear;
      case CalendarMode.goal:     return goalTotalDays.clamp(1, 3650);
      case CalendarMode.life:     return lifeTotalDays;
      case CalendarMode.settings: return daysInYear;
    }
  }

  int get pastDots {
    switch (mode) {
      case CalendarMode.year:     return dayOfYear - 1;
      case CalendarMode.goal:     return (totalDots - goalDaysLeft).clamp(0, totalDots);
      case CalendarMode.life:     return lifeDaysLived;
      case CalendarMode.settings: return dayOfYear - 1;
    }
  }

  String get progressLabel {
    switch (mode) {
      case CalendarMode.year:
        return '${daysInYear - dayOfYear} days left · '
            '${(yearProgress * 100).toStringAsFixed(0)}%';
      case CalendarMode.goal:
        return '$goalDaysLeft days left · $goalName';
      case CalendarMode.life:
        return '$lifeDaysLeft days left · '
            '${(lifeProgress * 100).toStringAsFixed(1)}%';
      case CalendarMode.settings:
        return '';
    }
  }
}

extension WallpaperTargetX on WallpaperTarget {
  String get label {
    switch (this) {
      case WallpaperTarget.lockscreen: return 'Lock Screen';
      case WallpaperTarget.homescreen: return 'Home Screen';
      case WallpaperTarget.both:       return 'Both';
    }
  }

  IconData get icon {
    switch (this) {
      case WallpaperTarget.lockscreen: return Icons.lock_rounded;
      case WallpaperTarget.homescreen: return Icons.home_rounded;
      case WallpaperTarget.both:       return Icons.layers_rounded;
    }
  }
}