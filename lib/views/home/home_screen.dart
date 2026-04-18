import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dotz/views/setting/setting_page.dart';
import '../../models/wallpaper_settings.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/dot_grid_widget.dart';
import '../widgets/floating_nav_bar.dart';
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
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
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
    _vm.checkLive();
  }

  Widget _applyBtn(double hPad) => Padding(
    padding: EdgeInsets.symmetric(horizontal: hPad),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.0,
            ),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'APPLY TO LOCK SCREEN',
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _dynamicHeader(double hPad) {
    String title = '';
    switch (_vm.mode) {
      case CalendarMode.year:
        title = 'Yearly Calendar';
        break;
      case CalendarMode.weekly:
        title = 'Monthly Calendar';
        break;
      case CalendarMode.life:
        title = 'Life Calendar';
        break;
      case CalendarMode.goal:
        title = 'Goal Calendar';
        break;
      default:
        title = 'Calendar';
    }

    return Padding(
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
              // ── NEW: Centers the text in the glass card ──
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Glass Antiqua',
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeSetup(double hPad) {
    if (_vm.mode == CalendarMode.year || _vm.mode == CalendarMode.settings || _vm.mode == CalendarMode.weekly) {
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
  Widget _dotPreview(double hPad, double pw, double ph, double mockupScale) {
    final bgColor = _vm.bgColor;
    final bgImage = _vm.bgImagePath;
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        child: FadeTransition(
          opacity: _af,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── THE PHONE MOCKUP ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(32 * mockupScale),
                  child: SizedBox(
                    width: pw,
                    height: ph,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Background
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
                          top: 24 * mockupScale,
                          left: 24 * mockupScale,
                          right: 24 * mockupScale,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(now),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14 * mockupScale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.wifi,
                                    color: Colors.white,
                                    size: 14 * mockupScale,
                                  ),
                                  SizedBox(width: 6 * mockupScale),
                                  Icon(
                                    Icons.battery_full,
                                    color: Colors.white,
                                    size: 14 * mockupScale,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 4. Center Clock
                        Align(
                          alignment: const Alignment(0, -0.60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('EEEE').format(now),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 20 * mockupScale,
                                  fontFamily: 'Glass Antiqua',
                                ),
                              ),
                              Text(
                                DateFormat('H:mm').format(now),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 80 * mockupScale,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -2 * mockupScale,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 5. Progress Label
                        if (_vm.showLabel)
                          Positioned(
                            bottom: 100 * mockupScale,
                            left: 20,
                            right: 20,
                            child: Text(
                              _vm.resolvedLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _vm.labelColor,
                                fontSize: _vm.labelFontSize == 0
                                    ? 14 * mockupScale
                                    : (_vm.labelFontSize * 0.8) * mockupScale,
                                fontFamily: 'Glass Antiqua',
                                shadows: const [
                                  Shadow(blurRadius: 4, color: Colors.black45),
                                ],
                              ),
                            ),
                          ),

                        // 6. Bottom Lockscreen Icons
                        Positioned(
                          bottom: 40 * mockupScale,
                          left: 30 * mockupScale,
                          right: 30 * mockupScale,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _lockScreenIcon(Icons.assistant, mockupScale),
                              _lockScreenIcon(Icons.camera_alt, mockupScale),
                            ],
                          ),
                        ),

                        // 7. Gesture Navigation Pill
                        Positioned(
                          bottom: 12 * mockupScale,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 120 * mockupScale,
                              height: 5 * mockupScale,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4 * mockupScale),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── EDIT BUTTON ──
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) => FullScreenEditor(vm: _vm),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  },
                  child: Container(
                    width: pw,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.zoom_out_map,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EDIT WALLPAPER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lockScreenIcon(IconData icon, double scale) => Container(
    padding: EdgeInsets.all(12 * scale),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withOpacity(0.3),
    ),
    child: Icon(icon, color: Colors.white, size: 24 * scale),
  );

  Widget _buildBackground(BuildContext context) {
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
              color: Colors.deepPurpleAccent.withOpacity(0.5),
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
              color: Colors.blueAccent.withOpacity(0.35),
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
              color: Colors.pinkAccent.withOpacity(0.25),
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

  Widget _settingsBody(double hPad) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Expanded(child: SettingsPage(vm: _vm)),
    ],
  );

  Widget _calendarBody(double hPad, double pw, double ph, double mockupScale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER REMOVED FROM HERE (Moved to fixed position in build method) ──
          _dotPreview(hPad, pw, ph, mockupScale),
          const SizedBox(height: 24),
          _modeSetup(hPad),
          const SizedBox(height: 24),
          _applyBtn(hPad),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    final hPad = sw >= 900 ? 48.0 : sw >= 600 ? 32.0 : 20.0;
    
    final pw = (sw * 0.50).clamp(160.0, 400.0);

    final deviceRatio = sh / sw;
    final mockupScale = pw / sw;

    final ph = pw * deviceRatio;

    final isSettings = _vm.mode == CalendarMode.settings;
    final navSideInset = sw >= 900 ? sw * 0.3 : sw >= 600 ? sw * 0.2 : 80.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(context),
            SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isSettings)
                    _settingsBody(hPad)
                  else
                    // ── NEW: FIXED HEADER LAYOUT ──
                    Column(
                      children: [
                        _dynamicHeader(hPad), // Remains pinned at the top
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            // Added top padding to push the preview down slightly below the fixed header
                            padding: const EdgeInsets.only(top: 24, bottom: 120),
                            child: _calendarBody(hPad, pw, ph, mockupScale), // Everything else scrolls
                          ),
                        ),
                      ],
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── FULL SCREEN WALLPAPER EDITOR ─────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class FullScreenEditor extends StatefulWidget {
  final HomeViewModel vm;
  const FullScreenEditor({super.key, required this.vm});

  @override
  State<FullScreenEditor> createState() => _FullScreenEditorState();
}

class _FullScreenEditorState extends State<FullScreenEditor> {
  double _baseScale = 1.0;
  double _baseOffsetX = 0.0;
  double _baseOffsetY = 0.0;
  Offset _focalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final size = MediaQuery.of(context).size;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Fullscreen Background
              if (vm.bgImagePath.isNotEmpty)
                Image.file(File(vm.bgImagePath), fit: BoxFit.cover)
              else
                Container(color: vm.bgColor),

              // 2. Fullscreen Dots Painter
              CustomPaint(
                painter: DotGridPainter(vm.settings, repaint: vm),
                child: const SizedBox.expand(),
              ),

              // 3. UI Overlay (True 1:1 Scale Clock & Status Bar)
              Positioned(
                top: 54,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.wifi, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Icon(Icons.battery_full, color: Colors.white, size: 16),
                      ],
                    ),
                  ],
                ),
              ),

              Align(
                alignment: const Alignment(0, -0.60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE').format(now),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 22,
                        fontFamily: 'Glass Antiqua',
                      ),
                    ),
                    Text(
                      DateFormat('H:mm').format(now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 86,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Immersive Gesture Detector (Pan & Zoom)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (details) {
                  _baseScale = vm.gridScale;
                  _baseOffsetX = vm.offsetX;
                  _baseOffsetY = vm.offsetY;
                  _focalPoint = details.localFocalPoint;
                },
                onScaleUpdate: (details) {
                  vm.setGridScale((_baseScale * details.scale).clamp(0.2, 3.0));
                  final dx = (details.localFocalPoint.dx - _focalPoint.dx) / size.width;
                  final dy = (details.localFocalPoint.dy - _focalPoint.dy) / size.height;
                  vm.setOffsets(_baseOffsetX + dx, _baseOffsetY + dy);
                },
              ),

              // 5. Instruction HUD
              Positioned(
                top: 130,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'Pinch to Zoom • Drag to Pan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 6. Reset Button (Bottom Left)
              Positioned(
                bottom: 40,
                left: 24,
                child: GestureDetector(
                  onTap: () {
                    vm.setGridScale(1.0);
                    vm.setOffsets(0.0, 0.0);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 7. Done Button (Bottom Right)
              Positioned(
                bottom: 40,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontFamily: 'Glass Antiqua',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}