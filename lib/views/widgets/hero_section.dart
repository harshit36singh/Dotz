import 'dart:ui';
import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final String tag;
  final String bigNum;
  final String title;
  final String statA;
  final String statB;
  final double hPad;
  final Animation<double> fade;

  const HeroSection({
    super.key,
    required this.tag,
    required this.bigNum,
    required this.title,
    required this.statA,
    required this.statB,
    required this.hPad,
    required this.fade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), 
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0), 
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25), 
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.15), 
                width: 0.5, // Hairline border for minimal aesthetic
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TINY EYEBROW TAG
                Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4), 
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 2. MASSIVE NUMBER & TITLE
                FadeTransition(
                  opacity: fade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bigNum, // e.g., "102"
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 84, // Massive size
                          fontWeight: FontWeight.w300, // Thin, elegant font weight
                          letterSpacing: -4,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title.toUpperCase(), // e.g., "DAYS PASSED"
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w800, // Heavy weight for contrast
                          letterSpacing: 4.0, // Wide spacing to look premium
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 3. HAIRLINE DIVIDER
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.15),
                ),
                
                const SizedBox(height: 24),
                
                // 4. CLEAN TEXT STATS (No background pill)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      statA,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statB.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}