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
      padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large typographic header replacing the old box
          FadeTransition(
            opacity: fade,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tag.isNotEmpty) ...[
                        Text(
                          tag.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Glass Antiqua', // Font applied
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        title.replaceAll(' ', '\n'), // Wraps cleanly
                        style: const TextStyle(
                          fontFamily: 'Glass Antiqua', // Font applied
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bigNum,
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua', // Font applied
                          color: Colors.white,
                          fontSize: bigNumSize,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative floating circular button from the UI reference
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Stats row turned into a card to match the grid UI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2936), // Updated image card color
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Yellow-green accent checkmark
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4F087),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 16),
                ),
                const SizedBox(width: 14),
                Text(
                  statA,
                  style: const TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  statB.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}