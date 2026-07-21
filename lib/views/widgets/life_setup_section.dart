import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_theme.dart';
import '../../models/wallpaper_settings.dart';
import '../../viewmodels/home_view_model.dart';
import 'glass_container.dart';
import 'glass_date_picker.dart';

class LifeSetupSection extends StatelessWidget {
  final HomeViewModel vm;
  const LifeSetupSection({super.key, required this.vm});

  Future<void> _pickDob(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempDate = vm.birthDate ?? DateTime(2000, 1, 1);
    if (tempDate.isAfter(now)) tempDate = now; // Safety check

    final date = await showGlassDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: DateTime(1900),
      lastDate: now,
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
          child: GlassContainer(
            color: Colors.white.withOpacity(0.05),
            blur: 14,
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
                          fontFamily: 'Montserrat',
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
                          fontFamily: 'Montserrat',
                          color: vm.birthDate == null
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
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
        GlassContainer(
          color: Colors.white.withOpacity(0.05),
          blur: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIFE EXPECTANCY',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
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
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vm.lifeUnit == LifeUnit.weeks
                          ? 'years\n${vm.lifeExp * 52} weeks total'
                          : 'years\n${vm.lifeExp * 365} days total',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
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
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
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
        const SizedBox(height: 12),

        // Display Unit — the classic "life calendar" is week-based (~4,000
        // dots for 80 years); days gives a denser, more granular grid.
        GlassContainer(
          color: Colors.white.withOpacity(0.05),
          blur: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COUNT IN',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                _UnitToggle(selected: vm.lifeUnit, onChanged: vm.setLifeUnit),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final LifeUnit selected;
  final void Function(LifeUnit) onChanged;
  const _UnitToggle({required this.selected, required this.onChanged});

  static const _options = [(LifeUnit.days, 'DAYS'), (LifeUnit.weeks, 'WEEKS')];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.black.withOpacity(0.22),
      blur: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((e) {
          final (unit, label) = e;
          final active = selected == unit;
          return GestureDetector(
            onTap: () => onChanged(unit),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: kAnimDuration,
              curve: kAnimCurve,
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withOpacity(0.92)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(kGlassRadius),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: active
                      ? Colors.black.withOpacity(0.85)
                      : Colors.white.withOpacity(0.35),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
