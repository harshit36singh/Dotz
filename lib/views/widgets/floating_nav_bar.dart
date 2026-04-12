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

    return Center(
      child: Padding(
        // Adds a small safety margin so it doesn't touch screen edges
        padding: const EdgeInsets.symmetric(horizontal: 16), 
        child: ConstrainedBox(
          // 1. LIMIT maximum width so it doesn't stretch on tablets
          constraints: const BoxConstraints(maxWidth: 280), 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(100),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  // 2. Use MainAxisSize.max here within the ConstrainedBox
                  mainAxisSize: MainAxisSize.max, 
                  children: _buildItems(items),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<(CalendarMode, IconData)> items) {
    List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final (m, icon) = items[i];
      final active = mode == m;

      // 3. Wrap in Expanded so buttons shrink on small screens
      widgets.add(
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.white54,
                size: 22,
              ),
            ),
          ),
        ),
      );

      if (i < items.length - 1) {
        widgets.add(
          Container(
            width: 1,
            height: 20, // 4. Fixed height for divider looks cleaner
            color: Colors.white.withOpacity(0.1),
          ),
        );
      }
    }

    return widgets;
  }
}