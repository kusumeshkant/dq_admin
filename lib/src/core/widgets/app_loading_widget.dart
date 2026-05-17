import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Standardized centered loading indicator used across all screens.
///
/// Usage:
/// ```dart
/// if (isLoading) const AppLoadingWidget()
/// ```
class AppLoadingWidget extends StatelessWidget {
  final double size;

  const AppLoadingWidget({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }
}
