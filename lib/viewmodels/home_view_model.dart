import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallpaper_settings.dart';
import '../core/app_theme.dart';

class HomeViewModel extends ChangeNotifier {
  static const _channel = MethodChannel('com.example.dotz/wallpaper');

  // ── Mode ──────────────────────────────────────────────────────
  CalendarMode _mode = CalendarMode.year;
  CalendarMode get mode => _mode;

  void setMode(CalendarMode m) {
    _mode = m;
    notifyListeners();
  }

  // ── Live wallpaper status ─────────────────────────────────────
  bool _live = false;
  bool get live => _live;

  Future<void> checkLive() async {
    try {
      final v = await _channel.invokeMethod<bool>('isLiveWallpaperActive') ?? false;
      _live = v;
      notifyListeners();
    } catch (_) {}
  }

  // ── Saving / loading state ────────────────────────────────────
  bool _saving = false;
  bool get saving => _saving;

  // ── Dot colours ──────────────────────────────────────────────
  Color _pastColor   = kDotPast;
  Color _todayColor  = kDotToday;
  Color _futureColor = kDotFuture;
  Color _bgColor     = kDotBg;

  Color get pastColor   => _pastColor;
  Color get todayColor  => _todayColor;
  Color get futureColor => _futureColor;
  Color get bgColor     => _bgColor;

  void setPastColor(Color c)   { _pastColor   = c; notifyListeners(); }
  void setTodayColor(Color c)  { _todayColor  = c; notifyListeners(); }
  void setFutureColor(Color c) { _futureColor = c; notifyListeners(); }
  void setBgColor(Color c)     { _bgColor     = c; notifyListeners(); }

  // ── Grid ──────────────────────────────────────────────────────
  int _columns = 20;
  int get columns => _columns;
  void setColumns(int v) { _columns = v; notifyListeners(); }

  // ── Label ─────────────────────────────────────────────────────
  bool _showLabel = true;
  bool get showLabel => _showLabel;
  void setShowLabel(bool v) { _showLabel = v; notifyListeners(); }

  // ── Goal ─────────────────────────────────────────────────────
  String    _goalName = 'My Goal';
  DateTime? _goalDate;

  String    get goalName => _goalName;
  DateTime? get goalDate => _goalDate;

  void setGoalName(String v) {
    _goalName = v.trim().isEmpty ? 'My Goal' : v.trim();
    notifyListeners();
  }

  void setGoalDate(DateTime d) {
    _goalDate = d;
    notifyListeners();
  }

  void clearGoal() {
    _goalName = 'My Goal';
    _goalDate = null;
    notifyListeners();
  }

  int get goalDaysLeft =>
      _goalDate == null
          ? 0
          : _goalDate!.difference(DateTime.now()).inDays.clamp(0, 999999);

  int get goalTotal {
    if (_goalDate == null) return 365;
    final diff = _goalDate!
        .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
    return diff <= 0 ? 1 : diff + 1;
  }

  // ── Life ──────────────────────────────────────────────────────
  DateTime? _birthDate;
  int       _lifeExp = 80;

  DateTime? get birthDate  => _birthDate;
  int       get lifeExp    => _lifeExp;

  void setBirthDate(DateTime d) { _birthDate = d; notifyListeners(); }
  void setLifeExp(int v)        { _lifeExp   = v; notifyListeners(); }

  // FIX: daysLived uses floor division from birth date to today
  int get daysLived {
    if (_birthDate == null) return 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final birth = DateTime(_birthDate!.year, _birthDate!.month, _birthDate!.day);
    return today.difference(birth).inDays.clamp(0, totalDays);
  }

  int get totalDays  => _lifeExp * 365;

  int get age {
    if (_birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - _birthDate!.year;
    if (now.month < _birthDate!.month ||
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      years--;
    }
    return years.clamp(0, 999);
  }

  // ── Assembled WallpaperSettings for the preview widget ───────
  WallpaperSettings get settings => WallpaperSettings(
    backgroundColor:     _bgColor,
    pastDotColor:        _pastColor,
    todayDotColor:       _todayColor,
    futureDotColor:      _futureColor,
    columns:             _columns,
    showProgressLabel:   _showLabel,
    mode:                _mode,
    goalName:            _goalName,
    goalDate:            _goalDate,
    birthDate:           _birthDate,
    lifeExpectancyYears: _lifeExp,
  );

  // ── Hero display values ───────────────────────────────────────
  String get heroTag => switch (_mode) {
    CalendarMode.year     => 'YEAR CALENDAR',
    CalendarMode.goal     => 'GOAL CALENDAR',
    CalendarMode.life     => 'LIFE CALENDAR',
    CalendarMode.settings => 'SETTINGS',
  };

  String get heroBigNum {
    final doy = WallpaperSettings.dayOfYear;
    return switch (_mode) {
      CalendarMode.year     => doy.toString().padLeft(2, '0'),
      CalendarMode.goal     => goalDaysLeft > 99 ? '$goalDaysLeft' : goalDaysLeft.toString().padLeft(2, '0'),
      CalendarMode.life     => daysLived > 99 ? '$daysLived' : daysLived.toString().padLeft(2, '0'),
      CalendarMode.settings => '⚙',
    };
  }

  String get heroTitle => switch (_mode) {
    CalendarMode.year     => 'Days\npassed',
    CalendarMode.goal     => _goalName,
    CalendarMode.life     => 'Days\nlived',
    CalendarMode.settings => 'Customize',
  };

  String get heroStatA {
    final doy = WallpaperSettings.dayOfYear;
    return switch (_mode) {
      CalendarMode.year     => 'Day $doy',
      CalendarMode.goal     => '$goalDaysLeft days left',
      CalendarMode.life     => '$daysLived of $totalDays days',
      CalendarMode.settings => 'Colors & Grid',
    };
  }

  String get heroStatB {
    final yp = WallpaperSettings.yearProgress;
    return switch (_mode) {
      CalendarMode.year     => '— ${(yp * 100).toStringAsFixed(0)}% of the year',
      CalendarMode.goal     => goalTotal > 0
          ? '— ${((goalTotal - goalDaysLeft) / goalTotal * 100).toStringAsFixed(0)}% done'
          : '',
      CalendarMode.life     => totalDays > 0
          ? '— ${(daysLived / totalDays * 100).toStringAsFixed(1)}% lived'
          : '',
      CalendarMode.settings => '— wallpaper appearance',
    };
  }

  // ── Platform: apply wallpaper ─────────────────────────────────
  int _toArgb(Color c) =>
      (c.alpha << 24) | (c.red << 16) | (c.green << 8) | c.blue;

  Future<bool> applyWallpaper() async {
    _saving = true;
    notifyListeners();
    try {
      final modeIdx = _mode == CalendarMode.goal
          ? 1
          : _mode == CalendarMode.life
              ? 2
              : 0;
      await _channel.invokeMethod('saveSettings', {
        'bgColor':     _toArgb(_bgColor),
        'pastColor':   _toArgb(_pastColor),
        'futureColor': _toArgb(_futureColor),
        'todayColor':  _toArgb(_todayColor),
        'columns':     _columns,
        'showLabel':   _showLabel,
        'mode':        modeIdx,
        'goalTotal':   goalTotal,
        'goalPast':    goalTotal - goalDaysLeft,
        'goalName':    _goalName,
        'lifeTotal':   totalDays,
        'lifeLived':   daysLived,
      });
      await _channel.invokeMethod('openWallpaperPicker');
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}