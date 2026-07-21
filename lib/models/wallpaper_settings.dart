import 'package:flutter/material.dart';

enum CalendarMode { year, goal, life, weekly, settings }

enum DotShape { circle, square, star, glass, hexagon, diamond }

enum LifeUnit { days, weeks }

/// A recurring annual marker (birthday, anniversary, holiday...) — matched
/// by month+day only, no year, so it lights up every time that date comes
/// around. Only meaningful in Year and Weekly/Monthly mode, since those are
/// the only modes whose dots correspond to real calendar dates (Goal/Life
/// dots represent "days since X", not a specific date on the calendar).
class MarkedDate {
  final int month; // 1-12
  final int day;   // 1-31
  final String label;

  const MarkedDate({required this.month, required this.day, required this.label});

  bool matches(int month, int day) => this.month == month && this.day == day;

  Map<String, dynamic> toJson() => {'month': month, 'day': day, 'label': label};

  factory MarkedDate.fromJson(Map<String, dynamic> json) => MarkedDate(
        month: json['month'] as int,
        day: json['day'] as int,
        label: json['label'] as String? ?? '',
      );
}

class WallpaperSettings {
  Color backgroundColor;
  Color pastDotColor;
  Color futureDotColor;
  Color todayDotColor;
  Color textColor; // label / quote text colour
  double labelFontSize; // 0 = auto; >0 = explicit sp size (8–32)
  int columns;
  bool showProgressLabel;
  bool isDark;
  CalendarMode mode;

  // Goal calendar
  String goalName;
  DateTime? goalDate;
  DateTime? goalStartDate; // null = count from today

  // Life calendar
  int lifeExpectancyYears;
  DateTime? birthDate;
  LifeUnit lifeUnit;
  double offsetX = 0.0;
  double offsetY = 0.0;
  // ── Background Image ──
  String bgImagePath;
  DotShape shape;
  double gridScale;
  // ── Marked Dates (Year / Weekly mode only) ──
  List<MarkedDate> markedDates;
  Color milestoneColor;
  // ── Date Numbers (Year / Weekly / Goal mode only, not Life) ──
  bool showDateNumbers;

  WallpaperSettings({
    this.offsetX = 0.0,
    this.offsetY=0.0,
    this.backgroundColor = const Color(0xFF000000),
    this.pastDotColor = const Color(0xFFFFFFFF),
    this.futureDotColor = const Color(0xFF2A2A2A),
    this.todayDotColor = const Color(0xFFFF4500),
    this.textColor = const Color(0xFFFFFFFF),
    this.labelFontSize = 0, // 0 = auto
    this.columns = 20,
    this.showProgressLabel = true,
    this.isDark = true,
    this.mode = CalendarMode.year,
    this.goalName = 'Goal',
    this.goalDate,
    this.goalStartDate,
    this.lifeExpectancyYears = 80,
    this.birthDate,
    this.lifeUnit = LifeUnit.days,
    this.bgImagePath = '',
    this.shape = DotShape.circle,
    this.gridScale = 1.0,
    this.markedDates = const [],
    this.milestoneColor = const Color(0xFFFFD700),
    this.showDateNumbers = false,
  });

  WallpaperSettings copyWith({
    Color? backgroundColor,
    Color? pastDotColor,
    Color? futureDotColor,
    Color? todayDotColor,
    Color? textColor,
    double? labelFontSize,
    int? columns,
    bool? showProgressLabel,
    bool? isDark,
    CalendarMode? mode,
    String? goalName,
    DateTime? goalDate,
    DateTime? goalStartDate,
    int? lifeExpectancyYears,
    DateTime? birthDate,
    LifeUnit? lifeUnit,
    String? bgImagePath,
    DotShape? shape,
    double? gridScale,
    List<MarkedDate>? markedDates,
    Color? milestoneColor,
    bool? showDateNumbers,
  }) => WallpaperSettings(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    pastDotColor: pastDotColor ?? this.pastDotColor,
    futureDotColor: futureDotColor ?? this.futureDotColor,
    todayDotColor: todayDotColor ?? this.todayDotColor,
    textColor: textColor ?? this.textColor,
    labelFontSize: labelFontSize ?? this.labelFontSize,
    columns: columns ?? this.columns,
    showProgressLabel: showProgressLabel ?? this.showProgressLabel,
    isDark: isDark ?? this.isDark,
    mode: mode ?? this.mode,
    goalName: goalName ?? this.goalName,
    goalDate: goalDate ?? this.goalDate,
    goalStartDate: goalStartDate ?? this.goalStartDate,
    lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
    birthDate: birthDate ?? this.birthDate,
    lifeUnit: lifeUnit ?? this.lifeUnit,
    bgImagePath: bgImagePath ?? this.bgImagePath,
    shape: shape ?? this.shape,
    gridScale: gridScale ?? this.gridScale,
    markedDates: markedDates ?? this.markedDates,
    milestoneColor: milestoneColor ?? this.milestoneColor,
    showDateNumbers: showDateNumbers ?? this.showDateNumbers,
  );

  /// True for modes whose dots correspond to an actual calendar date
  /// (Year/Weekly/Goal), so day numbers are meaningful. Life mode dots
  /// represent "days since birth", not a date, and there can be tens of
  /// thousands of them — numbering wouldn't be legible or useful.
  bool get supportsDateNumbers =>
      mode == CalendarMode.year || mode == CalendarMode.weekly || mode == CalendarMode.goal;

  /// The label of the marked date matching (month, day), if any.
  MarkedDate? markedDateFor(int month, int day) {
    for (final m in markedDates) {
      if (m.matches(month, day)) return m;
    }
    return null;
  }

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

  // ── Weekly helpers ────────────────────────────────────────────
  static int get currentWeek => (dayOfYear / 7).ceil().clamp(1, 52);

  // ── Goal helpers ──────────────────────────────────────────────
  /// Effective start of the goal range: goalStartDate if set, else today.
  DateTime get _goalStart {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    if (goalStartDate == null) return base;
    return DateTime(goalStartDate!.year, goalStartDate!.month, goalStartDate!.day);
  }

  /// Public accessor for the same effective start date, for renderers that
  /// need to map a dot index back to its actual calendar date.
  DateTime get effectiveGoalStart => _goalStart;

  int get goalTotalDays {
    if (goalDate == null) return 100;
    final diff = goalDate!.difference(_goalStart).inDays;
    if (diff <= 0) return 1;
    return diff + 1;
  }

  /// Days remaining from *today* until goalDate (a true countdown, regardless
  /// of when the range started).
  int get goalDaysLeft {
    if (goalDate == null) return 100;
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final diff = goalDate!.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  // ── Life helpers ────────────────────────────────────────────────
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

  int get lifeTotalWeeks => lifeExpectancyYears * 52;

  int get lifeWeeksLived {
    if (birthDate == null) return 0;
    final weeks = DateTime.now().difference(birthDate!).inDays ~/ 7;
    return weeks.clamp(0, lifeTotalWeeks);
  }

  int get lifeWeeksLeft =>
      (lifeTotalWeeks - lifeWeeksLived).clamp(0, lifeTotalWeeks);

  /// Life dot-grid totals in whichever unit `lifeUnit` selects.
  int get lifeTotalUnits =>
      lifeUnit == LifeUnit.weeks ? lifeTotalWeeks : lifeTotalDays;

  int get lifeUnitsLived =>
      lifeUnit == LifeUnit.weeks ? lifeWeeksLived : lifeDaysLived;

  int get lifeUnitsLeft =>
      lifeUnit == LifeUnit.weeks ? lifeWeeksLeft : lifeDaysLeft;

  // ── Computed dot counts ───────────────────────────────────────
  int get totalDots {
    switch (mode) {
      case CalendarMode.year:
        return daysInYear;
      case CalendarMode.weekly:
        return 52; // 52 weeks in a standard year
      case CalendarMode.goal:
        return goalTotalDays.clamp(1, 3650);
      case CalendarMode.life:
        return lifeTotalUnits;
      case CalendarMode.settings:
        return daysInYear;
    }
  }

  int get pastDots {
    switch (mode) {
      case CalendarMode.year:
        return dayOfYear - 1;
      case CalendarMode.weekly:
        return currentWeek - 1; // Past weeks
      case CalendarMode.goal:
        return (totalDots - goalDaysLeft).clamp(0, totalDots);
      case CalendarMode.life:
        return lifeUnitsLived;
      case CalendarMode.settings:
        return dayOfYear - 1;
    }
  }

  String get progressLabel {
    switch (mode) {
      case CalendarMode.year:
        return '${daysInYear - dayOfYear} days left · '
            '${(yearProgress * 100).toStringAsFixed(0)}%';
      case CalendarMode.weekly:
        return '${52 - currentWeek} weeks left · '
            '${(yearProgress * 100).toStringAsFixed(0)}%';
      case CalendarMode.goal:
        return '$goalDaysLeft days left · $goalName';
      case CalendarMode.life:
        final unitLabel = lifeUnit == LifeUnit.weeks ? 'weeks' : 'days';
        return '$lifeUnitsLeft $unitLabel left · '
            '${(lifeProgress * 100).toStringAsFixed(1)}%';
      case CalendarMode.settings:
        return '';
    }
  }
}

