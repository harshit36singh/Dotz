import 'package:flutter_test/flutter_test.dart';
import 'package:dotz/models/wallpaper_settings.dart';

void main() {
  group('WallpaperSettings.daysInYear / dayOfYear', () {
    test('daysInYear matches the Gregorian leap-year rule', () {
      final y = DateTime.now().year;
      final expected =
          ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 366 : 365;
      expect(WallpaperSettings.daysInYear, expected);
    });

    test('dayOfYear matches days elapsed since Jan 1st (inclusive)', () {
      final now = DateTime.now();
      final expected =
          now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      expect(WallpaperSettings.dayOfYear, expected);
    });

    test('yearProgress is dayOfYear / daysInYear, within (0, 1]', () {
      final progress = WallpaperSettings.yearProgress;
      expect(progress,
          closeTo(WallpaperSettings.dayOfYear / WallpaperSettings.daysInYear, 1e-9));
      expect(progress, greaterThan(0));
      expect(progress, lessThanOrEqualTo(1));
    });

    test('currentWeek stays within 1..52', () {
      expect(WallpaperSettings.currentWeek, greaterThanOrEqualTo(1));
      expect(WallpaperSettings.currentWeek, lessThanOrEqualTo(52));
    });
  });

  group('Goal mode', () {
    DateTime midnightToday() {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day);
    }

    test('a goal 10 days out leaves 10 days and totals 11', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.goal,
        goalDate: midnightToday().add(const Duration(days: 10)),
        goalName: 'Launch',
      );
      expect(settings.goalDaysLeft, 10);
      expect(settings.goalTotalDays, 11);
      expect(settings.totalDots, 11);
      expect(settings.pastDots, 1);
      expect(settings.progressLabel, '10 days left · Launch');
    });

    test('a goal in the past clamps to 0 days left / 1 total day', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.goal,
        goalDate: midnightToday().subtract(const Duration(days: 5)),
      );
      expect(settings.goalDaysLeft, 0);
      expect(settings.goalTotalDays, 1);
    });

    test('a custom start 30 days ago plus a 70-day-out end gives a 101-day range', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.goal,
        goalStartDate: midnightToday().subtract(const Duration(days: 30)),
        goalDate: midnightToday().add(const Duration(days: 70)),
      );
      // goalDaysLeft is always "today -> end", independent of start.
      expect(settings.goalDaysLeft, 70);
      expect(settings.goalTotalDays, 101);
      expect(settings.totalDots, 101);
      // pastDots reflects days elapsed since the custom start, not today.
      expect(settings.pastDots, 31);
    });

    test('a future start date leaves pastDots at 0 until it arrives', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.goal,
        goalStartDate: midnightToday().add(const Duration(days: 5)),
        goalDate: midnightToday().add(const Duration(days: 15)),
      );
      expect(settings.pastDots, 0);
    });

    test('no goal date falls back to the 100-day default', () {
      final settings = WallpaperSettings(mode: CalendarMode.goal);
      expect(settings.goalDaysLeft, 100);
      expect(settings.goalTotalDays, 100);
    });
  });

  group('Life mode', () {
    test('100 days lived out of an 80-year expectancy', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.life,
        lifeExpectancyYears: 80,
        birthDate: DateTime.now().subtract(const Duration(days: 100)),
      );
      expect(settings.lifeTotalDays, 80 * 365);
      expect(settings.lifeDaysLived, 100);
      expect(settings.lifeDaysLeft, 80 * 365 - 100);
      expect(settings.totalDots, 80 * 365);
      expect(settings.pastDots, 100);
    });

    test('days lived clamps to the total when birth predates the expectancy window', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.life,
        lifeExpectancyYears: 1,
        birthDate: DateTime.now().subtract(const Duration(days: 100000)),
      );
      expect(settings.lifeDaysLived, settings.lifeTotalDays);
      expect(settings.lifeDaysLeft, 0);
      expect(settings.lifeProgress, 1);
    });

    test('no birth date means zero days lived', () {
      final settings = WallpaperSettings(mode: CalendarMode.life);
      expect(settings.lifeDaysLived, 0);
      expect(settings.lifeProgress, 0);
    });

    test('weeks unit switches totalDots/pastDots to a week-based grid', () {
      final settings = WallpaperSettings(
        mode: CalendarMode.life,
        lifeExpectancyYears: 80,
        lifeUnit: LifeUnit.weeks,
        birthDate: DateTime.now().subtract(const Duration(days: 70)), // 10 weeks
      );
      expect(settings.lifeTotalWeeks, 80 * 52);
      expect(settings.lifeWeeksLived, 10);
      expect(settings.totalDots, 80 * 52);
      expect(settings.pastDots, 10);
      // Day-based getters stay available regardless of the display unit.
      expect(settings.lifeDaysLived, 70);
    });
  });

  group('Year / weekly totals', () {
    test('year mode totals track the current calendar year', () {
      final settings = WallpaperSettings(mode: CalendarMode.year);
      expect(settings.totalDots, WallpaperSettings.daysInYear);
      expect(settings.pastDots, WallpaperSettings.dayOfYear - 1);
    });

    test('weekly mode always has 52 total dots', () {
      final settings = WallpaperSettings(mode: CalendarMode.weekly);
      expect(settings.totalDots, 52);
      expect(settings.pastDots, WallpaperSettings.currentWeek - 1);
    });
  });

  group('copyWith', () {
    test('overrides only the requested fields', () {
      final base = WallpaperSettings(columns: 20, mode: CalendarMode.year);
      final copy = base.copyWith(columns: 12);
      expect(copy.columns, 12);
      expect(copy.mode, CalendarMode.year);
    });
  });
}
