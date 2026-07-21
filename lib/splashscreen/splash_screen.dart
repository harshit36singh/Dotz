import 'package:dotz/views/home/home_screen.dart';
import 'package:dotz/views/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;

  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.showOnboarding
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: _SplashMark()),
    );
  }
}

class _SplashMark extends StatefulWidget {
  const _SplashMark();

  @override
  State<_SplashMark> createState() => _SplashMarkState();
}

class _SplashMarkState extends State<_SplashMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: kAnimDuration,
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: kAnimCurve,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kOrange,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'DOTZ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }
}
