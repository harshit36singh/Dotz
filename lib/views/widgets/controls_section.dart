import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/home_view_model.dart';
import 'color_strip.dart';

class ControlsSection extends StatelessWidget {
  final HomeViewModel vm;

  const ControlsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Colours ───────────────────────────────────────────────
      const Text('COLOURS',
          style: TextStyle(
              color: kMid, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3.5)),
      const SizedBox(height: 16),
      ColorStrip(
        pastColor:       vm.pastColor,
        todayColor:      vm.todayColor,
        futureColor:     vm.futureColor,
        bgColor:         vm.bgColor,
        onPastChanged:   vm.setPastColor,
        onTodayChanged:  vm.setTodayColor,
        onFutureChanged: vm.setFutureColor,
        onBgChanged:     vm.setBgColor,
      ),
      const SizedBox(height: 28),
      Container(height: 1, color: kRule),
      const SizedBox(height: 28),

      // ── Grid density ──────────────────────────────────────────
      const Text('GRID DENSITY',
          style: TextStyle(
              color: kMid, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3.5)),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${vm.columns}',
              style: const TextStyle(
                  color: kRed, fontSize: 48,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  height: 1, letterSpacing: -2)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('columns',
                    style: TextStyle(
                        color: kMid, fontSize: 10,
                        fontWeight: FontWeight.w500, letterSpacing: 2)),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kRed,
                    inactiveTrackColor: kRule,
                    thumbColor: kRed,
                    overlayColor: kRed.withOpacity(0.08),
                    trackHeight: 1,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5),
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
      const SizedBox(height: 28),
      Container(height: 1, color: kRule),
      const SizedBox(height: 28),

      // ── Display toggle ────────────────────────────────────────
      const Text('DISPLAY',
          style: TextStyle(
              color: kMid, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3.5)),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress label',
                  style: TextStyle(
                      color: kInk, fontSize: 14,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 3),
              Text('Show days left at bottom',
                  style: TextStyle(
                      color: kMid, fontSize: 11, letterSpacing: 0.2)),
            ],
          ),
          Switch(
            value: vm.showLabel,
            onChanged: vm.setShowLabel,
            activeColor: kRed,
            trackOutlineColor: MaterialStateProperty.all(kRule),
          ),
        ],
      ),
    ],
  );
}
