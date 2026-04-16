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
            surface: Color(0xFF2C2936), // Keep date picker solid for readability
          ),
          dialogBackgroundColor: const Color(0xFF2C2936),
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

      // ── Native Glass Container ──
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x55000000), // Semi-transparent for glass effect
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date of birth
                _FieldLabel(icon: CupertinoIcons.heart, label: 'DATE OF BIRTH'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Row(children: [
                    Text(
                      vm.birthDate == null
                          ? 'Tap to pick your birth date'
                          : '${vm.birthDate!.day} / ${vm.birthDate!.month} / ${vm.birthDate!.year}',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua', // Font applied
                        color: vm.birthDate != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (vm.birthDate != null)
                      _Chip('Age ${vm.age}')
                    else
                      Icon(CupertinoIcons.chevron_right,
                        color: Colors.white.withOpacity(0.2), size: 16),
                  ]),
                ),

                _Divider(),

                // Life expectancy
                _FieldLabel(icon: CupertinoIcons.timer, label: 'LIFE EXPECTANCY'),
                const SizedBox(height: 10),
                Row(children: [
                  Text('${vm.lifeExp}',
                    style: const TextStyle(
                      fontFamily: 'Glass Antiqua', // Font applied
                      color: Colors.white, fontSize: 42,
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                      height: 0.9, letterSpacing: -2)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('years',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                    Text('${vm.totalDays} days total',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:   Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor:         Colors.white,
                        overlayColor:       Colors.white.withOpacity(0.06),
                        trackHeight:        2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: vm.lifeExp.toDouble(),
                        min: 50, max: 120, divisions: 70,
                        onChanged: (v) => vm.setLifeExp(v.round()),
                      ),
                    ),
                  ),
                ]),

                // Stats chips
                if (vm.birthDate != null) ...[
                  _Divider(),
                  Row(children: [
                    _StatChip(
                      value: '${vm.totalDays - vm.daysLived}',
                      label: 'DAYS LEFT'),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: vm.totalDays > 0
                          ? '${(vm.daysLived / vm.totalDays * 100).toStringAsFixed(1)}%'
                          : '0%',
                      label: 'LIFE LIVED'),
                    const SizedBox(width: 8),
                    _StatChip(
                      value: '${vm.daysLived}',
                      label: 'DAYS LIVED'),
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

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: Colors.white.withOpacity(0.3), size: 14),
    const SizedBox(width: 8),
    Text(label,
      style: TextStyle(
        fontFamily: 'Glass Antiqua', // Font applied
        color: Colors.white.withOpacity(0.4),
        fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Container(height: 1, color: Colors.white.withOpacity(0.05)),
  );
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    ),
    child: Text(text,
      style: const TextStyle(
        fontFamily: 'Glass Antiqua', // Font applied
        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
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
        color: Colors.black.withOpacity(0.2), // Adjusted to blend with new UI
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: const TextStyle(
              fontFamily: 'Glass Antiqua', // Font applied
              color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.w800, fontStyle: FontStyle.italic,
              letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
            style: TextStyle(
              fontFamily: 'Glass Antiqua', // Font applied
              color: Colors.white.withOpacity(0.4),
              fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
        ],
      ),
    ),
  );
}