import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: kSurf,
        border: Border.all(color: kRule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: kRed,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: kMid,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5)),
        ],
      ),
    ),
  );
}
