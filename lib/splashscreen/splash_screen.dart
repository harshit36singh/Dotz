import 'package:dotz/views/home/home_screen.dart';
import 'package:dotz/views/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  final bool showOnboarding;

  const SplashScreen({super.key, required this.showOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void _navigate() {
    if (!mounted) return; // ✅ prevents crash
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          "assets/dot.json", 
          height: 250,
          width:250,
          repeat: false,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            Future.delayed(composition.duration, _navigate);
          },
        ),
      ),
    );
  }
}