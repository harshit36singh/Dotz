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
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 50,
          // 1. Force children (the white highlights) to clip perfectly 
          // to the exact curve of this container.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(100),
          ),
          // 2. Draw the border ON TOP of everything to hide any microscopic bleeding
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildItems(items),
          ),
        ),
      ),
    );
  }

  // 3. Helper method to build the buttons and dividers separately
  List<Widget> _buildItems(List<(CalendarMode, IconData)> items) {
    List<Widget> widgets = [];
    
    for (int i = 0; i < items.length; i++) {
      final (m, icon) = items[i];
      final active = mode == m;

      // Add the symmetrical button
      widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: double.infinity,
            width: 60, // Perfectly 60px wide now, no stolen border pixels!
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
              // NO borders inside the button decoration anymore
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.white54,
              size: 22,
            ),
          ),
        ),
      );

      // Add the 1-pixel divider as its own standalone widget (if not the last item)
      if (i < items.length - 1) {
        widgets.add(
          Container(
            width: 1,
            height: double.infinity,
            color: Colors.white.withOpacity(0.1),
          ),
        );
      }
    }

    return widgets;
  }
}