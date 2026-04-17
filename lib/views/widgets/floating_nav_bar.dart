import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

class FloatingNavBar extends StatelessWidget {
  final CalendarMode mode;
  final void Function(CalendarMode) onTap;

  const FloatingNavBar({super.key, required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ── ADDED WEEKLY MODE HERE ──
    final items = [
      (CalendarMode.year, Icons.calendar_today_outlined),
      (CalendarMode.weekly, Icons.view_week_outlined), 
      (CalendarMode.goal, Icons.flag_outlined),
      (CalendarMode.life, Icons.favorite_outline),
      (CalendarMode.settings, Icons.settings_outlined),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), 
        child: ConstrainedBox(
          // ── INCREASED MAX WIDTH TO 340 TO FIT 5 ICONS ──
          constraints: const BoxConstraints(maxWidth: 340), 
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
                ),
                child: Row(
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
            height: 20, 
            color: Colors.white.withOpacity(0.1),
          ),
        );
      }
    }

    return widgets;
  }
}