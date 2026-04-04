import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import '../stores/stores_binding.dart';
import '../stores/stores_page.dart';
import '../analytics/analytics_binding.dart';
import '../analytics/analytics_page.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardController>();
    final session = Get.find<SessionManager>();

    return ThemedBackground(
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
            if (c.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary));
            }
            if (c.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: AppTheme.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(c.errorMessage.value,
                        style:
                            const TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: c.loadStats,
                        child: const Text('Retry')),
                  ],
                ),
              );
            }

            final s = c.stats.value;
            if (s == null) return const SizedBox.shrink();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
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
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );

  Widget _sectionHeader(String title, {required VoidCallback onViewAll}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          GestureDetector(
            onTap: onViewAll,
            child: Text('View All →',
                style: TextStyle(
                    color: AppTheme.primary.withValues(alpha: 0.85),
                    fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.adminName != null
                          ? '$_greeting, ${session.adminName}!'
                          : '$_greeting!',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_todayDate  ·  ${stats.totalOrders} orders  ·  ${stats.activeStores} stores',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800.withValues(alpha: 0.6),
            Colors.green.shade600.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Revenue',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(
                  '₹${_formatRevenue(stats.totalRevenue)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Quick Access ───────────────────────────────────────────────────────────────

class _QuickAccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(
        icon: Icons.store_rounded,
        label: 'Stores',
        subtitle: 'Manage locations',
        color: Colors.blue.shade400,
        onTap: () =>
            Get.to(() => const StoresPage(), binding: StoresBinding()),
      ),
      _QuickItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        subtitle: 'View all orders',
        color: AppTheme.primary,
        onTap: () =>
            Get.to(() => const OrdersPage(), binding: OrdersBinding()),
      ),
      _QuickItem(
        icon: Icons.people_rounded,
        label: 'Staff',
        subtitle: 'Manage team',
        color: Colors.orange.shade400,
        onTap: () =>
            Get.to(() => const StaffPage(), binding: StaffBinding()),
      ),
      _QuickItem(
        icon: Icons.bar_chart_rounded,
        label: 'Analytics',
        subtitle: 'Revenue & trends',
        color: Colors.indigo.shade300,
        onTap: () =>
            Get.to(() => const AnalyticsPage(), binding: AnalyticsBinding()),
      ),
    ];

    Widget buildCard(_QuickItem item) => Expanded(
          child: GestureDetector(
            onTap: item.onTap,
            child: AppGlassCard(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(item.label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 9),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );

    return Column(
      children: [
        Row(children: [
          buildCard(items[0]),
          const SizedBox(width: 10),
          buildCard(items[1]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          buildCard(items[2]),
          const SizedBox(width: 10),
          buildCard(items[3]),
        ]),
      ],
    );
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
          Colors.amber.shade400,
          Colors.grey.shade400,
          Colors.orange.shade300,
        ];
        final rankColor =
            i < rankColors.length ? rankColors[i] : AppTheme.textSecondary;

        return AppGlassCard(
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
