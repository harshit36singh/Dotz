import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/home/home_screen.dart';
import 'views/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool showOnboarding = true;
  try {
    showOnboarding = await OnboardingScreen.shouldShow();
  } catch (_) {
    // If SharedPreferences fails (first cold start), default to showing onboarding
    showOnboarding = true;
  }

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DotZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF111111),
        ),
      ),
      home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}