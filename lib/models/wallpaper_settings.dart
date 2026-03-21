import 'package:flutter/material.dart';

class WallpaperSettings {
  Color backgroundColor;
  Color pastDotColor;
  Color futureDotColor;
  Color todayDotColor;
  int columns;
  bool showProgressLabel;
  WallpaperTarget target;

  WallpaperSettings({
    this.backgroundColor = const Color(0xFF000000),
    this.pastDotColor    = const Color(0xFFFFFFFF),
    this.futureDotColor  = const Color(0xFF2A2A2A),
    this.todayDotColor   = const Color(0xFFFF4500),
    this.columns         = 20,
    this.showProgressLabel = true,
    this.target          = WallpaperTarget.lockscreen,
  });

  WallpaperSettings copyWith({
    Color? backgroundColor,
    Color? pastDotColor,
    Color? futureDotColor,
    Color? todayDotColor,
    int? columns,
    bool? showProgressLabel,
    WallpaperTarget? target,
  }) {
    return WallpaperSettings(
      backgroundColor:   backgroundColor   ?? this.backgroundColor,
      pastDotColor:      pastDotColor      ?? this.pastDotColor,
      futureDotColor:    futureDotColor    ?? this.futureDotColor,
      todayDotColor:     todayDotColor     ?? this.todayDotColor,
      columns:           columns           ?? this.columns,
      showProgressLabel: showProgressLabel ?? this.showProgressLabel,
      target:            target            ?? this.target,
    );
  }

  static int get dayOfYear {
    final now = DateTime.now();
    return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
  }

  static int get daysInYear {
    final y = DateTime.now().year;
    return ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 366 : 365;
  }

  static double get yearProgress => dayOfYear / daysInYear;
}

enum WallpaperTarget { lockscreen, homescreen, both }

extension WallpaperTargetLabel on WallpaperTarget {
  String get label {
    switch (this) {
      case WallpaperTarget.lockscreen: return 'Lock Screen';
      case WallpaperTarget.homescreen: return 'Home Screen';
      case WallpaperTarget.both:       return 'Both';
    }
  }
  IconData get icon {
    switch (this) {
      case WallpaperTarget.lockscreen: return Icons.lock_rounded;
      case WallpaperTarget.homescreen: return Icons.home_rounded;
      case WallpaperTarget.both:       return Icons.layers_rounded;
    }
  }
}
