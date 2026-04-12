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
      (CalendarMode.year, Icons.calendar_today_outlined),
      (CalendarMode.goal, Icons.flag_outlined),
      (CalendarMode.life, Icons.favorite_outline),
      (CalendarMode.settings, Icons.settings_outlined),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 50,
          // Optional: Add a max width here if you want it responsive, e.g., width: 280,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            // 1. Tell the Row to only take up as much space as its children need
            mainAxisSize: MainAxisSize.min, 
            children: items.indexed.map((entry) {
              final i = entry.$1;
              final (m, icon) = entry.$2;
              final active = mode == m;

              // 2. Removed the 'Expanded' widget here
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(m),
                child: Container(
                  height: double.infinity,
                  width: 60, // 3. Set a fixed width for each icon button (adjust to your liking)
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
                    border: i < items.length - 1
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
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}