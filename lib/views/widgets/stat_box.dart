import 'dart:ui';
import 'package:flutter/material.dart';

class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    // ── Native Glass Container ──
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12), // Match the inner border radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), // Transparent enough for the glass effect
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Montserrat', // Font applied
                      color: Colors.white, // Changed to white to match the new dark theme
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Montserrat', // Font applied
                      color: Colors.white.withOpacity(0.5), // Match new UI sub-text color
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    ),
  );
}