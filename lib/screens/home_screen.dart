import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallpaper_settings.dart';
import '../widgets/dot_grid_widget.dart';
import 'customize_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _channel = MethodChannel('com.example.dotz/wallpaper');

  WallpaperSettings _settings = WallpaperSettings();
  bool _isSaving = false;
  bool _isLiveActive = false;

  @override
  void initState() {
    super.initState();
    _checkLiveWallpaper();
  }

  Future<void> _checkLiveWallpaper() async {
    try {
      final active = await _channel.invokeMethod<bool>('isLiveWallpaperActive') ?? false;
      setState(() => _isLiveActive = active);
    } catch (_) {}
  }

  int _colorToAndroid(Color c) =>
      (c.alpha << 24) | (c.red << 16) | (c.green << 8) | c.blue;

  Future<void> _saveAndOpen() async {
    setState(() => _isSaving = true);
    try {
      // Save settings first so live wallpaper reads them
      await _channel.invokeMethod('saveSettings', {
        'bgColor':     _colorToAndroid(_settings.backgroundColor),
        'pastColor':   _colorToAndroid(_settings.pastDotColor),
        'futureColor': _colorToAndroid(_settings.futureDotColor),
        'todayColor':  _colorToAndroid(_settings.todayDotColor),
        'columns':     _settings.columns,
        'showLabel':   _settings.showProgressLabel,
      });

      // Try to open picker
      await _channel.invokeMethod('openWallpaperPicker');

      // Show OnePlus instructions
      if (mounted) _showInstructions();
    } on PlatformException catch (e) {
      if (mounted) _showInstructions(); // show manual steps anyway
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: _settings.todayDotColor.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: Icon(Icons.info_outline_rounded,
                    color: _settings.todayDotColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('How to set Dotz as Live Wallpaper',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 20),

            // Steps
            _Step('1', 'Go to your phone\'s\nSettings → Wallpaper',
                Icons.settings_rounded, _settings.todayDotColor),
            const SizedBox(height: 12),
            _Step('2', 'Tap "Lock screen" or "Wallpaper & Style"',
                Icons.lock_rounded, _settings.pastDotColor),
            const SizedBox(height: 12),
            _Step('3', 'Tap "Live Wallpapers" or the Live tab',
                Icons.play_circle_outline_rounded, _settings.todayDotColor),
            const SizedBox(height: 12),
            _Step('4', 'Find "Dotz" in the list and tap it',
                Icons.grid_view_rounded, _settings.pastDotColor),
            const SizedBox(height: 12),
            _Step('5', 'Tap "Apply" → choose Lock Screen',
                Icons.check_circle_outline_rounded, Colors.greenAccent),

            const SizedBox(height: 20),

            // OnePlus specific note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android_rounded,
                      color: Colors.amber, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'On OnePlus/ColorOS: Long-press home screen → Wallpapers → Live → Dotz',
                      style: TextStyle(
                          color: Colors.amber.shade200,
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _settings.todayDotColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Got it!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => _checkLiveWallpaper());
  }

  void _openCustomize() async {
    final updated = await Navigator.push<WallpaperSettings>(
      context,
      MaterialPageRoute(builder: (_) => CustomizeScreen(settings: _settings)),
    );
    if (updated != null) {
      setState(() => _settings = updated);
      // Auto-save settings so live wallpaper updates immediately
      _channel.invokeMethod('saveSettings', {
        'bgColor':     _colorToAndroid(_settings.backgroundColor),
        'pastColor':   _colorToAndroid(_settings.pastDotColor),
        'futureColor': _colorToAndroid(_settings.futureDotColor),
        'todayColor':  _colorToAndroid(_settings.todayDotColor),
        'columns':     _settings.columns,
        'showLabel':   _settings.showProgressLabel,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size      = MediaQuery.of(context).size;
    final dayOfYear = WallpaperSettings.dayOfYear;
    final totalDays = WallpaperSettings.daysInYear;
    final daysLeft  = totalDays - dayOfYear;
    final progress  = WallpaperSettings.yearProgress;
    final previewH  = ((size.width - 48) * 2.1).clamp(0.0, size.height * 0.56);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(children: [

          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DOTZ',
                      style: TextStyle(
                          color: Colors.white, fontSize: 26,
                          fontWeight: FontWeight.w900, letterSpacing: 6)),
                  Text('life calendar',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.28),
                          fontSize: 11, letterSpacing: 2.5,
                          fontWeight: FontWeight.w300)),
                ],
              ),
              const Spacer(),
              // Active badge
              if (_isLiveActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.35)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.fiber_manual_record,
                        color: Colors.greenAccent, size: 8),
                    SizedBox(width: 5),
                    Text('LIVE ACTIVE',
                        style: TextStyle(
                            color: Colors.greenAccent, fontSize: 11,
                            fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ]),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.fiber_manual_record,
                        color: Colors.redAccent, size: 8),
                    SizedBox(width: 5),
                    Text('NOT SET',
                        style: TextStyle(
                            color: Colors.redAccent, fontSize: 11,
                            fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ]),
                ),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Preview ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: _openCustomize,
              child: Container(
                height: previewH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: _settings.todayDotColor.withOpacity(0.2),
                      blurRadius: 40, spreadRadius: -4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: DotGridWallpaper(settings: _settings),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              _Stat('Day $dayOfYear', 'of $totalDays', _settings.todayDotColor),
              const SizedBox(width: 10),
              _Stat('${(progress * 100).toStringAsFixed(1)}%', 'complete',
                  _settings.pastDotColor),
              const SizedBox(width: 10),
              _Stat('$daysLeft', 'days left',
                  _settings.futureDotColor.withOpacity(0.8)),
            ]),
          ),

          const SizedBox(height: 14),

          // ── Buttons ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _openCustomize,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Row(children: [
                    Icon(Icons.tune_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('Customize'),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAndOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _settings.todayDotColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wallpaper_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Set Live Wallpaper',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ],
                          ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Step widget ──────────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  final String number, text;
  final IconData icon;
  final Color color;
  const _Step(this.number, this.text, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Center(
          child: Text(number,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.4)),
        ),
      ),
    ],
  );
}

// ── Stat widget ──────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String value, label;
  final Color accent;
  const _Stat(this.value, this.label, this.accent);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: accent, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white24, fontSize: 10, letterSpacing: 0.5)),
      ]),
    ),
  );
}
