import 'package:flutter/material.dart';
import 'app_responsive.dart';

/// Renders different widget trees based on the current [DeviceType].
///
/// [mobile] is required. [tablet] and [largeTablet] are optional — if omitted
/// the next smaller layout is used.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: _MobileView(),
///   tablet: _TabletView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? largeTablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.largeTablet,
  });

  @override
  Widget build(BuildContext context) {
    return context.responsive<Widget>(
      mobile,
      tablet: tablet,
      largeTablet: largeTablet,
    );
  }
}
