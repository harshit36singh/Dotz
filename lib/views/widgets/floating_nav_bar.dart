import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/wallpaper_settings.dart';

class FloatingNavBar extends StatelessWidget {
  final CalendarMode mode;
  final void Function(CalendarMode) onTap;

  const FloatingNavBar({super.key, required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      // Year  — a clean dot-grid feel
      (CalendarMode.year,    Icons.grid_on_outlined),
      // Monthly — horizontal bands / rows
      (CalendarMode.weekly,  Icons.table_rows_outlined),
      // Goal — target / bullseye feel
      (CalendarMode.goal,    Icons.my_location_outlined),
      // Life — hourglass (time of your life)
      (CalendarMode.life,    Icons.hourglass_bottom_outlined),
      // Settings — sliders, not a gear
      (CalendarMode.settings, Icons.tune_rounded),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.8,
                  ),
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
    final List<Widget> widgets = [];

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
                color: active
                    ? Colors.white.withOpacity(0.13)
                    : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.white38,
                size: 21,
              ),
            ),
          ),
        ),
      );

      if (i < items.length - 1) {
        widgets.add(
          Container(
            width: 0.5,
            height: 18,
            color: Colors.white.withOpacity(0.08),
          ),
        );
      }
    }

    return widgets;
  }
}