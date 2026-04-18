import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingKey = 'dotz_onboarding_complete';

  static Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_onboardingKey) ?? false);
    } catch (_) {
      return true;
    }
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  Future<void> _complete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OnboardingScreen._onboardingKey, true);
    } catch (_) {
      // Proceed to home even if prefs write fails
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  static const _pages = [
    _OnboardPage(
      svgPath: 'assets/splash1.svg',
      title: 'Reimagine life in\nYears.',
      subtitle: 'Watch your year unfold, dot by dot. Every single day matters.',
    ),
    _OnboardPage(
      svgPath: 'assets/splash3.svg',
      title: 'Reimagine life in\nMonths.',
      subtitle:
          'Track your progress with a clean, beautifully organized 12-month grid layout.',
    ),
    _OnboardPage(
      svgPath: 'assets/splash2.svg',
      title: 'Set a\nGoal.',
      subtitle:
          'Count down to what matters most. See exactly how much time you have left.',
    ),
    _OnboardPage(
      svgPath: 'assets/splash4.svg',
      title: 'Reimagine your\nLife.',
      subtitle:
          'See your entire life in a single glance. Make every dot count.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ── Responsive breakpoints ───────────────────────────────────
    // isTablet: width >= 600 (covers iPad mini, iPad, tablets)
    // isLargePhone: width >= 390 (iPhone Pro Max, large Androids)
    final double screenW = size.width;
    final bool isTablet = screenW >= 600;
    final bool isLargePhone = screenW >= 390 && !isTablet;

    // Bottom padding for CTA button area
    final double bottomPad = isTablet ? 56 : 36;
    // Dots indicator bottom spacing
    final double dotsBottomGap = isTablet ? 32 : 20;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          _OnboardBackground(size: size),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Pages
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: _pages.length,
                        itemBuilder: (_, i) => _OnboardPageView(
                          page: _pages[i],
                          isTablet: isTablet,
                          isLargePhone: isLargePhone,
                        ),
                      ),
                    ),

                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: dotsBottomGap),

                    // ── GLASS CTA BUTTON ─────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 80 : 24,
                      ),
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 18.0,
                              sigmaY: 18.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: isTablet ? 64 : 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(100),
                               
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'GET STARTED'
                                    : 'NEXT',
                                style: TextStyle(
                                  fontFamily: 'Glass Antiqua',
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: bottomPad),
                  ],
                ),
              ),
            ),
          ),

          // ── SKIP BUTTON (Top Right) ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: AnimatedOpacity(
              opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  if (_currentPage < _pages.length - 1) _complete();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class for each onboard page ──────────────────────────────
class _OnboardPage {
  final String svgPath;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.svgPath,
    required this.title,
    required this.subtitle,
  });
}

// ── Single page view ──────────────────────────────────────────────
class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  final bool isTablet;
  final bool isLargePhone;

  const _OnboardPageView({
    required this.page,
    required this.isTablet,
    required this.isLargePhone,
  });

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;

    // ── Responsive values ──────────────────────────────────────
    // SVG size: tablet → 300, large phone → 240, small phone → 200
    final double svgSize = isTablet
        ? 300
        : isLargePhone
            ? 240
            : 200;

    // Gap between SVG and title text: tightened significantly
    // Uses a fraction of screen height to stay proportional
    final double svgToTextGap = isTablet
        ? screenH * 0.06
        : screenH * 0.04; // ~32–40px on most phones

    // Title font size
    final double titleSize = isTablet
        ? 44
        : isLargePhone
            ? 36
            : 30;

    // Subtitle font size
    final double subtitleSize = isTablet ? 17 : 15;

    // Horizontal padding
    final double hPad = isTablet ? 48 : 24;

    // Vertical padding (top/bottom within the page area)
    final double vPad = isTablet ? 24 : 12;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // ← centered
        children: [
          // SVG — centered
          Center(
            child: SvgPicture.asset(
              page.svgPath,
              width: svgSize,
              height: svgSize,
            ),
          ),

          SizedBox(height: svgToTextGap), // ← tightened gap

          // Title — centered
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w300,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle inside glass card — centered text
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 24 : 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                 
                ),
                child: Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: subtitleSize,
                    height: 1.65,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated gradient background ──────────────────────────────────
class _OnboardBackground extends StatelessWidget {
  final Size size;
  const _OnboardBackground({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black),
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.4,
          left: size.width * 0.15,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pinkAccent.withOpacity(0.2),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}