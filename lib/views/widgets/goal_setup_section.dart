import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      initialDate: vm.goalDate ?? DateTime.now().add(const Duration(days: 60)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
    if (picked != null) vm.setGoalDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm   = widget.vm;
    final days = vm.goalDate == null
        ? null
        : vm.goalDate!.difference(DateTime.now()).inDays;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                // ── Goal name ──────────────────────────────────────
                Row(
                  children: [
                    Icon(CupertinoIcons.flag, color: Colors.white.withOpacity(0.4), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'GOAL NAME',
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. New York Marathon',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: vm.setGoalName,
                      ),
                    ),
                    // Clear button if text is entered
                    if (_nameCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _nameCtrl.clear();
                          vm.setGoalName('');
                          setState(() {});
                        },
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.white.withOpacity(0.3),
                          size: 18,
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Container(height: 0.5, color: Colors.white.withOpacity(0.1)),
                ),

                // ── Target date ───────────────────────────────────
                Row(
                  children: [
                    Icon(CupertinoIcons.calendar, color: Colors.white.withOpacity(0.4), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'TARGET DATE',
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
                  onTap: _pickDate,
                  child: Row(children: [
                    Text(
                      vm.goalDate == null
                          ? 'Tap to pick a date'
                          : '${vm.goalDate!.day} / ${vm.goalDate!.month} / ${vm.goalDate!.year}',
                      style: TextStyle(
                        color: vm.goalDate != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.25),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (days != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$days days',
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

                // ── Reset button ──────────────────────────────────
                if (vm.goalDate != null || _nameCtrl.text.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Container(height: 0.5, color: Colors.white.withOpacity(0.1)),
                  ),
                  GestureDetector(
                    onTap: () {
                      vm.clearGoal();
                      _nameCtrl.clear();
                      setState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          color: Colors.white.withOpacity(0.4),
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RESET GOAL',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),
    ]);
  }
}