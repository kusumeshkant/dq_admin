import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          final s = c.stats.value;
          return RefreshIndicator(
            onRefresh: c.loadStats,
            color: AppTheme.primary,
            child: CustomScrollView(
              slivers: [
                // ── Collapsible store header ──────────────────────────────
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A0D35),
                  title: Text(store.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
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
                          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.store_rounded,
                                        color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(store.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        if (store.address != null)
                                          Text(store.address!,
                                              style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.7),
                                                  fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Store Code + coordinates row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.35)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.tag_rounded,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            size: 11),
                                        const SizedBox(width: 3),
                                        Text(
                                          store.storeCode ??
                                              (store.id.length > 8
                                                  ? store.id.substring(store.id.length - 8)
                                                  : store.id),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (store.latitude != null && store.longitude != null) ...[
                                    const SizedBox(width: 8),
                                    Icon(Icons.location_on_rounded,
                                        color: Colors.white.withValues(alpha: 0.5),
                                        size: 12),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${store.latitude!.toStringAsFixed(4)}, ${store.longitude!.toStringAsFixed(4)}',
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 10),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Revenue featured card
                      if (s != null) ...[
                        _RevenueCard(stats: s),
                        const SizedBox(height: 12),

                        // Stats row
                        _StatsRow(stats: s),
                        const SizedBox(height: 20),
                      ],

                      // Manage Products
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
                      const SizedBox(height: 20),

                      // Recent orders
                      if (s != null && s.recentOrders.isNotEmpty) ...[
                        const Text('Recent Orders',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 10),
                        ...s.recentOrders.map(
                            (o) => _OrderRow(order: o)),
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
      padding: const EdgeInsets.only(top: 8),
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                color: AppTheme.textSecondary.withValues(alpha: 0.4), size: 40),
            const SizedBox(height: 10),
            const Text('No orders yet for this store',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800.withValues(alpha: 0.55),
            Colors.green.shade600.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Store Revenue',
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  _fmt(stats.totalRevenue),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent, size: 13),
                    const SizedBox(width: 4),
                    Text('$rate% completion rate',
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 11)),
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
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.store_rounded,
                        color: Colors.white70, size: 13),
                    SizedBox(width: 4),
                    Text('Store',
                        style:
                            TextStyle(color: Colors.white60, fontSize: 11)),
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
        const SizedBox(width: 10),
        _MiniStat(
            label: 'Pending',
            value: '${stats.pendingOrders}',
            icon: Icons.hourglass_top_rounded,
            color: Colors.orange.shade400),
        const SizedBox(width: 10),
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

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
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
      final diff = DateTime.now().difference(DateTime.parse(createdAt).toLocal());
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.receipt_rounded, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}  ·  ${_timeAgo(order.createdAt)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${order.grandTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(order.status,
                      style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
