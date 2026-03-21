import 'package:flutter/material.dart';

class WallpaperSettings {
  Color backgroundColor;
  Color pastDotColor;
  Color futureDotColor;
  Color todayDotColor;
  int columns;
  double dotRadius;
  double dotSpacing;
  bool showProgressLabel;
  bool fullScreenGrid;
  WallpaperTarget target;

  WallpaperSettings({
    this.backgroundColor = const Color(0xFF000000),
    this.pastDotColor = const Color(0xFFFFFFFF),
    this.futureDotColor = const Color(0xFF2A2A2A),
    this.todayDotColor = const Color(0xFFFF4500),
    this.columns = 20,
    this.dotRadius = 5.0,
    this.dotSpacing = 5.0,
    this.showProgressLabel = true,
    this.fullScreenGrid = true,
    this.target = WallpaperTarget.lockscreen,
  });

  WallpaperSettings copyWith({
    Color? backgroundColor,
    Color? pastDotColor,
    Color? futureDotColor,
    Color? todayDotColor,
    int? columns,
    double? dotRadius,
    double? dotSpacing,
    bool? showProgressLabel,
    bool? fullScreenGrid,
    WallpaperTarget? target,
  }) {
    return WallpaperSettings(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pastDotColor: pastDotColor ?? this.pastDotColor,
      futureDotColor: futureDotColor ?? this.futureDotColor,
      todayDotColor: todayDotColor ?? this.todayDotColor,
      columns: columns ?? this.columns,
      dotRadius: dotRadius ?? this.dotRadius,
      dotSpacing: dotSpacing ?? this.dotSpacing,
      showProgressLabel: showProgressLabel ?? this.showProgressLabel,
      fullScreenGrid: fullScreenGrid ?? this.fullScreenGrid,
      target: target ?? this.target,
    );
  }

  static int get dayOfYear {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return now.difference(start).inDays + 1;
  }

  static int get daysInYear {
    final now = DateTime.now();
    final isLeap = (now.year % 4 == 0 && now.year % 100 != 0) || (now.year % 400 == 0);
    return isLeap ? 366 : 365;
  }

  static double get yearProgress => dayOfYear / daysInYear;
}

enum WallpaperTarget { lockscreen, homescreen, both }

extension WallpaperTargetLabel on WallpaperTarget {
  String get label {
    switch (this) {
      case WallpaperTarget.lockscreen: return 'Lock Screen';
      case WallpaperTarget.homescreen: return 'Home Screen';
      case WallpaperTarget.both: return 'Both';
    }
  }

  IconData get icon {
    switch (this) {
      case WallpaperTarget.lockscreen: return Icons.lock_rounded;
      case WallpaperTarget.homescreen: return Icons.home_rounded;
      case WallpaperTarget.both: return Icons.layers_rounded;
    }
  }
}
