import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/app_theme.dart';

class ColorStrip extends StatelessWidget {
  final Color pastColor, todayColor, futureColor, bgColor;
  final void Function(Color) onPastChanged;
  final void Function(Color) onTodayChanged;
  final void Function(Color) onFutureChanged;
  final void Function(Color) onBgChanged;

  const ColorStrip({
    super.key,
    required this.pastColor,
    required this.todayColor,
    required this.futureColor,
    required this.bgColor,
    required this.onPastChanged,
    required this.onTodayChanged,
    required this.onFutureChanged,
    required this.onBgChanged,
  });

  void _pick(BuildContext ctx, String label, Color cur, void Function(Color) cb) =>
      showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.transparent,
        elevation: 0,
        isScrollControlled: true,
        builder: (_) => ColorPickerSheet(label: label, current: cur, onPick: cb),
      );

  @override
  Widget build(BuildContext ctx) {
    final items = [
      ('Past',   pastColor,   onPastChanged),
      ('Today',  todayColor,  onTodayChanged),
      ('Future', futureColor, onFutureChanged),
      ('BG',     bgColor,     onBgChanged),
    ];

    return Row(
      children: items.map((item) {
        final (lbl, col, cb) = item;
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _pick(ctx, lbl, col, cb),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: col,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lbl.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Color Picker Sheet ─────────────────────────────────────────────
class ColorPickerSheet extends StatelessWidget {
  final String label;
  final Color current;
  final void Function(Color) onPick;

  const ColorPickerSheet({
    super.key,
    required this.label,
    required this.current,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(CupertinoIcons.paintbrush, color: Colors.white.withOpacity(0.8), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Pick $label Color',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: kSwatches.map((c) {
                  final isSelected = current.value == c.value;
                  final isLight = c.computeLuminance() > 0.5;

                  return GestureDetector(
                    onTap: () {
                      onPick(c);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
                            : [],
                      ),
                      child: isSelected
                          ? Icon(
                              CupertinoIcons.checkmark_alt,
                              color: isLight ? Colors.black87 : Colors.white,
                              size: 26,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}