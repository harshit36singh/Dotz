import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallpaper_settings.dart';
import '../widgets/dot_grid_widget.dart';
import 'goal_setup_screen.dart';
import 'life_setup_screen.dart';

// ── Palette ──────────────────────────────────────────────────────
const _cream  = Color(0xFFF5F0E8);
const _paper  = Color(0xFFEEE9DF);
const _white  = Color(0xFFFAF8F4);
const _ink    = Color(0xFF1C1814);
const _inkMid = Color(0xFF6B6660);
const _inkFad = Color(0xFFB8B4AC);
const _rule   = Color(0xFFE0DAD0);
const _red    = Color(0xFFCC2200);
const _dkBg   = Color(0xFF100F0D);
const _dkSurf = Color(0xFF181613);
const _dkSide = Color(0xFF0C0B09);
const _dkInk  = Color(0xFFF0EBE2);
const _dkMid  = Color(0xFF686460);
const _dkRule = Color(0xFF272420);

// ── Breakpoints ──────────────────────────────────────────────────
const _tabletBreak = 600.0;  // >= 600 = tablet layout
const _desktopBreak = 900.0; // >= 900 = wide tablet / desktop

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _ch = MethodChannel('com.example.dotz/wallpaper');

  WallpaperSettings _s = WallpaperSettings();
  CalendarMode _mode   = CalendarMode.year;
  bool _saving = false;
  bool _live   = false;

  late AnimationController _ac;
  late Animation<double>    _af;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 360));
    _af = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();
    _checkLive();
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  Future<void> _checkLive() async {
    try {
      final v = await _ch.invokeMethod<bool>('isLiveWallpaperActive') ?? false;
      if (mounted) setState(() => _live = v);
    } catch (_) {}
  }

  int _toA(Color c) =>
      (c.alpha << 24) | (c.red << 16) | (c.green << 8) | c.blue;

  Future<void> _apply() async {
    setState(() => _saving = true);
    try {
      await _ch.invokeMethod('saveSettings', {
        'bgColor':     _toA(_s.backgroundColor),
        'pastColor':   _toA(_s.pastDotColor),
        'futureColor': _toA(_s.futureDotColor),
        'todayColor':  _toA(_s.todayDotColor),
        'columns':     _s.columns,
        'showLabel':   _s.showProgressLabel,
      });
      await _ch.invokeMethod('openWallpaperPicker');
      if (mounted) _bottomSheet();
    } catch (_) {
      if (mounted) _bottomSheet();
    } finally {
      setState(() => _saving = false);
    }
  }

  void _bottomSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: _surf,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 2, color: _rul),
        const SizedBox(height: 32),
        Text('Apply to Lock Screen',
            style: TextStyle(color: _ink_, fontSize: 24,
                fontWeight: FontWeight.w800, fontStyle: FontStyle.italic,
                letterSpacing: -0.5)),
        const SizedBox(height: 12),
        Text('Long-press home → Wallpapers → Live → DotZ → Apply',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mid_, fontSize: 14, height: 1.8)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity, height: 52,
            alignment: Alignment.center,
            color: _red,
            child: const Text('GOT IT',
                style: TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 2.5)),
          ),
        ),
      ]),
    ),
  ).then((_) => _checkLive());

  void _go(CalendarMode m) async {
    if (m == CalendarMode.goal && _s.goalDate == null) {
      final r = await Navigator.push<WallpaperSettings>(context,
          MaterialPageRoute(builder: (_) => GoalSetupScreen(settings: _s)));
      if (r != null) _swap(r.copyWith(mode: m));
      return;
    }
    if (m == CalendarMode.life && _s.birthDate == null) {
      final r = await Navigator.push<WallpaperSettings>(context,
          MaterialPageRoute(builder: (_) => LifeSetupScreen(settings: _s)));
      if (r != null) _swap(r.copyWith(mode: m));
      return;
    }
    _swap(_s.copyWith(mode: m));
  }

  void _swap(WallpaperSettings s) {
    _ac.reset();
    setState(() { _s = s; _mode = s.mode; });
    _ac.forward();
  }

  void _toggleTheme() {
    final d = !_s.isDark;
    setState(() => _s = _s.copyWith(
      isDark: d,
      backgroundColor: d ? _dkBg   : _cream,
      pastDotColor:    d ? _dkInk  : _ink,
      futureDotColor:  d ? _dkRule : _rule,
      textColor:       d ? _dkInk  : _ink,
    ));
  }

  // ── theme helpers ─────────────────────────────────────────────
  bool  get _d     => _s.isDark;
  Color _c(Color l, Color dk) => _d ? dk : l;
  Color get _bg_   => _c(_cream, _dkBg);
  Color get _surf  => _c(_white, _dkSurf);
  Color get _side_ => _c(_paper, _dkSide);
  Color get _ink_  => _c(_ink,   _dkInk);
  Color get _mid_  => _c(_inkMid,_dkMid);
  Color get _fad_  => _c(_inkFad, const Color(0xFF484440));
  Color get _rul   => _c(_rule,  _dkRule);

  @override
  Widget build(BuildContext context) {
    final mq  = MediaQuery.of(context);
    final sw  = mq.size.width;
    final sh  = mq.size.height;
    final isTab  = sw >= _tabletBreak;
    final isWide = sw >= _desktopBreak;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _d ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bg_,
        body: SafeArea(
          child: isTab
              ? _tabletLayout(sw, sh, isWide)
              : _phoneLayout(sw, sh),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PHONE LAYOUT  (< 600px)  — narrow sidebar with rotated labels
  // ════════════════════════════════════════════════════════════════
  Widget _phoneLayout(double sw, double sh) {
    final pw = sw - 52.0 - 28.0;
    final ph = (pw * 19 / 9).clamp(220.0, sh * 0.48);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Narrow sidebar
        _PhoneSidebar(
          dark: _d, bg: _side_, ink: _ink_, mid: _mid_, fad: _fad_, rul: _rul,
          mode: _mode, onMode: _go, onTheme: _toggleTheme,
        ),
        // Main scroll
        Expanded(
          child: _MainContent(
            s: _s, mode: _mode, saving: _saving, live: _live,
            surf: _surf, rul: _rul, ink: _ink_, mid: _mid_, fad: _fad_,
            fade: _af, previewH: ph, isTablet: false, isWide: false,
            onApply: _apply,
            onColorChanged: (s) => setState(() => _s = s),
            onColumnsChanged: (v) => setState(() => _s = _s.copyWith(columns: v)),
            onLabelChanged: (v) => setState(() => _s = _s.copyWith(showProgressLabel: v)),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TABLET LAYOUT  (>= 600px)  — expanded sidebar + 2-col content
  // ════════════════════════════════════════════════════════════════
  Widget _tabletLayout(double sw, double sh, bool isWide) {
    final sideW = isWide ? 200.0 : 160.0;
    final contentW = sw - sideW;
    final pw = (contentW * 0.88).clamp(200.0, 520.0);
    final ph = (pw * 19 / 9).clamp(260.0, sh * 0.55);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Wide sidebar with horizontal labels
        _TabletSidebar(
          width: sideW, dark: _d,
          bg: _side_, ink: _ink_, mid: _mid_, fad: _fad_, rul: _rul,
          mode: _mode, onMode: _go, onTheme: _toggleTheme,
        ),
        // Main scroll
        Expanded(
          child: _MainContent(
            s: _s, mode: _mode, saving: _saving, live: _live,
            surf: _surf, rul: _rul, ink: _ink_, mid: _mid_, fad: _fad_,
            fade: _af, previewH: ph, isTablet: true, isWide: isWide,
            onApply: _apply,
            onColorChanged: (s) => setState(() => _s = s),
            onColumnsChanged: (v) => setState(() => _s = _s.copyWith(columns: v)),
            onLabelChanged: (v) => setState(() => _s = _s.copyWith(showProgressLabel: v)),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  PHONE SIDEBAR  — 52px, rotated text
// ════════════════════════════════════════════════════════════════
class _PhoneSidebar extends StatelessWidget {
  final bool dark;
  final Color bg, ink, mid, fad, rul;
  final CalendarMode mode;
  final void Function(CalendarMode) onMode;
  final VoidCallback onTheme;

  const _PhoneSidebar({
    required this.dark, required this.bg, required this.ink,
    required this.mid, required this.fad, required this.rul,
    required this.mode, required this.onMode, required this.onTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: rul, width: 1)),
      ),
      child: Column(children: [
        const SizedBox(height: 22),
        // Script mark
        Text('D', style: TextStyle(color: ink, fontSize: 26,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        Container(height: 1, color: rul,
            margin: const EdgeInsets.symmetric(horizontal: 12)),
        const SizedBox(height: 24),
        // Rotated nav
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RNav('Life', mode == CalendarMode.life, fad, mid,
                  () => onMode(CalendarMode.life)),
              const SizedBox(height: 32),
              _RNav('Goal', mode == CalendarMode.goal, fad, mid,
                  () => onMode(CalendarMode.goal)),
              const SizedBox(height: 32),
              _RNav('Year', mode == CalendarMode.year, fad, mid,
                  () => onMode(CalendarMode.year)),
            ],
          ),
        ),
        // Red accent bar
        Container(width: 2, height: 40, color: _red,
            margin: const EdgeInsets.only(bottom: 10)),
        // Theme toggle
        _ThemeBtn(rul: rul, mid: mid, dark: dark, onTap: onTheme),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TABLET SIDEBAR  — wide, horizontal labels, full branding
// ════════════════════════════════════════════════════════════════
class _TabletSidebar extends StatelessWidget {
  final double width;
  final bool dark;
  final Color bg, ink, mid, fad, rul;
  final CalendarMode mode;
  final void Function(CalendarMode) onMode;
  final VoidCallback onTheme;

  const _TabletSidebar({
    required this.width, required this.dark,
    required this.bg, required this.ink, required this.mid,
    required this.fad, required this.rul,
    required this.mode, required this.onMode, required this.onTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: rul, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Wordmark
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('DotZ', style: TextStyle(
              color: ink, fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            )),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('LIFE CALENDAR', style: TextStyle(
              color: fad, fontSize: 8,
              fontWeight: FontWeight.w700, letterSpacing: 2.5,
            )),
          ),
          const SizedBox(height: 28),
          Divider(color: rul, height: 1, indent: 24, endIndent: 24),
          const SizedBox(height: 28),
          // Horizontal nav items
          _HNav('Year',  mode == CalendarMode.year, fad, mid,
              () => onMode(CalendarMode.year)),
          _HNav('Goal',  mode == CalendarMode.goal, fad, mid,
              () => onMode(CalendarMode.goal)),
          _HNav('Life',  mode == CalendarMode.life, fad, mid,
              () => onMode(CalendarMode.life)),
          const Spacer(),
          Divider(color: rul, height: 1, indent: 24, endIndent: 24),
          const SizedBox(height: 20),
          // Theme toggle row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: GestureDetector(
              onTap: onTheme,
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: rul),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: mid, size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Text(dark ? 'Light mode' : 'Dark mode',
                    style: TextStyle(color: mid, fontSize: 11,
                        fontWeight: FontWeight.w500, letterSpacing: 0.5)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  MAIN CONTENT  — shared between phone and tablet
// ════════════════════════════════════════════════════════════════
class _MainContent extends StatelessWidget {
  final WallpaperSettings s;
  final CalendarMode mode;
  final bool saving, live, isTablet, isWide;
  final Color surf, rul, ink, mid, fad;
  final Animation<double> fade;
  final double previewH;
  final VoidCallback onApply;
  final void Function(WallpaperSettings) onColorChanged;
  final void Function(int) onColumnsChanged;
  final void Function(bool) onLabelChanged;

  const _MainContent({
    required this.s, required this.mode, required this.saving,
    required this.live, required this.isTablet, required this.isWide,
    required this.surf, required this.rul, required this.ink,
    required this.mid, required this.fad, required this.fade,
    required this.previewH, required this.onApply,
    required this.onColorChanged, required this.onColumnsChanged,
    required this.onLabelChanged,
  });

  // On tablet, show preview + controls side by side if wide enough
  @override
  Widget build(BuildContext context) {
    if (isWide) return _wideContent(context);
    return _stackContent(context);
  }

  // Phone + narrow tablet: single column scroll
  Widget _stackContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._topBar(),
          _hr(),
          ..._hero(isTablet ? 36.0 : 24.0),
          _hr(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: fade,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity, height: previewH,
                      foregroundDecoration: BoxDecoration(
                        border: Border.all(color: rul),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DotGridWallpaper(settings: s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _hr(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20),
            child: _controls(context),
          ),
          _hr(),
          Padding(
            padding: EdgeInsets.fromLTRB(
                isTablet ? 32 : 20, 0,
                isTablet ? 32 : 20, 48),
            child: _applyBtn(),
          ),
        ],
      ),
    );
  }

  // Wide tablet: preview left, controls right
  Widget _wideContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._topBar(),
          _hr(),
          ..._hero(40),
          _hr(),
          // Two-column layout
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview
                Expanded(
                  flex: 5,
                  child: FadeTransition(
                    opacity: fade,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: previewH,
                        foregroundDecoration: BoxDecoration(
                          border: Border.all(color: rul),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DotGridWallpaper(settings: s),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // Controls
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _controls(context),
                      const SizedBox(height: 32),
                      _applyBtn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  List<Widget> _topBar() => [
    Padding(
      padding: EdgeInsets.fromLTRB(
          isTablet ? 32 : 20, isTablet ? 28 : 22,
          isTablet ? 32 : 20, 0),
      child: Row(children: [
        if (!isTablet) ...[
          Text('DotZ', style: TextStyle(
            color: ink, fontSize: 20,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          )),
          const Spacer(),
        ] else
          const Spacer(),
        // Live dot indicator
        Container(width: 6, height: 6, decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: live ? const Color(0xFF4CAF50) : fad,
        )),
        const SizedBox(width: 6),
        Text(live ? 'live' : 'not set', style: TextStyle(
          color: live ? const Color(0xFF4CAF50) : fad,
          fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5,
        )),
      ]),
    ),
    SizedBox(height: isTablet ? 0 : 0),
  ];

  List<Widget> _hero(double hPad) => [
    Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_tag, style: TextStyle(
            color: mid, fontSize: 9,
            fontWeight: FontWeight.w600, letterSpacing: 3.0,
          )),
          const SizedBox(height: 2),
          FadeTransition(
            opacity: fade,
            child: Text(_bigNum, style: TextStyle(
              color: _red,
              fontSize: isTablet ? 96 : 116,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              height: 0.85,
              letterSpacing: isTablet ? -4 : -6,
            )),
          ),
          const SizedBox(height: 4),
          FadeTransition(
            opacity: fade,
            child: Text(_title, style: TextStyle(
              color: _red,
              fontSize: isTablet ? 28 : 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              height: 1.15, letterSpacing: -0.5,
            )),
          ),
          const SizedBox(height: 20),
          Text('PROGRESS:', style: TextStyle(
            color: fad, fontSize: 8,
            fontWeight: FontWeight.w700, letterSpacing: 3.0,
          )),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_statA, style: TextStyle(
                color: ink, fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w800, letterSpacing: -0.3,
              )),
              const SizedBox(width: 14),
              Text(_statB, style: TextStyle(
                color: mid, fontSize: 13,
                fontWeight: FontWeight.w400, letterSpacing: 0.3,
              )),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  ];

  Widget _controls(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Colours
      _Cap('COLOURS', fad),
      const SizedBox(height: 16),
      _ColorStrip(s: s, surf: surf, rul: rul, ink: ink, mid: mid,
          onChanged: onColorChanged),
      const SizedBox(height: 28),
      Divider(color: rul, height: 1),
      const SizedBox(height: 28),

      // Grid
      _Cap('GRID DENSITY', fad),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${s.columns}', style: const TextStyle(
            color: _red, fontSize: 44,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            height: 1, letterSpacing: -2,
          )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('columns', style: TextStyle(
                    color: mid, fontSize: 10,
                    fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _red,
                    inactiveTrackColor: rul,
                    thumbColor: _red,
                    overlayColor: _red.withOpacity(0.08),
                    trackHeight: 1,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5),
                  ),
                  child: Slider(
                    value: s.columns.toDouble(),
                    min: 10, max: 30, divisions: 20,
                    onChanged: (v) => onColumnsChanged(v.round()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 28),
      Divider(color: rul, height: 1),
      const SizedBox(height: 28),

      // Display
      _Cap('DISPLAY', fad),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Progress label', style: TextStyle(
                color: ink, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('Show days left at bottom', style: TextStyle(
                color: mid, fontSize: 11, letterSpacing: 0.2)),
          ]),
          Switch(
            value: s.showProgressLabel,
            onChanged: onLabelChanged,
            activeColor: _red,
            trackOutlineColor: MaterialStateProperty.all(rul),
          ),
        ],
      ),
    ],
  );

  Widget _applyBtn() => GestureDetector(
    onTap: saving ? null : onApply,
    child: Container(
      width: double.infinity, height: 52,
      alignment: Alignment.center,
      color: _red,
      child: saving
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Text('APPLY TO LOCK SCREEN',
              style: TextStyle(color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 2.5)),
    ),
  );

  Widget _hr() => Container(height: 1, color: rul);

  // ── content getters ──────────────────────────────────────────

  String get _tag {
    switch (mode) {
      case CalendarMode.year: return 'YEAR CALENDAR';
      case CalendarMode.goal: return 'GOAL CALENDAR';
      case CalendarMode.life: return 'LIFE CALENDAR';
    }
  }

  String get _bigNum {
    switch (mode) {
      case CalendarMode.year:
        return WallpaperSettings.dayOfYear.toString().padLeft(2, '0');
      case CalendarMode.goal:
        final d = s.goalDaysLeft;
        return d > 99 ? '$d' : d.toString().padLeft(2, '0');
      case CalendarMode.life:
        final w = s.lifeWeeksLived;
        return w > 99 ? '$w' : w.toString().padLeft(2, '0');
    }
  }

  String get _title {
    switch (mode) {
      case CalendarMode.year:  return 'Days\npassed';
      case CalendarMode.goal:  return s.goalName;
      case CalendarMode.life:  return 'Weeks\nlived';
    }
  }

  String get _statA {
    switch (mode) {
      case CalendarMode.year:
        return 'Day ${WallpaperSettings.dayOfYear}';
      case CalendarMode.goal:
        return '${s.goalDaysLeft} days left';
      case CalendarMode.life:
        return '${s.lifeWeeksLived} of ${s.lifeTotalWeeks} wks';
    }
  }

  String get _statB {
    switch (mode) {
      case CalendarMode.year:
        return '— ${(WallpaperSettings.yearProgress * 100).toStringAsFixed(0)}% of the year';
      case CalendarMode.goal:
        final p = ((s.totalDots - s.goalDaysLeft) / s.totalDots * 100).toStringAsFixed(0);
        return '— $p% done';
      case CalendarMode.life:
        return '— ${(s.lifeProgress * 100).toStringAsFixed(1)}% lived';
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════

// Rotated nav (phone sidebar)
class _RNav extends StatelessWidget {
  final String label; final bool active;
  final Color inactive, mid; final VoidCallback onTap;
  const _RNav(this.label, this.active, this.inactive, this.mid, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: RotatedBox(quarterTurns: 3,
      child: Text(label, style: TextStyle(
        color: active ? _red : mid,
        fontSize: active ? 11 : 10,
        fontWeight: active ? FontWeight.w800 : FontWeight.w400,
        letterSpacing: active ? 0.3 : 2.5,
      ))),
  );
}

// Horizontal nav (tablet sidebar)
class _HNav extends StatelessWidget {
  final String label; final bool active;
  final Color fad, mid; final VoidCallback onTap;
  const _HNav(this.label, this.active, this.fad, this.mid, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: active ? _red : Colors.transparent, width: 2),
        ),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(
          color: active ? _red : mid,
          fontSize: active ? 13 : 12,
          fontWeight: active ? FontWeight.w800 : FontWeight.w400,
          letterSpacing: active ? 0.3 : 1.5,
        )),
        if (active) ...[
          const Spacer(),
          Container(width: 5, height: 5, decoration: const BoxDecoration(
            color: _red, shape: BoxShape.circle,
          )),
        ],
      ]),
    ),
  );
}

class _ThemeBtn extends StatelessWidget {
  final Color rul, mid; final bool dark; final VoidCallback onTap;
  const _ThemeBtn({required this.rul, required this.mid,
      required this.dark, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: rul),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: mid, size: 14,
      ),
    ),
  );
}

class _Cap extends StatelessWidget {
  final String t; final Color c;
  const _Cap(this.t, this.c);
  @override
  Widget build(BuildContext ctx) => Text(t,
    style: TextStyle(color: c, fontSize: 9,
        fontWeight: FontWeight.w700, letterSpacing: 3.0));
}

// ── Color strip ───────────────────────────────────────────────────
class _ColorStrip extends StatelessWidget {
  final WallpaperSettings s;
  final Color surf, rul, ink, mid;
  final void Function(WallpaperSettings) onChanged;
  const _ColorStrip({required this.s, required this.surf, required this.rul,
    required this.ink, required this.mid, required this.onChanged});

  void _pick(BuildContext ctx, String label, Color cur,
      void Function(Color) cb) =>
      showModalBottomSheet(
        context: ctx, backgroundColor: surf,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _Picker(
            label: label, current: cur, surf: surf, ink: ink, onPick: cb),
      );

  @override
  Widget build(BuildContext ctx) {
    final items = [
      ('Past',   s.pastDotColor,    (c) => onChanged(s.copyWith(pastDotColor: c))),
      ('Today',  s.todayDotColor,   (c) => onChanged(s.copyWith(todayDotColor: c))),
      ('Future', s.futureDotColor,  (c) => onChanged(s.copyWith(futureDotColor: c))),
      ('BG',     s.backgroundColor, (c) => onChanged(s.copyWith(backgroundColor: c))),
    ];
    return Row(
      children: items.map((item) {
        final (lbl, col, cb) = item;
        return Expanded(
          child: GestureDetector(
            onTap: () => _pick(ctx, lbl, col, cb),
            child: Column(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: col,
                  border: Border.all(color: rul),
                  borderRadius: BorderRadius.circular(4),
                )),
              const SizedBox(height: 7),
              Text(lbl, style: TextStyle(color: mid, fontSize: 9,
                  fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _Picker extends StatelessWidget {
  final String label; final Color current, surf, ink;
  final void Function(Color) onPick;
  const _Picker({required this.label, required this.current,
    required this.surf, required this.ink, required this.onPick});

  static const _sw = [
    Color(0xFFFAF8F4), Color(0xFF1C1814), Color(0xFFF5F0E8),
    Color(0xFFCC2200), Color(0xFF0D0D0B), Color(0xFFE0DAD0),
    Color(0xFF9B8FFF), Color(0xFF00D470), Color(0xFFFFCC44),
    Color(0xFF38B6FF), Color(0xFFFF88CC), Color(0xFFFFD700),
    Color(0xFF282420), Color(0xFFE8D5C4), Color(0xFF8B7355),
    Color(0xFFFF6B35), Color(0xFFA0A09A), Color(0xFFC8B89A),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 36, height: 2, color: Colors.black12),
      const SizedBox(height: 22),
      Align(alignment: Alignment.centerLeft,
        child: Text(label, style: TextStyle(color: ink, fontSize: 22,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w800,
            letterSpacing: -0.5))),
      const SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12,
        children: _sw.map((c) {
          final sel = current.value == c.value;
          return GestureDetector(
            onTap: () { onPick(c); Navigator.pop(context); },
            child: Container(width: 44, height: 44,
              decoration: BoxDecoration(color: c,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: sel ? _red : Colors.black12,
                    width: sel ? 2.5 : 1))),
          );
        }).toList()),
    ]),
  );
}
