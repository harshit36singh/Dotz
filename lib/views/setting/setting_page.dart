import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/app_theme.dart';
import '../widgets/color_strip.dart';

class SettingsPage extends StatelessWidget {
  final HomeViewModel vm;

  const SettingsPage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassSection(
            title: 'DOT COLOURS',
            icon: CupertinoIcons.paintbrush,
            child: ColorStrip(
              pastColor:       vm.pastColor,
              todayColor:      vm.todayColor,
              futureColor:     vm.futureColor,
              bgColor:         vm.bgColor,
              onPastChanged:   vm.setPastColor,
              onTodayChanged:  vm.setTodayColor,
              onFutureChanged: vm.setFutureColor,
              onBgChanged:     vm.setBgColor,
            ),
          ),

          const SizedBox(height: 16),

          _GlassSection(
            title: 'GRID DENSITY',
            icon: CupertinoIcons.square_grid_3x2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${vm.columns}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'columns',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.15),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.08),
                          trackHeight: 1.5,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: vm.columns.toDouble(),
                          min: 10, max: 30, divisions: 20,
                          onChanged: (v) => vm.setColumns(v.round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _GlassSection(
            title: 'DISPLAY',
            icon: CupertinoIcons.eye,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress label',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Show days left at bottom',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: vm.showLabel,
                  onChanged: vm.setShowLabel,
                  activeColor: Colors.white,
                  trackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.black,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _GlassSection(
            title: 'ABOUT',
            icon: CupertinoIcons.info_circle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AboutRow(label: 'App', value: 'DotZ'),
                _AboutRow(label: 'Version', value: '1.0.0'),
                _AboutRow(label: 'Purpose', value: 'Live dot wallpapers'),
                const SizedBox(height: 8),
                Text(
                  'Each dot is a day. Watch your year, goals, and life unfold—one dot at a time.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                    height: 1.7,
                    letterSpacing: 0.2,
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

// ── Glass section card ─────────────────────────────────────────────
class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _GlassSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withOpacity(0.5), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label, value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}