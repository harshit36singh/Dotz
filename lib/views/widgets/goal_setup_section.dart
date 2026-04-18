import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_view_model.dart';

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

  // ── CUSTOM GLASS DATE PICKER ──
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempDate = widget.vm.goalDate ?? now.add(const Duration(days: 100));
    if (tempDate.isBefore(now)) tempDate = now; // Safety check

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
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 365 * 10)),
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
    if (date != null) widget.vm.setGoalDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Name
            Text(
              'GOAL NAME',
              style: TextStyle(
                fontFamily: 'Glass Antiqua',
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
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Prepare for test',
                      hintStyle: TextStyle(
                        fontFamily: 'Glass Antiqua',
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
                        fontFamily: 'Glass Antiqua',
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
                fontFamily: 'Glass Antiqua',
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
                        : DateFormat('MMMM d, yyyy').format(widget.vm.goalDate!),
                    style: TextStyle(
                      fontFamily: 'Glass Antiqua',
                      color: widget.vm.goalDate == null ? Colors.white.withOpacity(0.5) : Colors.white,
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