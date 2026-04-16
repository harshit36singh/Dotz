import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for CupertinoSwitch
import '../../viewmodels/home_view_model.dart';
import 'color_strip.dart';

class ControlsSection extends StatelessWidget {
  final HomeViewModel vm;

  const ControlsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x55000000), // Semi-transparent for glass effect
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Colours ───────────────────────────────────────────────
            Text('Colours',
                style: TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white.withOpacity(0.5), 
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
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
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),

            // ── Grid density ──────────────────────────────────────────
            Text('Grid Density',
                style: TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white.withOpacity(0.5), 
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${vm.columns}',
                    style: const TextStyle(
                        fontFamily: 'Glass Antiqua', // Font applied
                        color: Colors.white, 
                        fontSize: 48,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        height: 1, 
                        letterSpacing: -2)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('columns',
                          style: TextStyle(
                              fontFamily: 'Glass Antiqua', // Font applied
                              color: Colors.white.withOpacity(0.5), 
                              fontSize: 12,
                              fontWeight: FontWeight.w500, 
                              letterSpacing: 1.5)),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:   const Color(0xFFE4F087), // Accent from image
                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                          thumbColor:         const Color(0xFFE4F087),
                          overlayColor:       const Color(0xFFE4F087).withOpacity(0.08),
                          trackHeight:        2,
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
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 24),

            // ── Display toggle ────────────────────────────────────────
            Text('Display',
                style: TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white.withOpacity(0.5), 
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress label',
                        style: TextStyle(
                            fontFamily: 'Glass Antiqua', // Font applied
                            color: Colors.white, 
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('Show days left at bottom',
                        style: TextStyle(
                            fontFamily: 'Glass Antiqua', // Font applied
                            color: Colors.white.withOpacity(0.5), 
                            fontSize: 13)),
                  ],
                ),
                CupertinoSwitch(
                  value: vm.showLabel,
                  onChanged: vm.setShowLabel,
                  activeColor: const Color(0xFFE4F087), // Accent from image
                  trackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}