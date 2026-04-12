import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingKey = 'dotz_onboarding_complete';

  /// Call this from main.dart to decide whether to show onboarding
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
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
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
      emoji: '⬤',
      title: 'Every dot\nis a day.',
      subtitle: 'Your year, your goals, your life — reduced to a grid of dots. Watch them fill, one day at a time.',
      accent: Colors.white,
    ),
    _OnboardPage(
      emoji: '◉',
      title: 'Three\ncalendars.',
      subtitle: 'Track the year ahead. Count down to a goal. Or see your entire life in a single glance.',
      accent: Colors.white,
    ),
    _OnboardPage(
      emoji: '◈',
      title: 'Live on your\nlock screen.',
      subtitle: 'Set it as a live wallpaper. Every unlock reminds you how much time is left — and how to use it.',
      accent: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                    const SizedBox(height: 24),

                    // Top logo bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 12, height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'DotZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pages
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: _pages.length,
                        itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
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

                    const SizedBox(height: 40),

                    // CTA Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'GET STARTED'
                                    : 'NEXT',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip
                    if (_currentPage < _pages.length - 1)
                      GestureDetector(
                        onTap: _complete,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'SKIP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 40),

                    const SizedBox(height: 8),
                  ],
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
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

// ── Single page view ──────────────────────────────────────────────
class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Giant emoji/symbol
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 88, height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  page.emoji,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.w300,
              letterSpacing: -2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),

          // Subtitle inside glass card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  page.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
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
          top: -120, right: -80,
          child: Container(
            width: 360, height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent.withOpacity(0.55),
            ),
          ),
        ),
        Positioned(
          bottom: -120, left: -80,
          child: Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.4, left: size.width * 0.15,
          child: Container(
            width: 280, height: 280,
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