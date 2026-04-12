import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

class FloatingNavBar extends StatelessWidget {
  final CalendarMode mode;
  final void Function(CalendarMode) onTap;

  const FloatingNavBar({super.key, required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (CalendarMode.year,     Icons.calendar_today_outlined),
      (CalendarMode.goal,     Icons.flag_outlined),
      (CalendarMode.life,     Icons.favorite_outline),
      (CalendarMode.settings, Icons.settings_outlined),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (i) {
              final (m, icon) = items[i];
              final active    = mode == m;
              final isFirst   = i == 0;
              final isLast    = i == items.length - 1;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: double.infinity,
                  width: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // Active pill: same border-radius as the outer container
                    // on the outer edges, so the highlight butts cleanly against
                    // the pill border on both first and last items.
                    color: active
                        ? Colors.white.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left:  isFirst ? const Radius.circular(23) : Radius.zero,
                      right: isLast  ? const Radius.circular(23) : Radius.zero,
                    ),
                    // Separator line between items (not after last)
                    border: !isLast
                        ? Border(
                            right: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: active ? Colors.white : Colors.white54,
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}