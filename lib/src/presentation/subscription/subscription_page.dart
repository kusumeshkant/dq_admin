import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../service_core/subscription/feature_keys.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/subscription/subscription_manager.dart';
import '../../service_core/subscription/subscription_model.dart';
import '../../theme/app_theme.dart';
import '../plans/plans_binding.dart';
import '../plans/plans_page.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = Get.find<SubscriptionManager>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Subscription'),
          centerTitle: false,
          actions: [
            Obx(() => sub.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh',
                    onPressed: () {
                      final storeId =
                          Get.find<SessionManager>().storeId ?? '';
                      if (storeId.isNotEmpty) sub.refresh(storeId);
                    },
                  )),
          ],
        ),
        body: Obx(() {
          if (sub.isLoading.value && !sub.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final info = sub.info;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 40),
            children: [
              // ── Plan status card ─────────────────────────────────────
              _PlanStatusCard(info: info),
              const SizedBox(height: 16),

              // ── Usage counters ───────────────────────────────────────
              const _SectionTitle('Usage'),
              const SizedBox(height: 10),
              _UsageSection(info: info),
              const SizedBox(height: 20),

              // ── Features included ────────────────────────────────────
              const _SectionTitle('Features'),
              const SizedBox(height: 10),
              _FeaturesSection(info: info),
              const SizedBox(height: 20),

              // ── Upgrade CTA (shown when not on top plan) ─────────────
              if (!_isTopPlan(info.planName)) ...[
                _UpgradeCta(currentPlan: info.planName),
              ],
            ],
          );
        }),
      ),
    );
  }

  bool _isTopPlan(String name) =>
      name == 'pro' || name == 'enterprise' || name == 'grandfathered';
}

// ── Plan Status Card ───────────────────────────────────────────────────────────

class _PlanStatusCard extends StatelessWidget {
  final SubscriptionInfo info;
  const _PlanStatusCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(info.status);
    final statusLabel = _statusLabel(info.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.25),
            statusColor.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_planIcon(info.planName), color: statusColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info.planDisplayName.isEmpty
                      ? _formatPlanName(info.planName)
                      : info.planDisplayName,
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              _StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          _periodRow(info),
          if (info.isTrial && info.trialDaysLeft != null) ...[
            const SizedBox(height: 8),
            _TrialProgressBar(daysLeft: info.trialDaysLeft!, totalDays: 14),
          ],
        ],
      ),
    );
  }

  Widget _periodRow(SubscriptionInfo info) {
    String label = '';
    String value = '';

    if (info.isTrial && info.trialEndsAt != null) {
      label = 'Trial ends';
      value = _formatDate(info.trialEndsAt!);
    } else if (info.isGracePeriod && info.gracePeriodEndsAt != null) {
      label = 'Grace period ends';
      value = _formatDate(info.gracePeriodEndsAt!);
    } else if (info.currentPeriodEnd != null) {
      label = info.isGrandfathered ? 'Free access until' : 'Renews on';
      value = _formatDate(info.currentPeriodEnd!);
    } else {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.calendar_today_rounded,
            size: 13, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text('$label  ',
            style:
                TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Color _statusColor(String status) => switch (status) {
        'trial'          => AppColors.info,
        'active'         => AppColors.success,
        'grace_period'   => AppColors.warning,
        'expired'        => AppColors.error,
        'cancelled'      => AppColors.error,
        'admin_override' => AppColors.primary,
        'grandfathered'  => AppColors.warning,
        _                => AppColors.neutral,
      };

  String _statusLabel(String status) => switch (status) {
        'trial'          => 'Trial',
        'active'         => 'Active',
        'grace_period'   => 'Grace Period',
        'expired'        => 'Expired',
        'cancelled'      => 'Cancelled',
        'admin_override' => 'Override',
        'grandfathered'  => 'Grandfathered',
        _                => status,
      };

  IconData _planIcon(String name) => switch (name) {
        'free'         => Icons.lock_open_rounded,
        'trial'        => Icons.hourglass_top_rounded,
        'starter'      => Icons.rocket_launch_rounded,
        'growth'       => Icons.trending_up_rounded,
        'pro'          => Icons.workspace_premium_rounded,
        'enterprise'   => Icons.business_rounded,
        'grandfathered'=> Icons.star_rounded,
        _              => Icons.subscriptions_rounded,
      };

  String _formatPlanName(String name) {
    if (name.isEmpty) return 'No Plan';
    return name[0].toUpperCase() + name.substring(1);
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _TrialProgressBar extends StatelessWidget {
  final int daysLeft;
  final int totalDays;
  const _TrialProgressBar({required this.daysLeft, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final progress = (daysLeft / totalDays).clamp(0.0, 1.0);
    final color = daysLeft <= 3
        ? AppColors.error
        : daysLeft <= 7
            ? AppColors.warning
            : AppColors.info;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trial progress',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
            Text('$daysLeft days left',
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Usage Section ──────────────────────────────────────────────────────────────

class _UsageSection extends StatelessWidget {
  final SubscriptionInfo info;
  const _UsageSection({required this.info});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _UsageRow(
            icon: Icons.people_rounded,
            label: 'Staff',
            color: AppColors.info,
            used: info.usage.staffCount,
            limit: info.limits.maxStaff,
            isUnlimited: info.limits.isStaffUnlimited,
          ),
          const Divider(height: 20, color: Colors.white10),
          _UsageRow(
            icon: Icons.receipt_long_rounded,
            label: 'Orders this month',
            color: AppTheme.primary,
            used: info.usage.ordersThisMonth,
            limit: info.limits.maxOrdersPerMonth,
            isUnlimited: info.limits.isOrdersUnlimited,
          ),
          const Divider(height: 20, color: Colors.white10),
          _UsageRow(
            icon: Icons.storefront_rounded,
            label: 'Stores',
            color: AppColors.primary,
            used: info.usage.storeCount,
            limit: info.limits.maxStores,
            isUnlimited: info.limits.isStoresUnlimited,
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int used;
  final int limit;
  final bool isUnlimited;

  const _UsageRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.used,
    required this.limit,
    required this.isUnlimited,
  });

  @override
  Widget build(BuildContext context) {
    final usageText = isUnlimited ? '$used / ∞' : '$used / $limit';
    final double progress = (isUnlimited || limit <= 0) ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final bool nearLimit = !isUnlimited && limit > 0 && progress >= 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppTheme.textPrimary)),
            ),
            Text(
              usageText,
              style: AppTypography.label.copyWith(
                color: nearLimit ? AppColors.warning : AppTheme.textSecondary,
                fontWeight: nearLimit ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        if (!isUnlimited) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                nearLimit ? AppColors.warning : color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Features Section ───────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  final SubscriptionInfo info;
  const _FeaturesSection({required this.info});

  static const _featureLabels = {
    FeatureKeys.analytics:                 ('Analytics Dashboard',      Icons.bar_chart_rounded),
    FeatureKeys.bulkUpload:                ('Bulk Excel Upload',         Icons.upload_file_rounded),
    FeatureKeys.coupons:                   ('Coupon Engine',             Icons.local_offer_rounded),
    FeatureKeys.advancedReports:           ('Advanced Reports',          Icons.analytics_rounded),
    FeatureKeys.staffPerformanceAnalytics: ('Staff Performance',         Icons.people_rounded),
    FeatureKeys.customerLtvAnalytics:      ('Customer LTV Analytics',    Icons.timeline_rounded),
    FeatureKeys.exportData:                ('Export Data',               Icons.download_rounded),
    FeatureKeys.prioritySupport:           ('Priority Support',          Icons.headset_mic_rounded),
    FeatureKeys.customBranding:            ('Custom Branding',           Icons.palette_rounded),
  };

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      child: Column(
        children: _featureLabels.entries.map((entry) {
          final key       = entry.key;
          final label     = entry.value.$1;
          final icon      = entry.value.$2;
          final isEnabled = info.features[key];
          final isLast    = entry.key == _featureLabels.keys.last;

          return Column(
            children: [
              _FeatureRow(
                icon:      icon,
                label:     label,
                isEnabled: isEnabled,
              ),
              if (!isLast)
                const Divider(height: 16, color: Colors.white10),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? AppColors.success : AppColors.neutral;
    return Row(
      children: [
        Icon(icon, size: 16, color: isEnabled ? AppTheme.primary : AppColors.neutral),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 13)),
        ),
        Icon(
          isEnabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: color,
        ),
      ],
    );
  }
}

// ── Upgrade CTA ────────────────────────────────────────────────────────────────

class _UpgradeCta extends StatelessWidget {
  final String currentPlan;
  const _UpgradeCta({required this.currentPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Upgrade your plan',
                  style: AppTypography.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock advanced analytics, coupon engine, unlimited products and more.',
            style: AppTypography.caption
                .copyWith(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.to(
                () => const PlansPage(),
                binding: PlansBinding(),
                transition: Transition.rightToLeft,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
              ),
              child: const Text('View Plans',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold));
  }
}
