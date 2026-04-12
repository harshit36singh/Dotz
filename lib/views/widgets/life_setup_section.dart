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

      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
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
                    color: vm.birthDate != null
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (vm.birthDate != null)
                  _Chip('Age ${vm.age}')
                else
                  Icon(CupertinoIcons.chevron_right,
                    color: Colors.white.withOpacity(0.2), size: 14),
              ]),
            ),

            _Divider(),

            // Life expectancy
            _FieldLabel(icon: CupertinoIcons.timer, label: 'LIFE EXPECTANCY'),
            const SizedBox(height: 10),
            Row(children: [
              Text('${vm.lifeExp}',
                style: const TextStyle(
                  color: Colors.white, fontSize: 42,
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                  height: 0.9, letterSpacing: -2)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('years',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                Text('${vm.totalDays} days total',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:   Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                    thumbColor:         Colors.white,
                    overlayColor:       Colors.white.withOpacity(0.06),
                    trackHeight:        1,
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
    Icon(icon, color: Colors.white.withOpacity(0.3), size: 12),
    const SizedBox(width: 6),
    Text(label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Container(height: 0.5, color: Colors.white.withOpacity(0.07)),
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
        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: const TextStyle(
              color: Colors.white, fontSize: 15,
              fontWeight: FontWeight.w800, fontStyle: FontStyle.italic,
              letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        ],
      ),
    ),
  );
}