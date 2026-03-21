import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

// ════════════════════════════════════════════════════════════════
//  COLOR STRIP  — four tappable swatches (Past / Today / Future / BG)
// ════════════════════════════════════════════════════════════════
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

  void _pick(BuildContext ctx, String label, Color cur,
      void Function(Color) cb) =>
      showModalBottomSheet(
        context: ctx,
        backgroundColor: kSurf,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero),
        builder: (_) =>
            ColorPickerSheet(label: label, current: cur, onPick: cb),
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
            onTap: () => _pick(ctx, lbl, col, cb),
            child: Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: col,
                  border: Border.all(color: kRule),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 7),
              Text(lbl,
                  style: const TextStyle(
                      color: kMid,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  COLOR PICKER SHEET  — modal bottom sheet with swatch grid
// ════════════════════════════════════════════════════════════════
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 36, height: 1, color: kRule),
      const SizedBox(height: 22),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: const TextStyle(
                color: kInk,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: kSwatches.map((c) {
          final sel = current.value == c.value;
          return GestureDetector(
            onTap: () {
              onPick(c);
              Navigator.pop(context);
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                    color: sel ? kRed : kRule,
                    width: sel ? 2 : 1),
              ),
            ),
          );
        }).toList(),
      ),
    ]),
  );
}
