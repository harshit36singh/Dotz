import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_view_model.dart';
import 'glass_container.dart';
import 'glass_date_picker.dart';

class GoalSetupSection extends StatefulWidget {
  final HomeViewModel vm;
  const GoalSetupSection({super.key, required this.vm});

  @override
  State<GoalSetupSection> createState() => _GoalSetupSectionState();
}

class _GoalSetupSectionState extends State<GoalSetupSection> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.vm.goalName == 'My Goal' ? '' : widget.vm.goalName,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempDate =
        widget.vm.goalDate ?? now.add(const Duration(days: 100));
    if (tempDate.isBefore(now)) tempDate = now; // Safety check

    final date = await showGlassDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (date != null) widget.vm.setGoalDate(date);
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final tempDate = widget.vm.goalStartDate ?? now;

    final date = await showGlassDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (date != null) widget.vm.setGoalStartDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.white.withOpacity(0.05),
      blur: 14,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Name
            Text(
              'GOAL NAME',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white.withOpacity(0.35),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Prepare for test',
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.vm.setGoalName,
                  ),
                ),
                if (_ctrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _ctrl.clear();
                      widget.vm.setGoalName('');
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      'CLEAR',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 20),

            // Target Date
            Text(
              'TARGET DATE',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white.withOpacity(0.35),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.vm.goalDate == null
                        ? 'Tap to pick a date'
                        : DateFormat(
                            'MMMM d, yyyy',
                          ).format(widget.vm.goalDate!),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: widget.vm.goalDate == null
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                      fontSize: 16,
                    ),
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

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 20),

            // Start Date — defaults to today; set a custom one to track a
            // range that already started (a challenge you began last week,
            // a project kicked off last month, etc).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'START DATE',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                if (widget.vm.goalStartDate != null)
                  GestureDetector(
                    onTap: () => widget.vm.setGoalStartDate(null),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'RESET TO TODAY',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickStartDate(context),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.vm.goalStartDate == null
                        ? 'Today'
                        : DateFormat(
                            'MMMM d, yyyy',
                          ).format(widget.vm.goalStartDate!),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: widget.vm.goalStartDate == null
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white,
                      fontSize: 16,
                    ),
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
          ],
        ),
      ),
    );
  }
}
