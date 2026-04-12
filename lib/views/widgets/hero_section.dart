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
    final sw = MediaQuery.of(context).size.width;
    // On wide screens, use a slightly smaller big number so it doesn't overwhelm
    final bigNumSize = sw >= 700 ? 72.0 : 84.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),   // solid dark — no glass
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow tag
            Text(
              tag.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),

            // Big number + title
            FadeTransition(
              opacity: fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bigNum,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bigNumSize,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Hairline divider
            Container(
              height: 0.5,
              width: double.infinity,
              color: Colors.white.withOpacity(0.08),
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  statA,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statB.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
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
    );
  }
}