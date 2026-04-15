import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // ← ADDED THIS IMPORT
import '../models/wallpaper_settings.dart';
import '../core/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String apiKey = dotenv.env['API_KEY']!;

/// What to show at the bottom of the wallpaper
enum LabelMode { off, progress, quote, custom }

class HomeViewModel extends ChangeNotifier {
  static const _channel = MethodChannel('com.example.dotz/wallpaper');

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
      // Opens the gallery for the user to select a photo
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        // 1. Get the app's safe document directory
        final directory = await getApplicationDocumentsDirectory();
        
        // 2. Extract the file name
        final fileName = p.basename(pickedFile.path);
        
        // 3. Create a permanent file path
        final savedImage = File('${directory.path}/$fileName');
        
        // 4. Copy the image there
        await File(pickedFile.path).copy(savedImage.path);
        
        // 5. Save the path to state
        _bgImagePath = savedImage.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void clearBackgroundImage() {
    _bgImagePath = '';
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

  // ── Label colour ──────────────────────────────────────────────
  Color _labelColor = const Color(0xFFFFFFFF);
  Color get labelColor => _labelColor;
  void setLabelColor(Color c) { _labelColor = c; notifyListeners(); }

  // ── Label font size (0 = auto) ────────────────────────────────
  /// Range: 8–32. 0 means "auto" (derived from dot radius on native side).
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
    _quoteFetching = true;
    _quoteError    = false;
    notifyListeners();
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req  = await client.getUrl(Uri.parse(apiKey));
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
    } catch (_) {
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

  String    get goalName => _goalName;
  DateTime? get goalDate => _goalDate;

  void setGoalName(String v) {
    _goalName = v.trim().isEmpty ? 'My Goal' : v.trim();
    notifyListeners();
  }

  void setGoalDate(DateTime d) { _goalDate = d; notifyListeners(); }

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

  DateTime? get birthDate => _birthDate;
  int       get lifeExp   => _lifeExp;

  void setBirthDate(DateTime d) { _birthDate = d; notifyListeners(); }
  void setLifeExp(int v)        { _lifeExp   = v; notifyListeners(); }

  int get daysLived {
    if (_birthDate == null) return 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final birth = DateTime(_birthDate!.year, _birthDate!.month, _birthDate!.day);
    return today.difference(birth).inDays.clamp(0, totalDays);
  }

  int get totalDays => _lifeExp * 365;

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
          : _mode == CalendarMode.life ? 2 : 0;
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
        'goalTotal':      goalTotal,
        'goalPast':       goalTotal - goalDaysLeft,
        'goalName':       _goalName,
        'lifeTotal':      totalDays,
        'lifeLived':      daysLived,
        'apiUrl':         apiKey,
        'bgImagePath':    _bgImagePath,
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