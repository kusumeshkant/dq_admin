import 'dart:ui';
import 'package:flutter/material.dart';
import '../src/theme/app_theme.dart';
import '../src/core/responsive/app_sizes.dart';
import '../src/core/responsive/app_spacing.dart';

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
