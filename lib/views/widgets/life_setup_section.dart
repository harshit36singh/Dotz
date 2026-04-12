import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/home_view_model.dart';

class LifeSetupSection extends StatelessWidget {
  final HomeViewModel vm;

  const LifeSetupSection({super.key, required this.vm});

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.birthDate ?? DateTime(1995, 6, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            surface: Color(0xFF1C1C1E),
          ),
          dialogBackgroundColor: const Color(0xFF1C1C1E),
        ),
        child: child!,
      ),
    );
    if (picked != null) vm.setBirthDate(picked);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),

      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date of birth ─────────────────────────────────
                Row(
                  children: [
                    Icon(CupertinoIcons.heart, color: Colors.white.withOpacity(0.4), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'DATE OF BIRTH',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Row(children: [
                    Text(
                      vm.birthDate == null
                          ? 'Tap to pick your birth date'
                          : '${vm.birthDate!.day} / ${vm.birthDate!.month} / ${vm.birthDate!.year}',
                      style: TextStyle(
                        color: vm.birthDate != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (vm.birthDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Age ${vm.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.white.withOpacity(0.25),
                        size: 14,
                      ),
                  ]),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Container(height: 0.5, color: Colors.white.withOpacity(0.1)),
                ),

                // ── Life expectancy ───────────────────────────────
                Row(
                  children: [
                    Icon(CupertinoIcons.timer, color: Colors.white.withOpacity(0.4), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'LIFE EXPECTANCY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Text(
                    '${vm.lifeExp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'years',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${vm.totalDays} days total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.15),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.08),
                        trackHeight: 1.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      ),
                      child: Slider(
                        value: vm.lifeExp.toDouble(),
                        min: 50, max: 120, divisions: 70,
                        onChanged: (v) => vm.setLifeExp(v.round()),
                      ),
                    ),
                  ),
                ]),

                // ── Stats ─────────────────────────────────────────
                if (vm.birthDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Container(height: 0.5, color: Colors.white.withOpacity(0.1)),
                  ),
                  Row(children: [
                    _StatChip(
                      value: '${vm.totalDays - vm.daysLived}',
                      label: 'DAYS LEFT',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: vm.totalDays > 0
                          ? '${(vm.daysLived / vm.totalDays * 100).toStringAsFixed(1)}%'
                          : '0%',
                      label: 'LIFE LIVED',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: '${vm.daysLived}',
                      label: 'DAYS LIVED',
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),
    ],
  );
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}