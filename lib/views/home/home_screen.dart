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
    final ok = await _vm.applyWallpaper();
    _vm.checkLive();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not apply wallpaper. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Apply Button ─────────────────────────────────────────────────
  Widget _applyBtn(double hPad) => Padding(
    padding: EdgeInsets.symmetric(horizontal: hPad),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
           
          ),
          child: GestureDetector(
            onTap: _vm.saving ? null : _apply,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: Center(
                child: _vm.saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MinimalIcon.upload(
                              size: 13,
                              color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 10),
                          Text(
                            'APPLY TO LOCK SCREEN',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  // ── Dynamic Header ────────────────────────────────────────────────
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.32),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          Text(
                  title.toUpperCase(), // Uppercase looks very minimal and clean
                  style: TextStyle(
                    // Removing fontFamily defaults to the clean system font (Roboto/SF Pro)
                    color: Colors.white.withOpacity(0.85), // Slightly dimmed for a "sober" look
                    fontSize: 13, // Smaller size
                    fontWeight: FontWeight.w600, // Medium weight, not too bold
                    letterSpacing: 2.5, // Wide, elegant spacing
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
    if (_vm.mode == CalendarMode.year ||
        _vm.mode == CalendarMode.settings ||
        _vm.mode == CalendarMode.weekly) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: _vm.mode == CalendarMode.goal
          ? GoalSetupSection(vm: _vm)
          : LifeSetupSection(vm: _vm),
    );
  }

  // ── Lockscreen Preview ────────────────────────────────────────────
  Widget _dotPreview(
      double hPad, double pw, double ph, double mockupScale) {
    final bgColor = _vm.bgColor;
    final bgImage = _vm.bgImagePath;
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        child: FadeTransition(
          opacity: _af,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(30 * mockupScale),
                  child: SizedBox(
                    width: pw,
                    height: ph,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (bgImage.isNotEmpty)
                          Image.file(File(bgImage), fit: BoxFit.cover)
                        else
                          Container(color: bgColor),
                        CustomPaint(
                          painter:
                              DotGridPainter(_vm.settings, repaint: _vm),
                          child: const SizedBox.expand(),
                        ),
                        Positioned(
                          top: 22 * mockupScale,
                          left: 20 * mockupScale,
                          right: 20 * mockupScale,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(now),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12 * mockupScale,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.signal_wifi_4_bar_rounded,
                                      color: Colors.white,
                                      size: 11 * mockupScale),
                                  SizedBox(width: 4 * mockupScale),
                                  Icon(Icons.battery_full_rounded,
                                      color: Colors.white,
                                      size: 11 * mockupScale),
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
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 18 * mockupScale,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                DateFormat('H:mm').format(now),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 78 * mockupScale,
                                  fontWeight: FontWeight.w200,
                                  letterSpacing: -3 * mockupScale,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    ? 13 * mockupScale
                                    : (_vm.labelFontSize * 0.8) *
                                        mockupScale,
                                fontFamily: 'Montserrat',
                                shadows: const [
                                  Shadow(
                                      blurRadius: 6,
                                      color: Colors.black38),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 38 * mockupScale,
                          left: 28 * mockupScale,
                          right: 28 * mockupScale,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _lockScreenIcon(
                                  Icons.mic_none_rounded, mockupScale),
                              _lockScreenIcon(
                                  Icons.camera_alt_outlined, mockupScale),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 10 * mockupScale,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 110 * mockupScale,
                              height: 4 * mockupScale,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        transitionDuration:
                            const Duration(milliseconds: 300),
                        pageBuilder: (_, __, ___) =>
                            FullScreenEditor(vm: _vm),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  },
                  child: Container(
                    width: pw,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MinimalIcon.expand(
                            size: 12,
                            color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 7),
                        Text(
                          'EDIT WALLPAPER',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
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
    padding: EdgeInsets.all(11 * scale),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.1),
      border:
          Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
    ),
    child: Icon(icon, color: Colors.white, size: 22 * scale),
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
              color: Colors.pinkAccent.withOpacity(0.2),
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

  Widget _calendarBody(
          double hPad, double pw, double ph, double mockupScale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        // ── KEY FIX: prevent the scaffold from resizing when keyboard appears.
        // The nav bar is in a Stack anchored to the bottom of the screen,
        // so with resizeToAvoidBottomInset: false it never moves.
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildBackground(context),

            // ── All content sits inside a MediaQuery that ignores viewInsets.
            // This means even if the keyboard is open, the content area does
            // not get squashed — text fields inside scroll views handle their
            // own scrollIntoView via ScrollController / Scrollable.ensureVisible.
            MediaQuery(
              data: mq.removeViewInsets(removeBottom: true),
              child: SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isSettings)
                      _settingsBody(hPad)
                    else
                      Column(
                        children: [
                          _dynamicHeader(hPad),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  top: 24, bottom: 120),
                              child: _calendarBody(
                                  hPad, pw, ph, mockupScale),
                            ),
                          ),
                        ],
                      ),

                    // ── Nav bar: Positioned inside SafeArea so it respects
                    // the home indicator / bottom notch, but is completely
                    // immune to keyboard because resizeToAvoidBottomInset=false.
                    Positioned(
                      left: navSideInset,
                      right: (navSideInset + 18),
                      bottom: 20,
                      child: FloatingNavBar(
                          mode: _vm.mode, onTap: _switchMode),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Minimal Icon Painters ─────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _MinimalIcon extends StatelessWidget {
  final _MinimalIconType _type;
  final double size;
  final Color color;

  const _MinimalIcon.upload({required this.size, required this.color})
      : _type = _MinimalIconType.upload;
  const _MinimalIcon.expand({required this.size, required this.color})
      : _type = _MinimalIconType.expand;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MinimalIconPainter(_type, color),
    );
  }
}

enum _MinimalIconType { upload, expand }

class _MinimalIconPainter extends CustomPainter {
  final _MinimalIconType type;
  final Color color;
  _MinimalIconPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (type == _MinimalIconType.upload) {
      canvas.drawLine(
          Offset(w / 2, h * 0.7), Offset(w / 2, h * 0.1), paint);
      canvas.drawLine(
          Offset(w * 0.25, h * 0.35), Offset(w / 2, h * 0.1), paint);
      canvas.drawLine(
          Offset(w * 0.75, h * 0.35), Offset(w / 2, h * 0.1), paint);
      canvas.drawLine(
          Offset(w * 0.1, h * 0.85), Offset(w * 0.9, h * 0.85), paint);
    } else if (type == _MinimalIconType.expand) {
      final s = w * 0.28;
      canvas.drawLine(Offset(0, s), Offset(0, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(s, 0), paint);
      canvas.drawLine(Offset(w - s, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, s), paint);
      canvas.drawLine(Offset(0, h - s), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(s, h), paint);
      canvas.drawLine(Offset(w - s, h), Offset(w, h), paint);
      canvas.drawLine(Offset(w, h), Offset(w, h - s), paint);
    }
  }

  @override
  bool shouldRepaint(_MinimalIconPainter old) => old.color != color;
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
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (vm.bgImagePath.isNotEmpty)
                Image.file(File(vm.bgImagePath), fit: BoxFit.cover)
              else
                Container(color: vm.bgColor),
              CustomPaint(
                painter: DotGridPainter(vm.settings, repaint: vm),
                child: const SizedBox.expand(),
              ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.signal_wifi_4_bar_rounded,
                            color: Colors.white, size: 15),
                        SizedBox(width: 5),
                        Icon(Icons.battery_full_rounded,
                            color: Colors.white, size: 15),
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
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 22,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      DateFormat('H:mm').format(now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 86,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (details) {
                  _baseScale = vm.gridScale;
                  _baseOffsetX = vm.offsetX;
                  _baseOffsetY = vm.offsetY;
                  _focalPoint = details.localFocalPoint;
                },
                onScaleUpdate: (details) {
                  vm.setGridScale(
                      (_baseScale * details.scale).clamp(0.2, 3.0));
                  final dx =
                      (details.localFocalPoint.dx - _focalPoint.dx) /
                          size.width;
                  final dy =
                      (details.localFocalPoint.dy - _focalPoint.dy) /
                          size.height;
                  vm.setOffsets(_baseOffsetX + dx, _baseOffsetY + dy);
                },
              ),
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Pinch to Zoom  ·  Drag to Pan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                      filter:
                          ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 38,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
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