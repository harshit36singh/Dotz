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
        backgroundColor: Colors.transparent, // Ensures the glass effect shows
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Row(
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
                        width: 36, 
                        height: 36,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle, 
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2), 
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lbl.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7), 
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  COLOR PICKER SHEET  — iOS Glassmorphism Modal
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
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
          decoration: BoxDecoration(
            // 1. Added a gradient to give a subtle inner "shine" to the glass
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.black.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
            // 2. Added a distinct white border around the sheet to separate it from the background
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              // iOS-style drag handle
              Container(
                width: 50, // Shortened slightly for a tighter look
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5), // Made handle slightly brighter
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(CupertinoIcons.paintbrush, color: Colors.white.withOpacity(0.9), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Pick $label Color',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: kSwatches.map((c) {
                  final isSelected = current.value == c.value;
                  final isLightColor = c.computeLuminance() > 0.5; 
                  
                  return GestureDetector(
                    onTap: () {
                      onPick(c);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48, 
                      height: 48,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle, 
                        border: Border.all(
                          color: isSelected 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.1),
                          width: isSelected ? 3 : 1, 
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: c.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      child: isSelected 
                          ? Icon(
                              CupertinoIcons.checkmark_alt, 
                              color: isLightColor ? Colors.black87 : Colors.white,
                              size: 28,
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