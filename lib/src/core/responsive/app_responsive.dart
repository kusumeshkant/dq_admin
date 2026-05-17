import 'package:flutter/material.dart';

/// Device breakpoints (logical pixels, width-based).
enum DeviceType { mobile, tablet, largeTablet }

/// Breakpoint thresholds.
abstract class Breakpoints {
  static const double tablet = 600;
  static const double largeTablet = 900;
}

/// BuildContext extension — all responsive helpers live here.
extension AppResponsive on BuildContext {
  // ── Device type ───────────────────────────────────────────
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceType get deviceType {
    final w = screenWidth;
    if (w >= Breakpoints.largeTablet) return DeviceType.largeTablet;
    if (w >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isLargeTablet => deviceType == DeviceType.largeTablet;
  bool get isTabletOrLarger => !isMobile;

  // ── Type-safe responsive value ────────────────────────────
  /// Returns [mobile] on phones, [tablet] on tablets (falls back to [mobile]
  /// if omitted), [largeTablet] on large tablets (falls back to [tablet] then
  /// [mobile] if omitted).
  T responsive<T>(T mobile, {T? tablet, T? largeTablet}) {
    return switch (deviceType) {
      DeviceType.largeTablet => largeTablet ?? tablet ?? mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.mobile => mobile,
    };
  }

  // ── Layout helpers ────────────────────────────────────────
  /// Horizontal padding for page-level content.
  double get pagePadding => responsive(16.0, tablet: 24.0, largeTablet: 32.0);

  /// Maximum content width — centers content on wide screens.
  double get maxContentWidth => responsive(
        double.infinity,
        tablet: 720,
        largeTablet: 960,
      );

  /// Number of grid columns for card grids.
  int get gridColumns => responsive(1, tablet: 2, largeTablet: 3);

  /// Quick-access / stat card columns.
  int get statColumns => responsive(2, tablet: 3, largeTablet: 4);
}
