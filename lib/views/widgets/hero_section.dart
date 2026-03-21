import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tag,
            style: const TextStyle(
                color: kMid,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5)),
        const SizedBox(height: 4),
        FadeTransition(
          opacity: fade,
          child: Text(bigNum,
              style: const TextStyle(
                color: kRed,
                fontSize: 108,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                height: 0.85,
                letterSpacing: -6,
              )),
        ),
        const SizedBox(height: 6),
        FadeTransition(
          opacity: fade,
          child: Text(title,
              style: const TextStyle(
                color: kRed,
                fontSize: 26,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              )),
        ),
        const SizedBox(height: 18),
        const Text('PROGRESS:',
            style: TextStyle(
                color: kMid,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.5)),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(statA,
                style: const TextStyle(
                    color: kInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(statB,
                  style: const TextStyle(
                      color: kMid, fontSize: 12, letterSpacing: 0.3)),
            ),
          ],
        ),
      ],
    ),
  );
}
