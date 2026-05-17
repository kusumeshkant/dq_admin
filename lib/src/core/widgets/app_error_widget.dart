import 'package:flutter/material.dart';
import '../responsive/app_spacing.dart';
import '../responsive/app_typography.dart';
import '../../theme/app_theme.dart';

/// Standardized error + retry widget used across all screens.
///
/// Usage:
/// ```dart
/// AppErrorWidget(
///   message: c.errorMessage.value,
///   onRetry: c.loadAnalytics,
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message.isNotEmpty ? message : 'Something went wrong.',
              style: AppTypography.body.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel, style: AppTypography.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
