import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_view_model.dart';

class LifeSetupSection extends StatelessWidget {
  final HomeViewModel vm;
  const LifeSetupSection({super.key, required this.vm});

  // ── CUSTOM GLASS DATE PICKER ──
  Future<void> _pickDob(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempDate = vm.birthDate ?? DateTime(2000, 1, 1);
    if (tempDate.isAfter(now)) tempDate = now; // Safety check

    final date = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.white, // Selected circle color
                                onPrimary: Colors.black, // Text inside selected circle
                                surface: Colors.transparent, // Background of calendar
                                onSurface: Colors.white, // Default text color
                              ),
                              dialogBackgroundColor: Colors.transparent,
                              textTheme: const TextTheme(
                                bodyMedium: TextStyle(fontFamily: 'Glass Antiqua'),
                                titleMedium: TextStyle(fontFamily: 'Glass Antiqua'),
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: tempDate,
                              firstDate: DateTime(1900),
                              lastDate: now,
                              onDateChanged: (val) => tempDate = val,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      fontFamily: 'Glass Antiqua',
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.pop(context, tempDate),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'CONFIRM',
                                    style: TextStyle(
                                      fontFamily: 'Glass Antiqua',
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (date != null) vm.setBirthDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date of Birth Section
        GestureDetector(
          onTap: () => _pickDob(context),
          behavior: HitTestBehavior.opaque,
          child: _GlassCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATE OF BIRTH',
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        vm.birthDate == null
                            ? 'Tap to set birth date'
                            : DateFormat('MMMM d, yyyy').format(vm.birthDate!),
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: vm.birthDate == null ? Colors.white.withOpacity(0.5) : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '›',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Life Expectancy Section
        _GlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIFE EXPECTANCY',
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua',
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${vm.lifeExp}',
                      style: const TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'years\n${vm.lifeExp * 365} days total',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.05),
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: vm.lifeExp.toDouble(),
                          min: 40,
                          max: 100,
                          divisions: 60,
                          onChanged: (v) => vm.setLifeExp(v.round()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
           
          ),
          child: child,
        ),
      ),
    );
  }
}