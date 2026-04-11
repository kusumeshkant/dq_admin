import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/app_loading_widget.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/entity/order_entity.dart';
import '../../service_core/auth/session_manager.dart';
import '../../theme/app_theme.dart';
import '../order_detail/order_detail_binding.dart';
import '../order_detail/order_detail_page.dart';
import '../orders/orders_binding.dart';
import '../orders/orders_page.dart';
import '../staff/staff_binding.dart';
import '../staff/staff_page.dart';
import '../store_detail/store_detail_binding.dart';
import '../store_detail/store_detail_page.dart';
import '../stores/stores_binding.dart';
import '../stores/stores_page.dart';
import '../analytics/analytics_binding.dart';
import '../analytics/analytics_page.dart';
import '../staff_management/staff_management_binding.dart';
import '../staff_management/staff_management_page.dart';
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
                const SizedBox(height: 16),

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
                    onViewAll: () => Get.to(
                        () => const StoresPage(),
                        binding: StoresBinding()),
                  ),
                  const SizedBox(height: 10),
                  _TopStoresList(topStores: s.topStores),
                  const SizedBox(height: 20),
                ],

                // ── Recent orders ────────────────────────────────────────
                if (s.recentOrders.isNotEmpty) ...[
                  _sectionHeader(
                    'Recent Orders',
                    onViewAll: () => Get.to(
                        () => const OrdersPage(),
                        binding: OrdersBinding()),
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
            child: Obx(() => Column(
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
                  ],
                )),
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
            Colors.green.shade800.withValues(alpha: 0.6),
            Colors.green.shade600.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                        color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('$completionRate% completion rate',
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.currency_rupee_rounded,
                        color: Colors.white, size: 14),
                    Text('Revenue',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('${stats.completedOrders}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const Text('completed',
                  style: TextStyle(color: Colors.white54, fontSize: 10)),
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
          color: Colors.orange.shade400,
        ),
        const SizedBox(width: 10),
        _MiniStatCard(
          label: 'Stores',
          value: '${stats.activeStores}',
          icon: Icons.store_rounded,
          color: Colors.blue.shade400,
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
// 5 items — layout: 2 + 2 + 1 (Staff as full-width bottom tile)

class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allItems = [
      _QuickItem(
        icon: Icons.store_rounded,
        label: 'Stores',
        subtitle: 'Manage locations & products',
        color: Colors.blue.shade400,
        onTap: () => Get.to(() => const StoresPage(), binding: StoresBinding()),
      ),
      _QuickItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        subtitle: 'View all orders',
        color: AppTheme.primary,
        onTap: () => Get.to(() => const OrdersPage(), binding: OrdersBinding()),
      ),
      _QuickItem(
        icon: Icons.bar_chart_rounded,
        label: 'Analytics',
        subtitle: 'Revenue & trends',
        color: Colors.indigo.shade300,
        onTap: () =>
            Get.to(() => const AnalyticsPage(), binding: AnalyticsBinding()),
      ),
      _QuickItem(
        icon: Icons.person_add_rounded,
        label: 'Invite Staff',
        subtitle: 'Add team members',
        color: Colors.teal.shade300,
        onTap: () => Get.to(
          () => const StaffManagementPage(),
          binding: StaffManagementBinding(),
        ),
      ),
      _QuickItem(
        icon: Icons.people_rounded,
        label: 'Staff',
        subtitle: 'View and manage your team',
        color: Colors.purple.shade300,
        onTap: () => Get.to(() => const StaffPage(), binding: StaffBinding()),
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
        _WideQuickTile(item: allItems[4]),
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

/// Full-width horizontal quick-access tile — used as the bottom row
/// when the grid has an odd number of items.
class _WideQuickTile extends StatelessWidget {
  final _QuickItem item;

  const _WideQuickTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
        child: Row(
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
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: AppTypography.bodySmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: item.color, size: 13),
          ],
        ),
      ),
    );
  }
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
          Colors.amber.shade400,
          Colors.grey.shade400,
          Colors.orange.shade300,
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
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: rankColor.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: rankColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store_rounded,
                          color: AppTheme.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sr.store?.name ?? '—',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text('${sr.orderCount} orders',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '₹${_fmt(sr.revenue)}',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    if (sr.store != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                          size: 11),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
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
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _statusColor(o.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_rounded,
                      color: _statusColor(o.status), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${o.id.substring(o.id.length > 8 ? o.id.length - 8 : 0)}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${o.storeName ?? '—'}  ·  ${o.items.length} item${o.items.length == 1 ? '' : 's'}  ·  ${_timeAgo(o.createdAt)}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${o.grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 4),
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

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => Colors.grey.shade500,
      'preparing' => Colors.orange.shade600,
      'ready' => Colors.blue.shade500,
      'completed' => Colors.green.shade600,
      'cancelled' => Colors.red.shade600,
      _ => Colors.grey.shade500,
    };
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toLowerCase()) {
      'pending' => Colors.grey.shade500,
      'preparing' => Colors.orange.shade600,
      'ready' => Colors.blue.shade500,
      'completed' => Colors.green.shade600,
      'cancelled' => Colors.red.shade600,
      _ => Colors.grey.shade500,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status,
          style:
              TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}
