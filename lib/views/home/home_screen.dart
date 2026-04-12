import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../models/wallpaper_settings.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/dot_grid_widget.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/goal_setup_section.dart';
import '../widgets/life_setup_section.dart';
import '../widgets/controls_section.dart';

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
    backgroundColor: kSurf,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 1, color: kRule),
        const SizedBox(height: 28),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Apply to Lock Screen',
              style: TextStyle(
                  color: kInk, fontSize: 22,
                  fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                  letterSpacing: -0.5)),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
              'Long-press home → Wallpapers → Live → DotZ → Apply',
              style: TextStyle(color: kMid, fontSize: 13, height: 1.8)),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity, height: 52,
            alignment: Alignment.center, color: kRed,
            child: const Text('GOT IT',
                style: TextStyle(
                    color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 2.5)),
          ),
        ),
      ]),
    ),
  ).then((_) => _vm.checkLive());

  // ── Helpers ───────────────────────────────────────────────────
  Widget _hr() => Container(height: 1, color: Colors.white.withOpacity(0.1)); 

  Widget _applyBtn() => GestureDetector(
    onTap: _vm.saving ? null : _apply,
    child: Container(
      width: double.infinity, height: 52,
      alignment: Alignment.center, color: kRed,
      child: _vm.saving
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
          : const Text('APPLY TO LOCK SCREEN',
              style: TextStyle(
                  color: Colors.white, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 2.5)),
    ),
  );

  Widget _topBar(double hPad) => Padding(
    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 18),
    child: Row(children: [
      Container(
        width: 26, height: 26,
        decoration: const BoxDecoration(
            color: kOrange, shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
                color: Color(0xFFFFF5EC), shape: BoxShape.circle),
          ),
        ),
      ),
      const SizedBox(width: 10),
      const Text('DotZ',
          style: TextStyle(
              color: Colors.white, 
              fontSize: 17,
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
              letterSpacing: -0.5)),
      const Spacer(),
      Text(
        _vm.live ? 'live' : 'not live',
        style: TextStyle(
            color: _vm.live ? kOrange : Colors.white70, 
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.8),
      ),
    ]),
  );

  Widget _modeSetup(double hPad) {
    if (_vm.mode == CalendarMode.year) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: _vm.mode == CalendarMode.goal
            ? GoalSetupSection(vm: _vm)
            : LifeSetupSection(vm: _vm),
      ),
      _hr(),
    ]);
  }

  // ── Custom Gradient Background ────────────────────────────────
  Widget _buildFusionBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        Container(color: Colors.black),
        
        Positioned(
          top: -150,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent.withOpacity(0.6),
            ),
          ),
        ),
        
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.4),
            ),
          ),
        ),

        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.2,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pinkAccent.withOpacity(0.3),
            ),
          ),
        ),

        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  // ── Body builders ─────────────────────────────────────────────
  Widget _stackBody(double hPad, double ph) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _topBar(hPad),
      _hr(),
      HeroSection(
        tag: _vm.heroTag, bigNum: _vm.heroBigNum,
        title: _vm.heroTitle, statA: _vm.heroStatA,
        statB: _vm.heroStatB, hPad: hPad, fade: _af,
      ),
      _hr(),
      _modeSetup(hPad),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: FadeTransition(
          opacity: _af,
          child: Container(
            width: double.infinity, height: ph,
            foregroundDecoration:
                BoxDecoration(border: Border.all(color: Colors.white24)), 
            child: DotGridWallpaper(settings: _vm.settings),
          ),
        ),
      ),
      _hr(),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: ControlsSection(vm: _vm),
      ),
      _hr(),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
        child: _applyBtn(),
      ),
    ],
  );

  Widget _wideBody(double hPad, double ph) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _topBar(hPad),
      _hr(),
      HeroSection(
        tag: _vm.heroTag, bigNum: _vm.heroBigNum,
        title: _vm.heroTitle, statA: _vm.heroStatA,
        statB: _vm.heroStatB, hPad: hPad, fade: _af,
      ),
      _hr(),
      _modeSetup(hPad),
      Padding(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: FadeTransition(
                opacity: _af,
                child: Container(
                  height: ph,
                  foregroundDecoration:
                      BoxDecoration(border: Border.all(color: Colors.white24)),
                  child: DotGridWallpaper(settings: _vm.settings),
                ),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ControlsSection(vm: _vm),
                  const SizedBox(height: 28),
                  _applyBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 48),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final mq    = MediaQuery.of(context);
    final sw    = mq.size.width;
    final sh    = mq.size.height;
    final isWide = sw >= 900.0;
    final hPad   = sw >= 600.0 ? 32.0 : 20.0;
    final pw     = sw - hPad * 2;
    final ph     = (pw * 19 / 9).clamp(220.0, sh * 0.50);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        body: Stack(
          children: [
            _buildFusionBackground(context),
            SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120), 
                    child: isWide
                        ? _wideBody(hPad, ph)
                        : _stackBody(hPad, ph),
                  ),
                  Positioned(
                    left: 80, 
                    right: 80, 
                    bottom: 20,
                    child: FloatingNavBar(
                        mode: _vm.mode, onTap: _switchMode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}