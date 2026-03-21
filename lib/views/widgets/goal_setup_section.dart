import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/home_view_model.dart';

class GoalSetupSection extends StatefulWidget {
  final HomeViewModel vm;

  const GoalSetupSection({super.key, required this.vm});

  @override
  State<GoalSetupSection> createState() => _GoalSetupSectionState();
}

class _GoalSetupSectionState extends State<GoalSetupSection> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.vm.goalName == 'My Goal' ? '' : widget.vm.goalName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final vm = widget.vm;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          vm.goalDate ?? DateTime.now().add(const Duration(days: 60)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kRed),
        ),
        child: child!,
      ),
    );
    if (picked != null) vm.setGoalDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm   = widget.vm;
    final days = vm.goalDate == null
        ? null
        : vm.goalDate!.difference(DateTime.now()).inDays;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),

      // ── Goal name ──────────────────────────────────────────────
      const Text('GOAL NAME',
          style: TextStyle(
              color: kMid,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 3)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: kSurf,
          border: Border.all(color: kRule),
        ),
        child: TextField(
          controller: _nameCtrl,
          style: const TextStyle(
              color: kInk, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(
            hintText: 'e.g. New York Marathon',
            hintStyle: TextStyle(color: kMid),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
          onChanged: vm.setGoalName,
        ),
      ),

      const SizedBox(height: 24),

      // ── Target date ───────────────────────────────────────────
      const Text('TARGET DATE',
          style: TextStyle(
              color: kMid,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 3)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: kSurf,
            border: Border.all(
              color: vm.goalDate != null ? kRed : kRule,
              width: vm.goalDate != null ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Text(
              vm.goalDate == null
                  ? 'Pick a date'
                  : '${vm.goalDate!.day} / ${vm.goalDate!.month} / ${vm.goalDate!.year}',
              style: TextStyle(
                  color: vm.goalDate != null ? kInk : kMid,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (days != null)
              Text('$days days away',
                  style: const TextStyle(
                      color: kRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
          ]),
        ),
      ),

      const SizedBox(height: 24),
    ]);
  }
}
