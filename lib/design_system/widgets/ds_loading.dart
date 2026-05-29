import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import 'ds_glass_card.dart';

/// Loading state widgets — standard patterns for async content.
///
/// Usage:
///   if (isLoading) const DsLoading()
///   DsLoadingOverlay(isLoading: controller.isLoading, child: content)
class DsLoading extends StatelessWidget {
  final String? message;
  final Color? color;

  const DsLoading({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Full-screen loading placeholder.
class DsLoadingPage extends StatelessWidget {
  final String? message;

  const DsLoadingPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: DsGlassCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(message!, style: AppTypography.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay that dims content while loading.
class DsLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const DsLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x4D000000),
              child: Center(child: DsLoading()),
            ),
          ),
      ],
    );
  }
}

/// Shimmer-style placeholder for list items.
class DsShimmerCard extends StatelessWidget {
  final double height;

  const DsShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.glassWhite07,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.glassWhite10),
      ),
    );
  }
}
