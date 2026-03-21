import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';
import '../../core/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final CalendarMode mode;
  final void Function(CalendarMode) onTap;

  const FloatingNavBar({
    super.key,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (CalendarMode.year, 'YEAR'),
      (CalendarMode.goal, 'GOAL'),
      (CalendarMode.life, 'LIFE'),
    ];

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: kSurf,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: kRule, width: 1),
        boxShadow: [
          BoxShadow(
            color: kInk.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: items.indexed.map((entry) {
          final i        = entry.$1;
          final (m, lbl) = entry.$2;
          final active   = mode == m;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(m),
              child: Container(
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? kRed : Colors.transparent,
                  border: i < items.length - 1
                      ? const Border(
                          right: BorderSide(color: kRule, width: 1))
                      : null,
                ),
                child: Text(
                  lbl,
                  style: TextStyle(
                    color: active ? Colors.white : kMid,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
