import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Note: You can remove app_theme.dart if you no longer use kRed, kSurf, etc.
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

  // ── iOS Glass Bottom Sheet ────────────────────────────────────
  void _showApplySheet() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Ensures the glass blur shows through
    elevation: 0,
    builder: (_) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // iOS Drag Handle
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Apply to Lock Screen',
                style: TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w700, fontStyle: FontStyle.italic,
                    letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text(
                'Long-press home → Wallpapers → Live → DotZ → Apply',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.8)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100), // Pill button
                ),
                child: const Text('GOT IT',
                    style: TextStyle(
                        color: Colors.black, fontSize: 11,
                        fontWeight: FontWeight.w900, letterSpacing: 2.0)),
              ),
            ),
          ]),
        ),
      ),
    ),
  ).then((_) => _vm.checkLive());

  // ── Helpers ───────────────────────────────────────────────────
  // Note: Removed _hr() entirely to reduce gaps and keep the UI clean and floating.

  Widget _applyBtn() => GestureDetector(
    onTap: _vm.saving ? null : _apply,
    child: Container(
      width: double.infinity, height: 56,
      alignment: Alignment.center, 
      decoration: BoxDecoration(
        color: Colors.white, // Minimal B&W pill
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: _vm.saving
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.black))
          : const Text('APPLY TO LOCK SCREEN',
              style: TextStyle(
                  color: Colors.black, fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 2.0)),
    ),
  );

  Widget _topBar(double hPad) => Padding(
    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0), // Reduced bottom padding here to close the gap
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100), 
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), 
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25), 
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.15), 
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Minimal B&W App Icon
              Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black, 
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              const Text(
                'DotZ',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16,
                  fontStyle: FontStyle.italic, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              
              // Creative "Live" Status Widget
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _vm.live ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(_vm.live ? 0.3 : 0.05),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: _vm.live ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                        border: _vm.live 
                            ? null 
                            : Border.all(color: Colors.white.withOpacity(0.3), width: 1), 
                        boxShadow: _vm.live ? [
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 6, 
                            spreadRadius: 1,
                          )
                        ] : [],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _vm.live ? 'LIVE' : 'IDLE',
                      style: TextStyle(
                        color: _vm.live ? Colors.white : Colors.white.withOpacity(0.5), 
                        fontSize: 9, 
                        fontWeight: FontWeight.w800, 
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _modeSetup(double hPad) {
    if (_vm.mode == CalendarMode.year) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: _vm.mode == CalendarMode.goal
          ? GoalSetupSection(vm: _vm)
          : LifeSetupSection(vm: _vm),
    );
  }

  // ── Custom Gradient Background ────────────────────────────────
  Widget _buildFusionBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned(
          top: -150, right: -100,
          child: Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.deepPurpleAccent.withOpacity(0.6)),
          ),
        ),
        Positioned(
          bottom: -150, left: -100,
          child: Container(
            width: 450, height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.4)),
          ),
        ),
        Positioned(
          top: size.height * 0.3, left: size.width * 0.2,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.pinkAccent.withOpacity(0.3)),
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
      HeroSection(
        tag: _vm.heroTag, bigNum: _vm.heroBigNum,
        title: _vm.heroTitle, statA: _vm.heroStatA,
        statB: _vm.heroStatB, hPad: hPad, fade: _af,
      ),
      // GAP REDUCTION: Removed all _hr() dividers here.
      _modeSetup(hPad),
      const SizedBox(height: 8), // Small buffer instead of lines
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: FadeTransition(
          opacity: _af,
          child: Container(
            width: double.infinity, height: ph,
            // Match the Calendar perfectly to the Hero card
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: DotGridWallpaper(settings: _vm.settings),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: ControlsSection(vm: _vm),
      ),
      const SizedBox(height: 32),
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
      HeroSection(
        tag: _vm.heroTag, bigNum: _vm.heroBigNum,
        title: _vm.heroTitle, statA: _vm.heroStatA,
        statB: _vm.heroStatB, hPad: hPad, fade: _af,
      ),
      _modeSetup(hPad),
      const SizedBox(height: 8),
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
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: DotGridWallpaper(settings: _vm.settings),
                  ),
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
                    right: 89, 
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