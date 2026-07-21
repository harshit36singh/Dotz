import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'glass_container.dart';

/// Shared glass-styled date picker dialog, used for goal target/start dates
/// and the life-mode birth date.
Future<DateTime?> showGlassDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  DateTime tempDate = initialDate;

  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: kAnimDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: kAnimCurve),
        child: FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: GlassContainer(
                color: Colors.white.withOpacity(0.1),
                blur: 24,
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          surface: Colors.transparent,
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.transparent,
                        textTheme: const TextTheme(
                          bodyMedium: TextStyle(fontFamily: 'Montserrat'),
                          titleMedium: TextStyle(fontFamily: 'Montserrat'),
                        ),
                        // Replace the default solid "glow" circle on the
                        // selected day with a simple translucent glass box —
                        // squarish (kGlassRadius), thin bright rim, no fill glow.
                        datePickerTheme: DatePickerThemeData(
                          dayShape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kGlassRadius),
                              side: BorderSide(
                                color: kGlassBorderColor,
                                width: kGlassBorderWidth,
                              ),
                            ),
                          ),
                          dayBackgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Colors.white.withOpacity(0.14)
                                : Colors.transparent,
                          ),
                          dayForegroundColor:
                              WidgetStateProperty.all(Colors.white),
                          dayOverlayColor: WidgetStateProperty.all(
                            Colors.white.withOpacity(0.08),
                          ),
                          todayBackgroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          todayForegroundColor:
                              WidgetStateProperty.all(Colors.white),
                          todayBorder: BorderSide(
                            color: kGlassBorderColor,
                            width: kGlassBorderWidth,
                          ),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: tempDate,
                        firstDate: firstDate,
                        lastDate: lastDate,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(kGlassRadius),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'CONFIRM',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
