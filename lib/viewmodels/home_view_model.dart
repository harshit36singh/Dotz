import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/wallpaper_settings.dart';
import '../core/app_theme.dart';
import '../services/windows_wallpaper_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// URL of the daily-quote API (see .env / .env.example). Empty string if the
/// env var is missing, so a misconfigured build degrades gracefully instead
/// of crashing on startup.
String quoteApiUrl = dotenv.env['QUOTE_API_URL'] ?? '';

/// What to show at the bottom of the wallpaper
enum LabelMode { off, progress, quote, custom }

class HomeViewModel extends ChangeNotifier {
  static const _channel = MethodChannel('com.example.dotz/wallpaper');
  
  // ── Grid Scale ────────────────────────────────────────────────
  double _gridScale = 1.0;
  double get gridScale => _gridScale;
  void setGridScale(double scale) {
    _gridScale = scale;
    notifyListeners();
  }
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double get offsetX => _offsetX;
  double get offsetY => _offsetY;
  
  void setOffsets(double x, double y) {
    _offsetX = x.clamp(-1.0, 1.0); // Prevent dragging completely off-screen
    _offsetY = y.clamp(-1.0, 1.0);
    notifyListeners();
  }
  
  // ── Dot Shape ─────────────────────────────────────────────────
  DotShape _dotShape = DotShape.circle;
  DotShape get dotShape => _dotShape;
  void setDotShape(DotShape s) {
    _dotShape = s;
    notifyListeners(); // Updates the UI instantly
  }
  
  // ── Mode ──────────────────────────────────────────────────────
  CalendarMode _mode = CalendarMode.year;
  CalendarMode get mode => _mode;

  String _bgImagePath = '';
  String get bgImagePath => _bgImagePath;

  void setMode(CalendarMode m) {
    _mode = m;
    notifyListeners();
  }

  // ── Background Image Logic ────────────────────────────────────
  Future<void> pickBackgroundImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        // Fixed filename — only one background is ever active at a time.
        // A stable name (instead of the source file's original basename)
        // avoids two different gallery photos silently overwriting each
        // other when they share a camera-generated name, and lets us
        // reliably evict the old bytes from Flutter's image cache below
        // (a reused path with new bytes would otherwise keep showing the
        // stale cached image).
        final ext = p.extension(pickedFile.path);
        final savedImage =
            File('${directory.path}/wallpaper_bg${ext.isNotEmpty ? ext : '.jpg'}');

        if (_bgImagePath.isNotEmpty && _bgImagePath != savedImage.path) {
          try {
            await File(_bgImagePath).delete();
          } catch (_) {}
        }

        await File(pickedFile.path).copy(savedImage.path);
        PaintingBinding.instance.imageCache.evict(FileImage(savedImage));

        _bgImagePath = savedImage.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void clearBackgroundImage() {
    if (_bgImagePath.isNotEmpty) {
      PaintingBinding.instance.imageCache.evict(FileImage(File(_bgImagePath)));
      try {
        File(_bgImagePath).delete();
      } catch (_) {}
    }
    _bgImagePath = '';
    notifyListeners();
  }

  // ── Live wallpaper status ─────────────────────────────────────
  bool _live = false;
  bool get live => _live;

  Future<void> checkLive() async {
    // No such concept on Windows — desktop wallpaper is always static.
    if (Platform.isWindows) return;
    try {
      final v = await _channel.invokeMethod<bool>('isLiveWallpaperActive') ?? false;
      _live = v;
      notifyListeners();
    } catch (e) {
      debugPrint('checkLive failed: $e');
    }
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
  
  void setBgColor(Color c) {
    _bgColor = c;
    _bgImagePath = '';
    notifyListeners();
  }

  // ── Marked Dates (Year / Weekly mode only) ──────────────────────
  final List<MarkedDate> _markedDates = [];
  Color _milestoneColor = const Color(0xFFFFD700);

  List<MarkedDate> get markedDates => List.unmodifiable(_markedDates);
  Color get milestoneColor => _milestoneColor;

  void addMarkedDate(MarkedDate date) {
    _markedDates.add(date);
    notifyListeners();
  }

  void removeMarkedDate(MarkedDate date) {
    _markedDates.remove(date);
    notifyListeners();
  }

  void setMilestoneColor(Color c) {
    _milestoneColor = c;
    notifyListeners();
  }

  // ── Label colour ──────────────────────────────────────────────
  Color _labelColor = const Color(0xFFFFFFFF);
  Color get labelColor => _labelColor;
  void setLabelColor(Color c) { _labelColor = c; notifyListeners(); }

  // ── Label font size (0 = auto) ────────────────────────────────
  double _labelFontSize = 0;
  double get labelFontSize => _labelFontSize;
  bool get labelFontSizeAuto => _labelFontSize == 0;
  void setLabelFontSize(double v) {
    _labelFontSize = v;
    notifyListeners();
  }

  // ── Grid ──────────────────────────────────────────────────────
  int _columns = 20;
  int get columns => _columns;
  void setColumns(int v) { _columns = v; notifyListeners(); }

  // ── Label mode ────────────────────────────────────────────────
  LabelMode _labelMode = LabelMode.progress;
  LabelMode get labelMode => _labelMode;

  bool get showLabel => _labelMode != LabelMode.off;

  void setLabelMode(LabelMode m) {
    _labelMode = m;
    if (m == LabelMode.quote && _quoteText.isEmpty && !_quoteFetching) {
      fetchQuote();
    }
    notifyListeners();
  }

  void setShowLabel(bool v) => setLabelMode(v ? LabelMode.progress : LabelMode.off);

  // ── Quote ─────────────────────────────────────────────────────
  String _quoteText    = '';
  String _quoteAuthor  = '';
  bool   _quoteFetching = false;
  bool   _quoteError    = false;

  String get quoteText      => _quoteText;
  String get quoteAuthor    => _quoteAuthor;
  bool   get quoteFetching  => _quoteFetching;
  bool   get quoteError     => _quoteError;

  Future<void> fetchQuote() async {
    if (quoteApiUrl.isEmpty) {
      _quoteFetching = false;
      _quoteError    = true;
      notifyListeners();
      return;
    }
    _quoteFetching = true;
    _quoteError    = false;
    notifyListeners();
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req  = await client.getUrl(Uri.parse(quoteApiUrl));
      req.headers.set('Accept', 'application/json');
      final res  = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();
      final list = jsonDecode(body) as List<dynamic>;
      if (list.isNotEmpty) {
        final item   = list.first as Map<String, dynamic>;
        _quoteText   = (item['q'] as String? ?? '').trim();
        _quoteAuthor = (item['a'] as String? ?? '').trim();
      }
    } catch (e) {
      debugPrint('fetchQuote failed: $e');
      _quoteError = true;
    } finally {
      _quoteFetching = false;
      notifyListeners();
    }
  }

  // ── Custom label text ─────────────────────────────────────────
  String _customLabelText = '';
  String get customLabelText => _customLabelText;
  void setCustomLabelText(String v) {
    _customLabelText = v;
    notifyListeners();
  }

  String get resolvedLabel {
    switch (_labelMode) {
      case LabelMode.quote:
        if (_quoteText.isNotEmpty) {
          return _quoteAuthor.isNotEmpty
              ? '"$_quoteText" — $_quoteAuthor'
              : '"$_quoteText"';
        }
        return settings.progressLabel;
      case LabelMode.progress:
        return settings.progressLabel;
      case LabelMode.custom:
        return _customLabelText.trim().isEmpty ? settings.progressLabel : _customLabelText.trim();
      case LabelMode.off:
        return '';
    }
  }

  // ── Goal ─────────────────────────────────────────────────────
  String    _goalName = 'My Goal';
  DateTime? _goalDate;
  DateTime? _goalStartDate; // null = count from today

  String    get goalName      => _goalName;
  DateTime? get goalDate      => _goalDate;
  DateTime? get goalStartDate => _goalStartDate;

  void setGoalName(String v) {
    _goalName = v.trim().isEmpty ? 'My Goal' : v.trim();
    notifyListeners();
  }

  void setGoalDate(DateTime d) { _goalDate = d; notifyListeners(); }

  void setGoalStartDate(DateTime? d) { _goalStartDate = d; notifyListeners(); }

  void clearGoal() {
    _goalName = 'My Goal';
    _goalDate = null;
    _goalStartDate = null;
    notifyListeners();
  }

  int get goalDaysLeft =>
      _goalDate == null
          ? 0
          : _goalDate!.difference(DateTime.now()).inDays.clamp(0, 999999);

  DateTime get _effectiveGoalStart {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    if (_goalStartDate == null) return base;
    return DateTime(_goalStartDate!.year, _goalStartDate!.month, _goalStartDate!.day);
  }

  int get goalTotal {
    if (_goalDate == null) return 365;
    final diff = _goalDate!.difference(_effectiveGoalStart).inDays;
    return diff <= 0 ? 1 : diff + 1;
  }

  // ── Life ──────────────────────────────────────────────────────
  DateTime? _birthDate;
  int       _lifeExp = 80;
  LifeUnit  _lifeUnit = LifeUnit.days;

  DateTime? get birthDate => _birthDate;
  int       get lifeExp   => _lifeExp;
  LifeUnit  get lifeUnit  => _lifeUnit;

  void setBirthDate(DateTime d) { _birthDate = d; notifyListeners(); }
  void setLifeExp(int v)        { _lifeExp   = v; notifyListeners(); }
  void setLifeUnit(LifeUnit u)  { _lifeUnit  = u; notifyListeners(); }

  /// Life progress in whichever unit [_lifeUnit] selects (days or weeks).
  int get daysLived {
    if (_birthDate == null) return 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final birth = DateTime(_birthDate!.year, _birthDate!.month, _birthDate!.day);
    final dayBasedTotal = _lifeExp * 365;
    final elapsedDays = today.difference(birth).inDays.clamp(0, dayBasedTotal);
    final elapsed = _lifeUnit == LifeUnit.weeks ? elapsedDays ~/ 7 : elapsedDays;
    return elapsed.clamp(0, totalDays);
  }

  int get totalDays => _lifeUnit == LifeUnit.weeks ? _lifeExp * 52 : _lifeExp * 365;

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

  // ── Helper for Weekly Mode ────────────────────────────────────
  int get currentWeek => (WallpaperSettings.dayOfYear / 7).ceil().clamp(1, 52);

  // ── Assembled WallpaperSettings ───────────────────────────────
  WallpaperSettings get settings => WallpaperSettings(
    backgroundColor:     _bgColor,
    pastDotColor:        _pastColor,
    todayDotColor:       _todayColor,
    futureDotColor:      _futureColor,
    textColor:           _labelColor,
    labelFontSize:       _labelFontSize,
    columns:             _columns,
    showProgressLabel:   showLabel,
    mode:                _mode,
    goalName:            _goalName,
    goalDate:            _goalDate,
    goalStartDate:       _goalStartDate,
    birthDate:           _birthDate,
    lifeExpectancyYears: _lifeExp,
    lifeUnit:            _lifeUnit,
    bgImagePath:         _bgImagePath,
    shape:               _dotShape,
    gridScale:           _gridScale,
    offsetX:             _offsetX,
    offsetY:             _offsetY,
    markedDates:         _markedDates,
    milestoneColor:      _milestoneColor,
  );

  // ── Hero display values ───────────────────────────────────────
  String get heroTag => switch (_mode) {
    CalendarMode.year     => 'YEAR CALENDAR',
    CalendarMode.goal     => 'GOAL CALENDAR',
    CalendarMode.life     => 'LIFE CALENDAR',
    CalendarMode.weekly   => 'WEEKLY CALENDAR', // Added Weekly
    CalendarMode.settings => 'SETTINGS',
  };

  String get heroBigNum {
    final doy = WallpaperSettings.dayOfYear;
    return switch (_mode) {
      CalendarMode.year     => doy.toString().padLeft(2, '0'),
      CalendarMode.goal     => goalDaysLeft > 99 ? '$goalDaysLeft' : goalDaysLeft.toString().padLeft(2, '0'),
      CalendarMode.life     => daysLived > 99 ? '$daysLived' : daysLived.toString().padLeft(2, '0'),
      CalendarMode.weekly   => currentWeek.toString().padLeft(2, '0'), // Added Weekly
      CalendarMode.settings => '⚙',
    };
  }

  String get heroTitle => switch (_mode) {
    CalendarMode.year     => 'Days\npassed',
    CalendarMode.goal     => _goalName,
    CalendarMode.life     => 'Days\nlived',
    CalendarMode.weekly   => 'Weeks\npassed', // Added Weekly
    CalendarMode.settings => 'Customize',
  };

  String get heroStatA {
    final doy = WallpaperSettings.dayOfYear;
    return switch (_mode) {
      CalendarMode.year     => 'Day $doy',
      CalendarMode.goal     => '$goalDaysLeft days left',
      CalendarMode.life     => '$daysLived of $totalDays ${_lifeUnit == LifeUnit.weeks ? 'weeks' : 'days'}',
      CalendarMode.weekly   => 'Week $currentWeek of 52', // Added Weekly
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
      CalendarMode.weekly   => '— ${(yp * 100).toStringAsFixed(0)}% of the year', // Added Weekly
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
      if (Platform.isWindows) {
        return await WindowsWallpaperService.apply(
          settings: settings,
          bgImagePath: _bgImagePath,
          bgColor: _bgColor,
        );
      }
      return await _applyWallpaperAndroid();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> _applyWallpaperAndroid() async {
    try {
      // ── ADDED MODE 3 FOR WEEKLY (Native mapping) ──
      final modeIdx = switch (_mode) {
        CalendarMode.year   => 0,
        CalendarMode.goal   => 1,
        CalendarMode.life   => 2,
        CalendarMode.weekly => 3, 
        _ => 0,
      };

      await _channel.invokeMethod('saveSettings', {
        'bgColor':        _toArgb(_bgColor),
        'pastColor':      _toArgb(_pastColor),
        'futureColor':    _toArgb(_futureColor),
        'todayColor':     _toArgb(_todayColor),
        'labelColor':     _toArgb(_labelColor),
        'labelFontSize':  _labelFontSize,
        'columns':        _columns,
        'showLabel':      showLabel,
        'labelMode':      _labelMode.index,
        'customLabel':    resolvedLabel,
        'mode':           modeIdx,
        // Precomputed snapshot — used for the first render immediately after
        // apply, and as a fallback if the date fields below are unset.
        'goalTotal':      goalTotal,
        'goalPast':       goalTotal - goalDaysLeft,
        'goalName':       _goalName,
        'lifeTotal':      totalDays,
        'lifeLived':      daysLived,
        // Raw dates — the native engine recomputes goal/life progress from
        // these every day so the wallpaper keeps advancing without the app
        // being reopened (matches how Year/Weekly mode already self-advance).
        'goalEndMillis':   _goalDate?.millisecondsSinceEpoch ?? 0,
        'goalStartMillis': _effectiveGoalStart.millisecondsSinceEpoch,
        'birthMillis':     _birthDate?.millisecondsSinceEpoch ?? 0,
        'lifeExpYears':    _lifeExp,
        'lifeUnit':        _lifeUnit.index,
        'apiUrl':         quoteApiUrl,
        'bgImagePath':    _bgImagePath,
        'dotShape':       _dotShape.index,
        'gridScale':      _gridScale,
        'offsetX':        _offsetX,
        'offsetY':        _offsetY,
        'markedDates':    jsonEncode(_markedDates.map((m) => m.toJson()).toList()),
        'milestoneColor': _toArgb(_milestoneColor),
      });
      await _channel.invokeMethod('openWallpaperPicker');
      return true;
    } catch (e) {
      debugPrint('applyWallpaper failed: $e');
      return false;
    }
  }
}