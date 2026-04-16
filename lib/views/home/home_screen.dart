import 'dart:io';
import 'dart:ui';
import 'package:dotz/views/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Add to pubspec for the date formatting
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
  late Animation<double> _af;

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
                color: Colors.black.withOpacity(0.5),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withOpacity(0.12), width: 0.5),
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Apply to Lock Screen',
                  style: TextStyle(
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Long-press home → Wallpapers → Live → DotZ → Apply',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      height: 1.8),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: Center(
                            child: Text(
                              'GOT IT',
                              style: TextStyle(
                                  fontFamily: 'Glass Antiqua',
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ).then((_) => _vm.checkLive());

  Widget _applyBtn(double hPad) => Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(100),
              ),
              child: GestureDetector(
                onTap: _vm.saving ? null : _apply,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Center(
                    child: _vm.saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Text(
                            'APPLY TO LOCK SCREEN',
                            style: TextStyle(
                                fontFamily: 'Glass Antiqua',
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _topBar(double hPad) => Padding(
        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Text(
                    'DotZ',
                    style: TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5),
                  ),
                ],
              ),
            ),
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

  // ── Simulated Lockscreen Preview ────────────────────────────────
  Widget _dotPreview(double hPad, double ph) {
    final bgColor = _vm.bgColor;
    final bgImage = _vm.bgImagePath;
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: FadeTransition(
        opacity: _af,
        child: Container(
          // Glass card spacing: The card itself
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: double.infinity,
              height: ph,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background (Image or Solid)
                  if (bgImage.isNotEmpty)
                    Image.file(File(bgImage), fit: BoxFit.cover)
                  else
                    Container(color: bgColor),

                  // 2. Dots Painter Layer
                  CustomPaint(
                    painter: DotGridPainter(_vm.settings, repaint: _vm),
                    child: const SizedBox.expand(),
                  ),

                  // 3. Status Bar Simulation
                  Positioned(
                    top: 12, left: 16, right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('HH:mm').format(now), 
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            const Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            const Icon(Icons.wifi, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            const Icon(Icons.battery_full, color: Colors.white, size: 12),
                          ],
                        )
                      ],
                    ),
                  ),

                  // 4. Center Clock Simulation
                  Align(
                    alignment: const Alignment(0, -0.65),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEEE').format(now),
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: 'Glass Antiqua')),
                        Text(DateFormat('H:mm').format(now),
                            style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w300, letterSpacing: -2)),
                      ],
                    ),
                  ),

                  // 5. Progress Label / Quote Simulation (Positioned above bottom icons)
                  if (_vm.showLabel)
                    Positioned(
                      bottom: 80, left: 20, right: 20,
                      child: Text(
                        _vm.resolvedLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _vm.labelColor,
                          fontSize: _vm.labelFontSize == 0 ? 13 : _vm.labelFontSize * 0.8,
                          fontFamily: 'Glass Antiqua',
                          shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
                        ),
                      ),
                    ),

                  // 6. Bottom Lockscreen Icons
                  Positioned(
                    bottom: 20, left: 20, right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _lockScreenIcon(Icons.assistant),
                        _lockScreenIcon(Icons.camera_alt),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lockScreenIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
    child: Icon(icon, color: Colors.white, size: 20),
  );

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

  Widget _settingsBody(double hPad) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Expanded(child: SettingsPage(vm: _vm)),
        ],
      );

  Widget _calendarBody(double hPad, double ph) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_vm.mode == CalendarMode.year) _topBar(hPad),
          if (_vm.mode != CalendarMode.year) const SizedBox(height: 24),
          HeroSection(
            tag: _vm.heroTag,
            bigNum: _vm.heroBigNum,
            title: _vm.heroTitle,
            statA: _vm.heroStatA,
            statB: _vm.heroStatB,
            hPad: hPad,
            fade: _af,
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
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    final hPad = sw >= 900 ? 48.0 : sw >= 600 ? 32.0 : 20.0;
    final pw = sw - hPad * 2;
    final ph = sw >= 700
        ? (pw * 0.55).clamp(240.0, sh * 0.45)
        : (pw * 19 / 9).clamp(220.0, sh * 0.48);

    final isSettings = _vm.mode == CalendarMode.settings;
    final navSideInset = sw >= 900 ? sw * 0.3 : sw >= 600 ? sw * 0.2 : 80.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          _buildBackground(context),
          SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isSettings)
                  _settingsBody(hPad)
                else
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120),
                    child: _calendarBody(hPad, ph),
                  ),
                Positioned(
                  left: navSideInset,
                  right: (navSideInset + 18),
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