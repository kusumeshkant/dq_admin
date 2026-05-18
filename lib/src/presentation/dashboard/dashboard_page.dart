import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/app_loading_widget.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/entity/order_entity.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/subscription/subscription_manager.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../order_detail/order_detail_binding.dart';
import '../order_detail/order_detail_page.dart';
import '../store_detail/store_detail_binding.dart';
import '../store_detail/store_detail_page.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final session = Get.find<SessionManager>();

    return PopScope(
      canPop: false, // Dashboard is root — back button exits app, not back to onboarding
      child: ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Admin Panel'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign out',
              onPressed: c.logout,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: c.loadStats,
          color: AppTheme.primary,
          child: Obx(() {
            if (c.isLoading.value) return const AppLoadingWidget();
            if (c.errorMessage.value.isNotEmpty) {
              return AppErrorWidget(
                message: c.errorMessage.value,
                onRetry: c.loadStats,
              );
            }

            final s = c.stats.value;
            if (s == null) return const SizedBox.shrink();

            return ListView(
              padding: EdgeInsets.fromLTRB(
                  context.pagePadding, 4, context.pagePadding, 40),
              children: [
                // ── Greeting header ──────────────────────────────────────
                _GreetingHeader(session: session, stats: s),
                const SizedBox(height: 12),

                // ── Subscription alert banner (shown when action needed) ──
                _SubscriptionBanner(),
                const SizedBox(height: 4),

                // ── Revenue featured card ────────────────────────────────
                _RevenueCard(stats: s),
                const SizedBox(height: 16),

                // ── Stats row ────────────────────────────────────────────
                _StatsRow(stats: s),
                const SizedBox(height: 20),

                // ── Quick access ─────────────────────────────────────────
                _sectionTitle('Quick Access'),
                const SizedBox(height: 10),
                _QuickAccess(),
                const SizedBox(height: 20),

                // ── Top stores ───────────────────────────────────────────
                if (s.topStores.isNotEmpty) ...[
                  _sectionHeader(
                    'Top Stores',
                    onViewAll: () => Get.toNamed(AppRoutes.stores),
                  ),
                  const SizedBox(height: 10),
                  _TopStoresList(topStores: s.topStores),
                  const SizedBox(height: 20),
                ],

                // ── Recent orders ────────────────────────────────────────
                if (s.recentOrders.isNotEmpty) ...[
                  _sectionHeader(
                    'Recent Orders',
                    onViewAll: () => Get.toNamed(AppRoutes.orders),
                  ),
                  const SizedBox(height: 10),
                  _RecentOrdersList(orders: s.recentOrders),
                ],
              ],
            );
          }),
        ),
      ),
    ));
  }

  Widget _sectionTitle(String title) => Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold));

  Widget _sectionHeader(String title, {required VoidCallback onViewAll}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onViewAll,
            child: Text('View All →',
                style: AppTypography.label.copyWith(
                    color: AppTheme.primary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );
}

// ── Greeting Header ────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final SessionManager session;
  final DashboardStatsEntity stats;

  const _GreetingHeader({required this.session, required this.stats});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _todayDate {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Obx(() {
              final sub = Get.find<SubscriptionManager>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.adminName != null
                        ? '$_greeting, ${session.adminName}!'
                        : '$_greeting!',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_todayDate  ·  ${stats.totalOrders} orders  ·  ${stats.activeStores} stores',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 6),
                  _PlanBadge(info: sub.info),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Revenue Featured Card ──────────────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  final DashboardStatsEntity stats;
  const _RevenueCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final completionRate = stats.totalOrders > 0
        ? (stats.completedOrders / stats.totalOrders * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.6),
            AppColors.success.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Revenue',
                    style: AppTypography.label
                        .copyWith(color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: AppSpacing.sm - 2),
                Text(
                  '₹${_formatRevenue(stats.totalRevenue)}',
                  style: AppTypography.statLarge
                      .copyWith(letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 14),
                    const SizedBox(width: AppSpacing.xs),
                    Text('$completionRate% completion rate',
                        style: AppTypography.label
                            .copyWith(color: AppColors.success)),
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
                    horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs + 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee_rounded,
                        color: Colors.white, size: 14),
                    Text('Revenue',
                        style: AppTypography.caption
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('${stats.completedOrders}',
                  style: AppTypography.statSmall
                      .copyWith(color: Colors.white)),
              Text('completed',
                  style: AppTypography.caption
                      .copyWith(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRevenue(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardStatsEntity stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStatCard(
          label: 'Total Orders',
          value: '${stats.totalOrders}',
          icon: Icons.receipt_long_rounded,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 10),
        _MiniStatCard(
          label: 'Pending',
          value: '${stats.pendingOrders}',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
        ),
        const SizedBox(width: 10),
        _MiniStatCard(
          label: 'Stores',
          value: '${stats.activeStores}',
          icon: Icons.store_rounded,
          color: AppColors.info,
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
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
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconMd - 8),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Text(value, style: AppTypography.statMedium),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

// ── Quick Access ───────────────────────────────────────────────────────────────
//
// Products are intentionally absent here. They live inside a store:
//   Dashboard → Stores → Store Detail → Manage Products
//
// 6 items — layout: 2 + 2 + 2 on mobile, uniform grid on tablet

class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allItems = [
      _QuickItem(
        icon: Icons.store_rounded,
        label: 'Stores',
        subtitle: 'Manage locations & products',
        color: AppColors.info,
        onTap: () => Get.toNamed(AppRoutes.stores),
      ),
      _QuickItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        subtitle: 'View all orders',
        color: AppTheme.primary,
        onTap: () => Get.toNamed(AppRoutes.orders),
      ),
      _QuickItem(
        icon: Icons.bar_chart_rounded,
        label: 'Analytics',
        subtitle: 'Revenue & trends',
        color: AppColors.primary,
        onTap: () => Get.toNamed(AppRoutes.analytics),
      ),
      _QuickItem(
        icon: Icons.person_add_rounded,
        label: 'Invite Staff',
        subtitle: 'Add team members',
        color: AppColors.info,
        onTap: () => Get.toNamed(AppRoutes.staffManagement),
      ),
      _QuickItem(
        icon: Icons.people_rounded,
        label: 'Staff',
        subtitle: 'View and manage your team',
        color: AppColors.primary,
        onTap: () => Get.toNamed(AppRoutes.staff),
      ),
      _QuickItem(
        icon: Icons.workspace_premium_rounded,
        label: 'Subscription',
        subtitle: 'Plan, features & usage',
        color: AppColors.warning,
        onTap: () => Get.toNamed(AppRoutes.subscription),
      ),
      _QuickItem(
        icon: Icons.verified_user_rounded,
        label: 'Permissions',
        subtitle: 'Requests, approvals & logs',
        color: AppColors.success,
        onTap: () => Get.toNamed(AppRoutes.permissions),
      ),
    ];

    // On tablet+: all 5 as uniform grid cards. On mobile: 2+2+1 layout.
    if (context.isTabletOrLarger) {
      return _QuickAccessGrid(items: allItems, columns: context.statColumns);
    }

    // Mobile: 2×2 grid + full-width Staff tile
    Widget buildCard(_QuickItem item) => Expanded(
          child: GestureDetector(
            onTap: item.onTap,
            child: AppGlassCard(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg, horizontal: AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    width: AppSizes.iconXl - 4,
                    height: AppSizes.iconXl - 4,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Icon(item.icon, color: item.color, size: AppSizes.iconMd - 4),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(item.label,
                      style: AppTypography.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );

    return Column(
      children: [
        Row(children: [
          buildCard(allItems[0]),
          const SizedBox(width: AppSpacing.sm + 2),
          buildCard(allItems[1]),
        ]),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(children: [
          buildCard(allItems[2]),
          const SizedBox(width: AppSpacing.sm + 2),
          buildCard(allItems[3]),
        ]),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(children: [
          buildCard(allItems[4]),
          const SizedBox(width: AppSpacing.sm + 2),
          buildCard(allItems[5]),
        ]),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(children: [
          buildCard(allItems[6]),
          const SizedBox(width: AppSpacing.sm + 2),
          const Expanded(child: SizedBox()),
        ]),
      ],
    );
  }
}

/// Responsive grid for tablet — renders items in [columns] columns.
class _QuickAccessGrid extends StatelessWidget {
  final List<_QuickItem> items;
  final int columns;

  const _QuickAccessGrid({required this.items, required this.columns});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += columns) {
      final rowItems = items.skip(i).take(columns).toList();
      rows.add(Row(
        children: [
          for (int j = 0; j < rowItems.length; j++) ...[
            if (j > 0) const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: GestureDetector(
                onTap: rowItems[j].onTap,
                child: AppGlassCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      Container(
                        width: AppSizes.iconXl - 4,
                        height: AppSizes.iconXl - 4,
                        decoration: BoxDecoration(
                          color: rowItems[j].color.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: Icon(rowItems[j].icon,
                            color: rowItems[j].color,
                            size: AppSizes.iconMd - 4),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(rowItems[j].label,
                          style: AppTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 2),
                      Text(rowItems[j].subtitle,
                          style: AppTypography.caption,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // Fill empty cells in the last row
          for (int k = rowItems.length; k < columns; k++) ...[
            const SizedBox(width: AppSpacing.sm + 2),
            const Expanded(child: SizedBox()),
          ],
        ],
      ));
      if (i + columns < items.length) {
        rows.add(const SizedBox(height: AppSpacing.sm + 2));
      }
    }
    return Column(children: rows);
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _QuickItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}


// ── Top Stores ─────────────────────────────────────────────────────────────────

class _TopStoresList extends StatelessWidget {
  final List<StoreRevenueEntity> topStores;
  const _TopStoresList({required this.topStores});

  @override
  Widget build(BuildContext context) {
    final maxRevenue =
        topStores.isEmpty ? 1.0 : topStores.first.revenue.clamp(1.0, double.infinity);

    return Column(
      children: List.generate(topStores.length, (i) {
        final sr = topStores[i];
        final ratio = (sr.revenue / maxRevenue).clamp(0.0, 1.0);
        final rankColors = [
          AppColors.warning,
          AppColors.neutral,
          AppColors.warning,
        ];
        final rankColor =
            i < rankColors.length ? rankColors[i] : AppTheme.textSecondary;

        return GestureDetector(
          onTap: sr.store != null
              ? () => Get.to(
                    () => StoreDetailPage(store: sr.store!),
                    binding: StoreDetailBinding(store: sr.store!),
                  )
              : null,
          child: AppGlassCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: AppSizes.iconLg,
                      height: AppSizes.iconLg,
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: rankColor.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: AppTypography.label.copyWith(
                                color: rankColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Container(
                      width: AppSizes.iconLg,
                      height: AppSizes.iconLg,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(Icons.store_rounded,
                          color: AppTheme.primary, size: AppSizes.iconSm - 2),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sr.store?.name ?? '—',
                              style: AppTypography.bodySmall
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text('${sr.orderCount} orders',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    Text(
                      '₹${_fmt(sr.revenue)}',
                      style: AppTypography.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                    if (sr.store != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          size: 11),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm - 4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        rankColor.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Recent Orders ──────────────────────────────────────────────────────────────

class _RecentOrdersList extends StatelessWidget {
  final List<OrderEntity> orders;
  const _RecentOrdersList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: orders.take(5).map((o) {
        return GestureDetector(
          onTap: () => Get.to(
            () => OrderDetailPage(order: o),
            binding: OrderDetailBinding(order: o),
          ),
          child: AppGlassCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            child: Row(
              children: [
                Container(
                  width: AppSizes.avatarSm,
                  height: AppSizes.avatarSm,
                  decoration: BoxDecoration(
                    color: AppColors.statusColor(o.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
                  ),
                  child: Icon(Icons.receipt_rounded,
                      color: AppColors.statusColor(o.status), size: AppSizes.iconMd - 6),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${o.id.substring(o.id.length > 8 ? o.id.length - 8 : 0)}',
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${o.storeName ?? '—'}  ·  ${o.items.length} item${o.items.length == 1 ? '' : 's'}  ·  ${_timeAgo(o.createdAt)}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${o.grandTotal.toStringAsFixed(0)}',
                        style: AppTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.xs),
                    _StatusChip(status: o.status),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (_) {
      return '';
    }
  }
}

// ── Plan Badge ─────────────────────────────────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  final dynamic info; // SubscriptionInfo

  const _PlanBadge({required this.info});

  @override
  Widget build(BuildContext context) {
    if (info.status == 'loading' || info.planName.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = _badgeColor(info.status);
    final label = info.planDisplayName.isNotEmpty
        ? info.planDisplayName
        : _fmt(info.planName);
    final suffix = info.isTrial && info.trialDaysLeft != null
        ? ' · ${info.trialDaysLeft}d left'
        : '';

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.subscription),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_rounded, color: color, size: 11),
            const SizedBox(width: 4),
            Text(
              '$label$suffix',
              style: AppTypography.caption.copyWith(
                  color: color, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(String status) => switch (status) {
        'trial'          => AppColors.info,
        'active'         => AppColors.success,
        'grace_period'   => AppColors.warning,
        'expired'        => AppColors.error,
        'cancelled'      => AppColors.error,
        'admin_override' => AppColors.primary,
        'grandfathered'  => AppColors.warning,
        _                => AppColors.neutral,
      };

  String _fmt(String name) {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}

// ── Subscription Banner ────────────────────────────────────────────────────────

class _SubscriptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sub = Get.find<SubscriptionManager>();
    return Obx(() {
      final info = sub.info;

      String? message;
      Color? color;
      IconData? icon;

      if (info.isExpired) {
        message = 'Your subscription has expired. Renew to restore access.';
        color = AppColors.error;
        icon = Icons.error_rounded;
      } else if (info.isGracePeriod) {
        final days = info.gracePeriodEndsAt != null
            ? info.gracePeriodEndsAt!.difference(DateTime.now()).inDays
            : 0;
        message =
            'Payment overdue — $days day${days == 1 ? '' : 's'} of grace period remaining.';
        color = AppColors.warning;
        icon = Icons.warning_rounded;
      } else if (info.isTrial && (info.trialDaysLeft ?? 99) <= 5) {
        final d = info.trialDaysLeft!;
        message = d == 0
            ? 'Your trial expires today — upgrade to keep access.'
            : 'Trial expires in $d day${d == 1 ? '' : 's'} — upgrade to continue.';
        color = AppColors.info;
        icon = Icons.info_rounded;
      }

      if (message == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.subscription),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color!.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('View →',
                  style: AppTypography.caption.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    });
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status,
          style: AppTypography.caption.copyWith(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}
