import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../core/widgets/app_loading_widget.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../theme/app_theme.dart';
import '../order_detail/order_detail_binding.dart';
import '../order_detail/order_detail_page.dart';
import '../products/products_binding.dart';
import '../products/products_page.dart';
import 'store_detail_controller.dart';

class StoreDetailPage extends StatelessWidget {
  final StoreEntity store;
  const StoreDetailPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StoreDetailController>();
    // Adapt sliver header height to screen size
    final expandedHeight =
        context.responsive(180.0, tablet: 200.0, largeTablet: 220.0);
    final hPad = context.pagePadding;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          if (c.isLoading.value) return const AppLoadingWidget();
          final s = c.stats.value;
          return RefreshIndicator(
            onRefresh: c.loadStats,
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: [
                // ── Collapsible store header ──────────────────────────────
                SliverAppBar(
                  expandedHeight: expandedHeight,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A0D35),
                  title: Text(store.name,
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.7),
                            const Color(0xFF1A0D35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              hPad,
                              AppSizes.appBarHeight,
                              hPad,
                              AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: AppSizes.avatarMd,
                                    height: AppSizes.avatarMd,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMd),
                                    ),
                                    child: const Icon(Icons.store_rounded,
                                        color: Colors.white,
                                        size: AppSizes.iconMd),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(store.name,
                                            style: AppTypography.titleSmall
                                                .copyWith(color: Colors.white)),
                                        if (store.address != null)
                                          Text(store.address!,
                                              style: AppTypography.caption
                                                  .copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.7)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm + 2),
                              // Store Code + coordinates row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusSm - 2),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.35)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.tag_rounded,
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            size: 11),
                                        const SizedBox(width: 3),
                                        Text(
                                          store.storeCode ??
                                              (store.id.length > 8
                                                  ? store.id.substring(
                                                      store.id.length - 8)
                                                  : store.id),
                                          style: AppTypography.caption
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (store.latitude != null &&
                                      store.longitude != null) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(Icons.location_on_rounded,
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        size: 12),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${store.latitude!.toStringAsFixed(4)}, ${store.longitude!.toStringAsFixed(4)}',
                                      style: AppTypography.caption.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Body content ─────────────────────────────────────────
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, AppSpacing.lg, hPad, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (s != null) ...[
                        _RevenueCard(stats: s),
                        const SizedBox(height: AppSpacing.md),
                        _StatsRow(stats: s),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      _ActionTile(
                        icon: Icons.inventory_2_rounded,
                        label: 'Manage Products',
                        subtitle: 'View, add and edit inventory',
                        color: Colors.orange,
                        onTap: () => Get.to(
                          () => ProductsPage(store: store),
                          binding: ProductsBinding(store: store),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (s != null && s.recentOrders.isNotEmpty) ...[
                        Text('Recent Orders',
                            style: AppTypography.bodyLarge
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm + 2),
                        ...s.recentOrders.map((o) => _OrderRow(order: o)),
                      ],

                      if (s != null && s.recentOrders.isEmpty)
                        _emptyOrders(),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyOrders() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl + AppSpacing.sm),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                size: AppSizes.iconXl - 4),
            const SizedBox(height: AppSpacing.sm + 2),
            Text('No orders yet for this store',
                style: AppTypography.bodySmall
                    .copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Revenue Card ───────────────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final StoreStatsEntity stats;
  const _RevenueCard({required this.stats});

  String _fmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final rate = stats.totalOrders > 0
        ? (stats.completedOrders / stats.totalOrders * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl - 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800.withValues(alpha: 0.55),
            Colors.green.shade600.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Store Revenue',
                    style: AppTypography.label
                        .copyWith(color: Colors.white60)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _fmt(stats.totalRevenue),
                  style: AppTypography.statLarge
                      .copyWith(letterSpacing: -0.5),
                ),
                const SizedBox(height: AppSpacing.sm - 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent, size: 13),
                    const SizedBox(width: AppSpacing.xs),
                    Text('$rate% completion rate',
                        style: AppTypography.caption
                            .copyWith(color: Colors.greenAccent)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.store_rounded,
                        color: Colors.white70, size: 13),
                    SizedBox(width: AppSpacing.xs),
                    Text('Store',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('${stats.completedOrders}',
                  style: AppTypography.statMedium
                      .copyWith(color: Colors.white, fontSize: 22)),
              Text('completed',
                  style: AppTypography.caption
                      .copyWith(color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final StoreStatsEntity stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
            label: 'Total Orders',
            value: '${stats.totalOrders}',
            icon: Icons.receipt_long_rounded,
            color: AppTheme.primary),
        const SizedBox(width: AppSpacing.sm + 2),
        _MiniStat(
            label: 'Pending',
            value: '${stats.pendingOrders}',
            icon: Icons.hourglass_top_rounded,
            color: Colors.orange.shade400),
        const SizedBox(width: AppSpacing.sm + 2),
        _MiniStat(
            label: 'Completed',
            value: '${stats.completedOrders}',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.blue.shade400),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSizes.iconLg - 2,
              height: AppSizes.iconLg - 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconSm - 3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: AppTypography.statMedium.copyWith(color: color)),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

// ── Action Tile ────────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconMd - 2),
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.labelSmall),
                ],
              ),
            ),
            Container(
              width: AppSizes.iconLg - 2,
              height: AppSizes.iconLg - 2,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: color, size: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Row ──────────────────────────────────────────────────────────────────

class _OrderRow extends StatelessWidget {
  final OrderEntity order;
  const _OrderRow({required this.order});

  Color _statusColor(String s) => switch (s.toLowerCase()) {
        'pending' => Colors.grey.shade500,
        'preparing' => Colors.orange.shade600,
        'ready' => Colors.blue.shade500,
        'completed' => Colors.green.shade600,
        'cancelled' => Colors.red.shade600,
        _ => Colors.grey.shade500,
      };

  String _timeAgo(String createdAt) {
    try {
      final diff =
          DateTime.now().difference(DateTime.parse(createdAt).toLocal());
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return GestureDetector(
      onTap: () => Get.to(
        () => OrderDetailPage(order: order),
        binding: OrderDetailBinding(order: order),
      ),
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm + 3),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconXl - 6,
              height: AppSizes.iconXl - 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm + 2),
              ),
              child: Icon(Icons.receipt_rounded,
                  color: color, size: AppSizes.iconMd - 6),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}  ·  ${_timeAgo(order.createdAt)}',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${order.grandTotal.toStringAsFixed(0)}',
                    style: AppTypography.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm - 1, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm - 2),
                    border:
                        Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(order.status,
                      style: AppTypography.caption.copyWith(
                          color: color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
