import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../theme/app_theme.dart';
import 'analytics_controller.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _periodDays = 7; // 7 | 14 | 30

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AnalyticsController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Analytics'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: c.loadAnalytics,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Obx(() {
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
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: c.loadAnalytics,
                      child: const Text('Retry')),
                ],
              ),
            );
          }
          final a = c.analytics.value;
          if (a == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: c.loadAnalytics,
            color: AppTheme.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                // ── Revenue hero ─────────────────────────────────────────
                _RevenueHero(analytics: a),
                const SizedBox(height: 12),

                // ── KPI chips row ────────────────────────────────────────
                _KpiChipsRow(analytics: a),
                const SizedBox(height: 20),

                // ── Business insights ────────────────────────────────────
                _BusinessInsights(analytics: a),
                const SizedBox(height: 20),

                // ── Revenue chart ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Revenue Trend',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    _PeriodSelector(
                      selected: _periodDays,
                      onChanged: (v) => setState(() => _periodDays = v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _RevenueChart(
                    dailyRevenue: a.dailyRevenue, periodDays: _periodDays),
                const SizedBox(height: 20),

                // ── Top products ─────────────────────────────────────────
                const Text('Top Products by Revenue',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 10),
                _TopProductsList(
                    products: a.topProducts,
                    totalRevenue: a.totalRevenue),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Revenue Hero ──────────────────────────────────────────────────────────────

class _RevenueHero extends StatelessWidget {
  final StoreAnalyticsEntity analytics;
  const _RevenueHero({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final wow = analytics.weekOverWeekPct;
    final isUp = wow != null && wow >= 0;
    final wowColor = wow == null
        ? Colors.white54
        : isUp
            ? Colors.greenAccent
            : Colors.redAccent;
    final wowText = wow == null
        ? 'No prior week data'
        : '${isUp ? '↑' : '↓'} ${wow.abs().toStringAsFixed(1)}% vs last week';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1060),
            AppTheme.primary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Revenue',
              style: TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            '₹${_fmt(analytics.totalRevenue)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: wowColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: wowColor.withValues(alpha: 0.4)),
                ),
                child: Text(wowText,
                    style: TextStyle(
                        color: wowColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Text(
                'This week: ₹${_fmt(analytics.thisWeekRevenue)}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── KPI Chips ─────────────────────────────────────────────────────────────────

class _KpiChipsRow extends StatelessWidget {
  final StoreAnalyticsEntity analytics;
  const _KpiChipsRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _KpiData('Orders', '${analytics.totalOrders}',
          Icons.receipt_long_rounded, AppTheme.primary),
      _KpiData(
          'Completion',
          '${analytics.completionRate.toStringAsFixed(0)}%',
          Icons.check_circle_outline_rounded,
          Colors.green.shade400),
      _KpiData(
          'Cancellation',
          '${analytics.cancellationRate.toStringAsFixed(0)}%',
          Icons.cancel_outlined,
          analytics.cancellationRate > 15
              ? Colors.red.shade400
              : Colors.orange.shade400),
      _KpiData('Avg Order', '₹${analytics.avgOrderValue.toStringAsFixed(0)}',
          Icons.shopping_bag_outlined, Colors.blue.shade400),
      _KpiData('Avg Items', analytics.avgItemsPerOrder.toStringAsFixed(1),
          Icons.inventory_2_outlined, Colors.purple.shade300),
      _KpiData('Units Sold', '${analytics.totalUnitsSold}',
          Icons.sell_outlined, Colors.teal.shade300),
      _KpiData(
          'Low Stock',
          '${analytics.lowStockCount}',
          Icons.warning_amber_rounded,
          analytics.lowStockCount > 0
              ? Colors.red.shade400
              : Colors.green.shade400),
    ];

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _KpiChip(data: chips[i]),
      ),
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiChip extends StatelessWidget {
  final _KpiData data;
  const _KpiChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, color: data.color, size: 18),
          const SizedBox(height: 4),
          Text(data.value,
              style: TextStyle(
                  color: data.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(data.label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Business Insights ─────────────────────────────────────────────────────────

class _BusinessInsights extends StatelessWidget {
  final StoreAnalyticsEntity analytics;
  const _BusinessInsights({required this.analytics});

  @override
  Widget build(BuildContext context) {
    // Best day from daily revenue
    DailyRevenueStatEntity? bestDay;
    for (final d in analytics.dailyRevenue) {
      if (bestDay == null || d.revenue > bestDay.revenue) bestDay = d;
    }

    final wow = analytics.weekOverWeekPct;
    final trend = wow == null
        ? '— No trend data'
        : wow >= 10
            ? '🚀 Strong growth this week'
            : wow >= 0
                ? '↑ Positive trend this week'
                : wow >= -10
                    ? '↓ Slight dip this week'
                    : '⚠ Revenue down this week';

    final trendColor = wow == null
        ? AppTheme.textSecondary
        : wow >= 0
            ? Colors.greenAccent
            : Colors.redAccent;

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Business Insights',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 12),
          // Trend
          _InsightRow(
            icon: Icons.trending_up_rounded,
            iconColor: trendColor,
            label: 'Revenue Trend',
            value: trend,
            valueColor: trendColor,
          ),
          const Divider(color: Colors.white10, height: 16),
          // Best day
          _InsightRow(
            icon: Icons.emoji_events_rounded,
            iconColor: Colors.amber.shade400,
            label: 'Best Day',
            value: bestDay != null
                ? '${_shortDate(bestDay.date)}  ·  ₹${_fmt(bestDay.revenue)}'
                : 'Not enough data',
            valueColor: AppTheme.textPrimary,
          ),
          const Divider(color: Colors.white10, height: 16),
          // Low stock
          _InsightRow(
            icon: Icons.inventory_2_rounded,
            iconColor: analytics.lowStockCount > 0
                ? Colors.red.shade400
                : Colors.green.shade400,
            label: 'Low Stock Alert',
            value: analytics.lowStockCount > 0
                ? '${analytics.lowStockCount} product${analytics.lowStockCount > 1 ? 's' : ''} running low (≤5 units)'
                : 'All products well stocked',
            valueColor: analytics.lowStockCount > 0
                ? Colors.red.shade300
                : Colors.green.shade300,
          ),
          const Divider(color: Colors.white10, height: 16),
          // Basket size
          _InsightRow(
            icon: Icons.shopping_cart_rounded,
            iconColor: Colors.blue.shade400,
            label: 'Avg Basket Size',
            value:
                '${analytics.avgItemsPerOrder.toStringAsFixed(1)} items  ·  ₹${analytics.avgOrderValue.toStringAsFixed(0)} avg spend',
            valueColor: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }

  String _shortDate(String iso) {
    try {
      final parts = iso.split('-');
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[int.parse(parts[1]) - 1]} ${parts[2]}, ${parts[0]}';
    } catch (_) {
      return iso;
    }
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _InsightRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Period Selector ───────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [7, 14, 30].map((days) {
        final active = selected == days;
        return GestureDetector(
          onTap: () => onChanged(days),
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? AppTheme.primary.withValues(alpha: 0.7)
                    : Colors.white12,
              ),
            ),
            child: Text('${days}D',
                style: TextStyle(
                    color: active
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Revenue Bar Chart ─────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  final List<DailyRevenueStatEntity> dailyRevenue;
  final int periodDays;
  const _RevenueChart(
      {required this.dailyRevenue, required this.periodDays});

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return AppGlassCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No revenue data yet.',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ),
      );
    }

    final data = dailyRevenue.length > periodDays
        ? dailyRevenue.sublist(dailyRevenue.length - periodDays)
        : dailyRevenue;

    double maxRevenue = 0;
    for (final d in data) {
      if (d.revenue > maxRevenue) maxRevenue = d.revenue;
    }
    final totalPeriodRevenue = data.fold(0.0, (s, d) => s + d.revenue);
    final totalPeriodOrders = data.fold(0, (s, d) => s + d.orders);

    return AppGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final ratio =
                    maxRevenue > 0 ? d.revenue / maxRevenue : 0.0;
                final isPeak = d.revenue == maxRevenue;
                final isToday = d.date ==
                    DateTime.now().toIso8601String().substring(0, 10);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isPeak) ...[
                          Text(
                            '₹${_fmt(d.revenue)}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 7,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Container(
                          height: (ratio * 100).clamp(3.0, 100.0),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.amber.shade400
                                : isPeak
                                    ? AppTheme.primary
                                    : AppTheme.primary
                                        .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_shortDate(data.first.date),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 9)),
              if (data.length > 2)
                Text(_shortDate(data[data.length ~/ 2].date),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 9)),
              Text(_shortDate(data.last.date),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 9)),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChartStat(
                  label: 'Period Revenue',
                  value: '₹${_fmt(totalPeriodRevenue)}'),
              _ChartStat(
                  label: 'Orders', value: '$totalPeriodOrders'),
              _ChartStat(
                  label: 'Peak Day',
                  value: '₹${_fmt(maxRevenue)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              const Text('Today',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 9)),
              const SizedBox(width: 12),
              Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              const Text('Peak day',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  String _shortDate(String iso) {
    try {
      final parts = iso.split('-');
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[int.parse(parts[1]) - 1]} ${parts[2]}';
    } catch (_) {
      return iso;
    }
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _ChartStat extends StatelessWidget {
  final String label;
  final String value;
  const _ChartStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 9)),
      ],
    );
  }
}

// ── Top Products ──────────────────────────────────────────────────────────────

class _TopProductsList extends StatelessWidget {
  final List<ProductStatEntity> products;
  final double totalRevenue;
  const _TopProductsList(
      {required this.products, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return AppGlassCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No product data yet.',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ),
      );
    }

    final maxRevenue = products.first.revenue.clamp(1.0, double.infinity);

    return Column(
      children: products.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        final ratio = p.revenue / maxRevenue;
        final pct = totalRevenue > 0
            ? (p.revenue / totalRevenue * 100).toStringAsFixed(1)
            : '0.0';

        return AppGlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _rankColor(i).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _rankColor(i).withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              color: _rankColor(i),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                            '${p.totalSold} units  ·  ${p.barcode}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${_fmt(p.revenue)}',
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _rankColor(i).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$pct% of revenue',
                            style: TextStyle(
                                color: _rankColor(i),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
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
                      _rankColor(i).withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _rankColor(int i) {
    if (i == 0) return Colors.amber.shade400;
    if (i == 1) return Colors.grey.shade400;
    if (i == 2) return Colors.orange.shade300;
    return AppTheme.primary;
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
