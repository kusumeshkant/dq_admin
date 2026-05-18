import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dq_admin/design_system/design_system.dart';
import '../widgets/app_loading_widget.dart';
import '../../theme/app_theme.dart';
import 'paginated_controller.dart';
import 'paginated_state.dart';

/// Drop-in replacement for [ListView.builder] that handles all pagination
/// states automatically.
///
/// Attach the controller's [PaginatedController.scrollController] to
/// this widget — it is done internally. Do NOT add a separate scroll
/// listener to the same [ScrollController].
///
/// Example:
/// ```dart
/// AppPaginatedListView<ProductEntity>(
///   controller: c,
///   itemBuilder: (ctx, product, i) => ProductCard(product: product),
///   emptyTitle: 'No products yet',
///   emptySubtitle: 'Tap + to add your first product.',
/// )
/// ```
class AppPaginatedListView<T> extends StatelessWidget {
  final PaginatedController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Shown when [PaginatedState.empty].
  final String emptyTitle;
  final String? emptySubtitle;
  final Widget? emptyAction;

  final EdgeInsets? padding;
  final Widget? header; // pinned above the list items (e.g., filter chips)
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AppPaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
    this.emptyAction,
    this.padding,
    this.header,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.state.value;

      // ── Full-screen states (no items) ──────────────────────────────────────
      if (s == PaginatedState.loading) return const AppLoadingWidget();

      if (s == PaginatedState.error && controller.items.isEmpty) {
        return _ErrorState(
          message: controller.errorMsg.value,
          onRetry: controller.loadInitial,
        );
      }

      if (s == PaginatedState.empty) {
        return _EmptyState(
          title: emptyTitle,
          subtitle: emptySubtitle,
          action: emptyAction,
        );
      }

      // ── List with optional footer ──────────────────────────────────────────
      final itemCount = controller.items.length +
          (header != null ? 1 : 0) +
          (s == PaginatedState.loadingMore ? 1 : 0);

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppTheme.primary,
        child: ListView.builder(
          controller: controller.scrollController,
          padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 100),
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          shrinkWrap: shrinkWrap,
          itemCount: itemCount,
          itemBuilder: (ctx, i) {
            // Header slot
            if (header != null && i == 0) return header!;
            final offset = header != null ? 1 : 0;

            // Load-more footer
            if (i == controller.items.length + offset) {
              return const _LoadMoreFooter();
            }

            return itemBuilder(ctx, controller.items[i - offset], i - offset);
          },
        ),
      );
    });
  }
}

// ── Grid variant ──────────────────────────────────────────────────────────────

class AppPaginatedGridView<T> extends StatelessWidget {
  final PaginatedController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final String emptyTitle;
  final String? emptySubtitle;
  final EdgeInsets? padding;

  const AppPaginatedGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.state.value;

      if (s == PaginatedState.loading) return const AppLoadingWidget();

      if (s == PaginatedState.error && controller.items.isEmpty) {
        return _ErrorState(
          message: controller.errorMsg.value,
          onRetry: controller.loadInitial,
        );
      }

      if (s == PaginatedState.empty) {
        return _EmptyState(title: emptyTitle, subtitle: emptySubtitle);
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppTheme.primary,
        child: GridView.builder(
          controller: controller.scrollController,
          padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 100),
          gridDelegate: gridDelegate,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.items.length +
              (s == PaginatedState.loadingMore ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i == controller.items.length) {
              return const Center(child: _LoadMoreFooter());
            }
            return itemBuilder(ctx, controller.items[i], i);
          },
        ),
      );
    });
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const _EmptyState({required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded,
                  color: AppTheme.textSecondary, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!,
                  style: AppTypography.caption
                      .copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTypography.caption
                    .copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
