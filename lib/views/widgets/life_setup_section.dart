import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/home_view_model.dart';
import 'stat_box.dart';

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
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kRed),
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
      const SizedBox(height: 24),

      // ── Date of birth ─────────────────────────────────────────
      const Text('DATE OF BIRTH',
          style: TextStyle(
              color: kMid, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () => _pickDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: kSurf,
            border: Border.all(
              color: vm.birthDate != null ? kRed : kRule,
              width: vm.birthDate != null ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Text(
              vm.birthDate == null
                  ? 'Pick your birth date'
                  : '${vm.birthDate!.day} / ${vm.birthDate!.month} / ${vm.birthDate!.year}',
              style: TextStyle(
                  color: vm.birthDate != null ? kInk : kMid,
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (vm.birthDate != null)
              Text('Age ${vm.age}',
                  style: const TextStyle(
                      color: kRed, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),

      const SizedBox(height: 24),

      // ── Life expectancy slider ────────────────────────────────
      const Text('LIFE EXPECTANCY',
          style: TextStyle(
              color: kMid, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3)),
      const SizedBox(height: 10),
      Row(children: [
        Text('${vm.lifeExp}',
            style: const TextStyle(
                color: kRed, fontSize: 48, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900, height: 0.9, letterSpacing: -2)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('years',
              style: TextStyle(
                  color: kMid, fontSize: 10,
                  fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          Text('${vm.totalDays} days total',
              style: const TextStyle(
                  color: kRed, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kRed,
              inactiveTrackColor: kRule,
              thumbColor: kRed,
              overlayColor: kRed.withOpacity(0.08),
              trackHeight: 1,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: vm.lifeExp.toDouble(),
              min: 50, max: 120, divisions: 70,
              onChanged: (v) => vm.setLifeExp(v.round()),
            ),
          ),
        ),
      ]),

      // ── Stats (only when birth date set) ─────────────────────
      if (vm.birthDate != null) ...[
        const SizedBox(height: 20),
        Row(children: [
          StatBox(
            value: '${vm.totalDays - vm.daysLived}',
            label: 'DAYS LEFT',
          ),
          const SizedBox(width: 1),
          StatBox(
            value: vm.totalDays > 0
                ? '${(vm.daysLived / vm.totalDays * 100).toStringAsFixed(1)}%'
                : '0%',
            label: 'OF LIFE LIVED',
          ),
        ]),
      ],

      const SizedBox(height: 24),
    ],
  );
}
