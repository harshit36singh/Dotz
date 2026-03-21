import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DotZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFCC2200),
          surface: Color(0xFFFAF8F4),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
