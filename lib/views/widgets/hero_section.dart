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
      // Reduced top and bottom padding to make the overall section more compact
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 16),
      // ── Native Glass Container ──
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            // Tighter internal padding for a minimal card look
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x55000000), // Semi-transparent for glass effect
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow tag
                if (tag.isNotEmpty) ...[
                  Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Glass Antiqua', // Font applied
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Single-line header (Title + BigNum combined at size 32)
                FadeTransition(
                  opacity: fade,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${title.replaceAll('\n', ' ').trim()} ', // Forces single line and adds space
                              style: const TextStyle(
                                fontFamily: 'Glass Antiqua',
                                color: Colors.white,
                                fontSize: 32, // Forced to size 32
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              bigNum,
                              style: const TextStyle(
                                fontFamily: 'Glass Antiqua',
                                color: Colors.white,
                                fontSize: 32, // Forced to size 32
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Minimal Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.05),
                ),
                
                const SizedBox(height: 12),
                
                // Bottom stats row (Only the percentage/statB is kept)
                Text(
                  statB.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua',
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}