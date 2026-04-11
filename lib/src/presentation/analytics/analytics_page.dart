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
          if (c.isLoading.value) return const AppLoadingWidget();
          if (c.errorMessage.value.isNotEmpty) {
            return AppErrorWidget(
              message: c.errorMessage.value,
              onRetry: c.loadAnalytics,
            );
          }
          final a = c.analytics.value;
          if (a == null) return const SizedBox.shrink();

          final hPad = context.pagePadding;
          return RefreshIndicator(
            onRefresh: c.loadAnalytics,
            color: AppTheme.primary,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, AppSpacing.sm, hPad, 40),
              children: [
                // ── Revenue hero ─────────────────────────────────────────
                _RevenueHero(analytics: a),
                const SizedBox(height: AppSpacing.md),

                // ── KPI chips row ────────────────────────────────────────
                _KpiChipsRow(analytics: a),
                const SizedBox(height: AppSpacing.xl),

                // ── Business insights ────────────────────────────────────
                _BusinessInsights(analytics: a),
                const SizedBox(height: AppSpacing.xl),

                // ── Revenue chart ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Revenue Trend',
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    _PeriodSelector(
                      selected: _periodDays,
                      onChanged: (v) => setState(() => _periodDays = v),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                _RevenueChart(
                    dailyRevenue: a.dailyRevenue, periodDays: _periodDays),
                const SizedBox(height: AppSpacing.xl),

                // ── Top products ─────────────────────────────────────────
                Text('Top Products by Revenue',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                _TopProductsList(
                    products: a.topProducts,
                    totalRevenue: a.totalRevenue),
                const SizedBox(height: AppSpacing.xl),

                // ── Monthly revenue chart ────────────────────────────────
                Text('Monthly Revenue',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                Obx(() => _MonthlyRevenueChart(
                    months: c.monthlyRevenue.toList())),
                const SizedBox(height: AppSpacing.xl),

                // ── Customer retention ───────────────────────────────────
                Text('Customer Retention',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                Obx(() => c.retention.value != null
                    ? _RetentionCard(r: c.retention.value!)
                    : const SizedBox.shrink()),
                const SizedBox(height: AppSpacing.xl),

                // ── Basket abandonment ───────────────────────────────────
                Text('Basket Abandonment',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                Obx(() => c.basketAbandonment.value != null
                    ? _BasketAbandonmentCard(b: c.basketAbandonment.value!)
                    : const SizedBox.shrink()),
                const SizedBox(height: AppSpacing.xl),

                // ── Customer LTV ─────────────────────────────────────────
                Text('Customer LTV',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                Obx(() => c.customerLTV.value != null
                    ? _CustomerLTVCard(ltv: c.customerLTV.value!)
                    : const SizedBox.shrink()),
                const SizedBox(height: AppSpacing.xl),

                // ── Staff performance ────────────────────────────────────
                Text('Staff Performance',
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm + 2),
                Obx(() => _StaffPerformanceList(staff: c.staffPerformance.toList())),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1060),
            AppTheme.primary.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl - 2),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Revenue',
              style: AppTypography.label.copyWith(color: Colors.white60)),
          const SizedBox(height: AppSpacing.sm - 2),
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: data.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(data.icon, color: data.color, size: AppSizes.iconSm),
          const SizedBox(height: AppSpacing.xs),
          Text(data.value,
              style: AppTypography.titleSmall.copyWith(color: data.color)),
          Text(data.label,
              style: AppTypography.caption,
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
          Text('Business Insights',
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
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
          width: AppSizes.iconLg - 2,
          height: AppSizes.iconLg - 2,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(icon, color: iconColor, size: AppSizes.iconMd - 8),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTypography.label.copyWith(
                      color: valueColor, fontWeight: FontWeight.w500)),
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

// ── Monthly Revenue Chart ─────────────────────────────────────────────────────

class _MonthlyRevenueChart extends StatelessWidget {
  final List<MonthlyRevenueStatEntity> months;
  const _MonthlyRevenueChart({required this.months});

  static const _monthNames = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  String _safeMonthName(int month) =>
      (month >= 1 && month <= 12) ? _monthNames[month - 1] : '?';

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return AppGlassCard(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No monthly data yet.',
              style: TextStyle(color: AppTheme.textSecondary))),
        ),
      );
    }

    // Find peak index explicitly to avoid double-equality firstWhere fragility
    int peakIdx = 0;
    for (int i = 1; i < months.length; i++) {
      if (months[i].revenue > months[peakIdx].revenue) peakIdx = i;
    }
    final maxRev = months[peakIdx].revenue;
    final totalRev = months.fold(0.0, (s, e) => s + e.revenue);
    final currentMonth = DateTime.now().month;

    return AppGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  final ratio = maxRev > 0 ? m.revenue / maxRev : 0.0;
                  final isCurrent = m.month == currentMonth;
                  final isPeak = i == peakIdx && maxRev > 0;
                  return SizedBox(
                    width: 28,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isPeak)
                            Text(_mfmt(m.revenue),
                                style: const TextStyle(
                                    color: AppTheme.primary, fontSize: 7,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.clip),
                          const SizedBox(height: 2),
                          Container(
                            height: (ratio * 86).clamp(3.0, 86.0),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.amber.shade400
                                  : isPeak
                                      ? AppTheme.primary
                                      : AppTheme.primary.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_safeMonthName(m.month),
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 7)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChartStat(label: 'Year Total', value: '₹${_mfmt(totalRev)}'),
              _ChartStat(
                  label: 'Best Month',
                  value: maxRev > 0
                      ? '${_safeMonthName(months[peakIdx].month)} · ₹${_mfmt(maxRev)}'
                      : '—'),
              _ChartStat(
                  label: 'Avg / Month',
                  value: '₹${_mfmt(totalRev / months.length)}'),
            ],
          ),
        ],
      ),
    );
  }

  String _mfmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Customer Retention ────────────────────────────────────────────────────────

class _RetentionCard extends StatelessWidget {
  final CustomerRetentionEntity r;
  const _RetentionCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final weekChange = r.newCustomersThisWeek - r.newCustomersLastWeek;
    final weekColor = weekChange >= 0 ? Colors.greenAccent : Colors.redAccent;

    return AppGlassCard(
      child: Column(
        children: [
          Row(
            children: [
              _StatBox(label: 'Retention Rate',
                  value: '${r.retentionRate.toStringAsFixed(1)}%',
                  color: r.retentionRate >= 30 ? Colors.greenAccent
                      : r.retentionRate >= 15 ? Colors.amber.shade400
                      : Colors.redAccent),
              const SizedBox(width: 8),
              _StatBox(label: 'Returning', value: '${r.returningCustomers}',
                  color: AppTheme.primary),
              const SizedBox(width: 8),
              _StatBox(label: 'Total Customers', value: '${r.totalCustomers}',
                  color: Colors.blue.shade400),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatBox(
                label: 'New This Week',
                value: '${r.newCustomersThisWeek}',
                color: Colors.teal.shade300,
                suffix: ' (${weekChange >= 0 ? '+' : ''}$weekChange vs last)',
                suffixColor: weekColor,
              ),
              const SizedBox(width: 8),
              _StatBox(
                label: 'Avg Repeat Interval',
                value: r.avgRepeatIntervalDays != null
                    ? '${r.avgRepeatIntervalDays!.toStringAsFixed(1)} days'
                    : '—',
                color: Colors.purple.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Basket Abandonment ────────────────────────────────────────────────────────

class _BasketAbandonmentCard extends StatelessWidget {
  final BasketAbandonmentEntity b;
  const _BasketAbandonmentCard({required this.b});

  @override
  Widget build(BuildContext context) {
    final weekChange = b.thisWeekAbandonmentRate - b.lastWeekAbandonmentRate;
    final weekColor = weekChange <= 0 ? Colors.greenAccent : Colors.redAccent;

    return AppGlassCard(
      child: Column(
        children: [
          Row(
            children: [
              _StatBox(
                label: 'Abandonment Rate',
                value: '${b.abandonmentRate.toStringAsFixed(1)}%',
                color: b.abandonmentRate > 50 ? Colors.redAccent
                    : b.abandonmentRate > 30 ? Colors.amber.shade400
                    : Colors.greenAccent,
              ),
              const SizedBox(width: 8),
              _StatBox(label: 'Conversion Rate',
                  value: '${b.conversionRate.toStringAsFixed(1)}%',
                  color: Colors.greenAccent),
              const SizedBox(width: 8),
              _StatBox(label: 'Total Checks', value: '${b.totalChecks}',
                  color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatBox(
                label: 'This Week',
                value: '${b.thisWeekAbandonmentRate.toStringAsFixed(1)}%',
                color: weekColor,
                suffix: ' (${weekChange >= 0 ? '+' : ''}${weekChange.toStringAsFixed(1)}%)',
                suffixColor: weekColor,
              ),
              const SizedBox(width: 8),
              _StatBox(label: 'Abandoned', value: '${b.abandonedChecks}',
                  color: Colors.redAccent),
              const SizedBox(width: 8),
              _StatBox(label: 'Converted', value: '${b.convertedChecks}',
                  color: Colors.teal.shade300),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Customer LTV ──────────────────────────────────────────────────────────────

class _CustomerLTVCard extends StatelessWidget {
  final CustomerLTVEntity ltv;
  const _CustomerLTVCard({required this.ltv});

  String _lfmt(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatBox(label: 'Avg Revenue / Customer',
                  value: _lfmt(ltv.avgRevenuePerCustomer),
                  color: Colors.greenAccent),
              const SizedBox(width: 8),
              _StatBox(
                label: 'Projected Monthly LTV',
                value: ltv.projectedMonthlyLTV != null
                    ? _lfmt(ltv.projectedMonthlyLTV!) : '—',
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatBox(label: 'Avg Orders / Customer',
                  value: ltv.avgOrdersPerCustomer.toStringAsFixed(1),
                  color: Colors.blue.shade400),
              const SizedBox(width: 8),
              _StatBox(
                label: 'Avg Days Active',
                value: ltv.avgDaysActive != null
                    ? '${ltv.avgDaysActive!.toStringAsFixed(0)} days' : '—',
                color: Colors.purple.shade300,
              ),
              const SizedBox(width: 8),
              _StatBox(label: 'Total Customers', value: '${ltv.totalCustomers}',
                  color: Colors.teal.shade300),
            ],
          ),
          if (ltv.topCustomers.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Top Customers',
                style: TextStyle(color: AppTheme.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...ltv.topCustomers.take(5).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final cu = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                      child: Center(child: Text('${i + 1}',
                          style: const TextStyle(color: AppTheme.primary,
                              fontSize: 10, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cu.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${cu.totalOrders} orders',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(_lfmt(cu.totalSpend),
                        style: const TextStyle(color: Colors.greenAccent,
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Staff Performance ─────────────────────────────────────────────────────────

class _StaffPerformanceList extends StatefulWidget {
  final List<StaffPerformanceStatEntity> staff;
  const _StaffPerformanceList({required this.staff});

  @override
  State<_StaffPerformanceList> createState() => _StaffPerformanceListState();
}

class _StaffPerformanceListState extends State<_StaffPerformanceList> {
  static const _previewCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    if (widget.staff.isEmpty) {
      return AppGlassCard(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No staff data yet.',
              style: TextStyle(color: AppTheme.textSecondary))),
        ),
      );
    }

    final display = _showAll
        ? widget.staff
        : widget.staff.take(_previewCount).toList();
    final remaining = widget.staff.length - _previewCount;

    return Column(
      children: [
        ...display.map((s) => _buildCard(s)),
        if (widget.staff.length > _previewCount)
          GestureDetector(
            onTap: () => setState(() => _showAll = !_showAll),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showAll
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _showAll
                        ? 'Show less'
                        : 'Show $remaining more',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(StaffPerformanceStatEntity s) {
    final cancColor = s.cancellationRate > 20
        ? Colors.redAccent
        : s.cancellationRate > 10
            ? Colors.amber.shade400
            : Colors.greenAccent;
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.staffName,
                        style: const TextStyle(color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${s.totalOrdersHandled} orders handled',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              if (s.avgFulfillmentTime != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      '⚡ ${s.avgFulfillmentTime!.toStringAsFixed(0)}m avg',
                      style: TextStyle(color: Colors.blue.shade400,
                          fontSize: 10, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatBox(label: 'Completed', value: '${s.ordersCompleted}',
                  color: Colors.greenAccent),
              const SizedBox(width: 6),
              _StatBox(label: 'Cancelled', value: '${s.ordersCancelled}',
                  color: cancColor),
              const SizedBox(width: 6),
              _StatBox(label: 'Flags Raised', value: '${s.flagsRaised}',
                  color: s.flagsRaised > 0
                      ? Colors.orange.shade400 : Colors.greenAccent),
              const SizedBox(width: 6),
              _StatBox(label: 'Cancel Rate',
                  value: '${s.cancellationRate.toStringAsFixed(0)}%',
                  color: cancColor),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared stat box ───────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? suffix;
  final Color? suffixColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
    this.suffixColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(value,
                      style: TextStyle(color: color, fontSize: 14,
                          fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (suffix != null)
                  Text(suffix!,
                      style: TextStyle(color: suffixColor ?? color,
                          fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 9),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
