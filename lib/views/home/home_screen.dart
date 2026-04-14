import 'dart:ui';
import 'package:dotz/views/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/wallpaper_settings.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/dot_grid_widget.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/goal_setup_section.dart';
import '../widgets/life_setup_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeViewModel _vm = HomeViewModel();
  late AnimationController _ac;
  late Animation<double>   _af;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 340));
    _af = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();
    _vm.checkLive();
    _vm.addListener(_onVmChange);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    _ac.dispose();
    super.dispose();
  }

  void _onVmChange() => setState(() {});

  void _switchMode(CalendarMode m) {
    _ac.reset();
    _vm.setMode(m);
    _ac.forward();
  }

  Future<void> _apply() async {
    await _vm.applyWallpaper();
    if (mounted) _showApplySheet();
  }

  void _showApplySheet() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2936), // Updated to match settings UI card
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.12), width: 0.5),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 32),
            const Text('Apply to Lock Screen',
              style: TextStyle(
                fontFamily: 'Glass Antiqua', // Font applied
                color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text(
              'Long-press home → Wallpapers → Live → DotZ → Apply',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Glass Antiqua', // Font applied
                color: Colors.white.withOpacity(0.55),
                fontSize: 13, height: 1.8)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100)),
                child: const Text('GOT IT',
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.black, fontSize: 14, // Adjusted slightly for font
                    fontWeight: FontWeight.w900, letterSpacing: 2.0)),
              ),
            ),
          ]),
        ),
      ),
    ),
  ).then((_) => _vm.checkLive());

  // ── Apply button — solid white, no glass ──────────────────────
  Widget _applyBtn(double hPad) => Padding(
    padding: EdgeInsets.symmetric(horizontal: hPad),
    child: GestureDetector(
      onTap: _vm.saving ? null : _apply,
      child: Container(
        width: double.infinity, height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: _vm.saving
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.black))
            : const Text('APPLY TO LOCK SCREEN',
                style: TextStyle(
                  fontFamily: 'Glass Antiqua', // Font applied
                  color: Colors.black, fontSize: 13, // Adjusted slightly for font
                  fontWeight: FontWeight.w900, letterSpacing: 2.0)),
      ),
    ),
  );

  // ── Top bar — solid dark, no glass ───────────────────────────
Widget _topBar(double hPad) => Padding(
    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Slightly roomier padding
      decoration: BoxDecoration(
        color: const Color(0xFF2C2936), // Updated to match the new dark card theme
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1), // Softer border
      ),
      child: Row(
        children: [      
          const SizedBox(width: 8),
          Center(
            child: const Text('DotZ',
              style: TextStyle(
                fontFamily: 'Glass Antiqua', // Font applied
                color: Colors.white, 
                fontSize: 20, // Bumped slightly for the custom font
                fontStyle: FontStyle.italic, 
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
          ),
        
        ],
      ),
    ),
  );

  Widget _modeSetup(double hPad) {
    if (_vm.mode == CalendarMode.year || _vm.mode == CalendarMode.settings) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: _vm.mode == CalendarMode.goal
          ? GoalSetupSection(vm: _vm)
          : LifeSetupSection(vm: _vm),
    );
  }

  Widget _dotPreview(double hPad, double ph) {
    final bgColor = _vm.bgColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: FadeTransition(
        opacity: _af,
        child: Container(
          width: double.infinity,
          height: ph,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(children: [
              Container(color: bgColor),
              CustomPaint(
                painter: DotGridPainter(_vm.settings),
                child: const SizedBox.expand()),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(children: [
      Container(color: Colors.black),
      Positioned(
        top: -150, right: -100,
        child: Container(
          width: 400, height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepPurpleAccent.withOpacity(0.5)),
        ),
      ),
      Positioned(
        bottom: -150, left: -100,
        child: Container(
          width: 450, height: 450,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent.withOpacity(0.35)),
        ),
      ),
      Positioned(
        top: size.height * 0.3, left: size.width * 0.2,
        child: Container(
          width: 300, height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.pinkAccent.withOpacity(0.25)),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent)),
      ),
    ]);
  }

  // ── Settings body ──────────────────────────────────────────────
  Widget _settingsBody(double hPad) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24), // Topbar removed completely
      SettingsPage(vm: _vm),
    ],
  );

  // ── Calendar body ──────────────────────────────────────────────
  Widget _calendarBody(double hPad, double ph) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Top bar ONLY shows on the main Year page now
      if (_vm.mode == CalendarMode.year) _topBar(hPad),
      if (_vm.mode != CalendarMode.year) const SizedBox(height: 24), 

      HeroSection(
        tag: _vm.heroTag, bigNum: _vm.heroBigNum,
        title: _vm.heroTitle, statA: _vm.heroStatA,
        statB: _vm.heroStatB, hPad: hPad, fade: _af,
      ),
      Transform.translate(
        offset: const Offset(0, -16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _modeSetup(hPad),
            if (_vm.mode != CalendarMode.year) const SizedBox(height: 4),
            _dotPreview(hPad, ph),
            const SizedBox(height: 20),
            _applyBtn(hPad),
          ],
        ),
      ),
    ],
  );

 @override
  Widget build(BuildContext context) {
    final mq   = MediaQuery.of(context);
    final sw   = mq.size.width;
    final sh   = mq.size.height;

    // Responsive padding
    final hPad = sw >= 900
        ? 48.0
        : sw >= 600
            ? 32.0
            : 20.0;

    final pw = sw - hPad * 2;
    // Tablet: cap preview height so it doesn't dominate
    final ph = sw >= 700
        ? (pw * 0.55).clamp(240.0, sh * 0.45)
        : (pw * 19 / 9).clamp(220.0, sh * 0.48);

    final isSettings = _vm.mode == CalendarMode.settings;

    // Responsive navbar position
    final navSideInset = sw >= 900 ? sw * 0.3 : sw >= 600 ? sw * 0.2 : 80.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          _buildBackground(context),
          SafeArea(
            child: Stack(
              // ── THE FIX ──
              // Forces the Stack to take up the full screen height even if 
              // the settings content is very short. This keeps the navbar pinned!
              fit: StackFit.expand, 
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  child: isSettings
                      ? _settingsBody(hPad)
                      : _calendarBody(hPad, ph),
                ),
                // Glass navbar - Positioning absolutely untouched
                Positioned(
                  left: navSideInset,
                  right: (navSideInset+18),
                  bottom: 20,
                  child: FloatingNavBar(mode: _vm.mode, onTap: _switchMode),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
