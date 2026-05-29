import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_config.dart';
import '../../core/responsive/app_responsive.dart';
import '../../theme/app_theme.dart';
import 'plans_controller.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlansController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Choose Your Plan'),
          centerTitle: false,
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.errorMessage.value,
                      style: AppTypography.body.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(onPressed: c.fetchPlans, child: const Text('Retry')),
                ],
              ),
            );
          }

          return Column(
            children: [
              _BillingToggle(controller: c),
              Expanded(
                child: context.isTabletOrLarger
                    // ── Tablet / desktop: grid layout ──────────────────
                    ? SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                            context.pagePadding,
                            AppSpacing.sm,
                            context.pagePadding,
                            40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: context.maxContentWidth),
                            child: Column(
                              children: [
                                // Plan cards grid
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final cols = context.responsive(
                                        1, tablet: 2, largeTablet: 3);
                                    final spacing = AppSpacing.md.toDouble();
                                    final cardWidth = (constraints.maxWidth -
                                            spacing * (cols - 1)) /
                                        cols;
                                    return Wrap(
                                      spacing: spacing,
                                      runSpacing: spacing,
                                      children: [
                                        for (final plan in c.plans)
                                          SizedBox(
                                            width: cardWidth,
                                            child: _PlanCard(
                                                plan: plan, controller: c),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _Footer(),
                              ],
                            ),
                          ),
                        ),
                      )
                    // ── Mobile: original vertical list ─────────────────
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, AppSpacing.sm, AppSpacing.md, 40),
                        children: [
                          for (final plan in c.plans)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _PlanCard(plan: plan, controller: c),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          _Footer(),
                        ],
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Billing toggle ─────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final PlansController controller;
  const _BillingToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAnnual = controller.billingCycle.value == 'annual';
      return Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleOption(
              label: 'Monthly',
              selected: !isAnnual,
              onTap: () => controller.billingCycle.value = 'monthly',
            ),
            _ToggleOption(
              label: 'Annual',
              subLabel: 'Save ~20%',
              selected: isAnnual,
              onTap: () => controller.billingCycle.value = 'annual',
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final String? subLabel;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleOption({
    required this.label,
    this.subLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  subLabel!,
                  style: AppTypography.labelSmall.copyWith(
                    color: selected ? Colors.white : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Plan card ──────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final PlansController controller;
  const _PlanCard({required this.plan, required this.controller});

  @override
  Widget build(BuildContext context) {
    final name            = plan['name'] as String;
    final displayName     = plan['displayName'] as String;
    final description     = plan['description'] as String? ?? '';
    final isRecommended   = plan['isRecommended'] as bool? ?? false;
    final isCustomPricing = plan['isCustomPricing'] as bool? ?? false;
    final features        = plan['features'] as Map<String, dynamic>? ?? {};
    final limits          = plan['limits'] as Map<String, dynamic>? ?? {};
    final priceMap        = plan['price'] as Map<String, dynamic>? ?? {};

    return Obx(() {
      final cycle   = controller.billingCycle.value;
      final monthly = (priceMap['monthly'] as num?)?.toInt() ?? 0;
      final annual  = (priceMap['annual']  as num?)?.toInt() ?? 0;
      final price   = cycle == 'annual' ? annual : monthly;
      final perMonth = cycle == 'annual' ? (annual / 12).round() : monthly;

      final isCurrent   = controller.isCurrentPlan(name);
      final isUpgrading = controller.isUpgrading.value;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          AppGlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRecommended
                          ? [AppTheme.primary.withValues(alpha: 0.35),
                             AppColors.primary.withValues(alpha: 0.15)]
                          : [Colors.white.withValues(alpha: 0.05),
                             Colors.white.withValues(alpha: 0.03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusLg)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(displayName,
                              style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold)),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            _Badge(label: 'Current', color: AppColors.success),
                          ],
                          const Spacer(),
                          if (isRecommended)
                            _Badge(label: 'Recommended', color: AppTheme.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(description,
                          style: AppTypography.caption
                              .copyWith(color: AppTheme.textSecondary)),
                      const SizedBox(height: 12),
                      if (isCustomPricing)
                        Text(
                          'Custom',
                          style: AppTypography.displayMedium.copyWith(
                              fontWeight: FontWeight.w900),
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${_fmt(perMonth)}',
                              style: AppTypography.displayMedium.copyWith(
                                  fontWeight: FontWeight.w900),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3, left: 4),
                              child: Text('/mo',
                                  style: AppTypography.caption
                                      .copyWith(color: AppTheme.textSecondary)),
                            ),
                            if (cycle == 'annual') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successSubtle,
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusFull),
                                ),
                                child: Text(
                                  '₹${_fmt(price)}/yr',
                                  style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),

                // ── Features ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._featureRows(features),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1, color: Colors.white12),
                      const SizedBox(height: AppSpacing.sm),
                      ..._limitRows(limits),
                    ],
                  ),
                ),

                // ── CTA ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCustomPricing
                          ? () => controller.selectPlan(name)
                          : (isCurrent || isUpgrading)
                              ? null
                              : () => controller.selectPlan(name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? AppTheme.primary
                            : Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.white.withValues(alpha: 0.06),
                        disabledForegroundColor: AppTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd)),
                        elevation: 0,
                      ),
                      child: isUpgrading && controller.pendingPlanName.value == name
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isCustomPricing
                                  ? 'Contact Us'
                                  : isCurrent
                                      ? 'Current Plan'
                                      : 'Select Plan',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _featureRows(Map<String, dynamic> features) {
    const featureLabels = {
      'analytics':                 ('Analytics Dashboard', Icons.bar_chart_rounded),
      'bulkUpload':                ('Bulk Excel Upload', Icons.upload_file_rounded),
      'coupons':                   ('Coupon Engine', Icons.discount_rounded),
      'advancedReports':           ('Advanced Reports', Icons.assessment_rounded),
      'staffPerformanceAnalytics': ('Staff Performance', Icons.people_rounded),
      'customerLtvAnalytics':      ('Customer LTV Analytics', Icons.timeline_rounded),
      'exportData':                ('Export Data', Icons.download_rounded),
      'prioritySupport':           ('Priority Support', Icons.headset_mic_rounded),
      'customBranding':            ('Custom Branding', Icons.palette_rounded),
    };

    return featureLabels.entries.map((e) {
      final enabled = features[e.key] as bool? ?? false;
      final (label, icon) = e.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: enabled ? AppTheme.primary : AppTheme.textSecondary
                    .withValues(alpha: 0.4)),
            const SizedBox(width: 8),
            Text(label,
                style: AppTypography.caption.copyWith(
                    color: enabled
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary.withValues(alpha: 0.4))),
            const Spacer(),
            Icon(
              enabled
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size: 14,
              color: enabled ? AppColors.success : Colors.white12,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _limitRows(Map<String, dynamic> limits) {
    Widget limitRow(IconData icon, String label, dynamic value) {
      final display = (value == -1 || value == null) ? '∞' : value.toString();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppTheme.textSecondary)),
            const Spacer(),
            Text(display,
                style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: display == '∞'
                        ? AppColors.warning
                        : AppTheme.textPrimary)),
          ],
        ),
      );
    }

    return [
      limitRow(Icons.people_outline_rounded, 'Staff members',
          limits['maxStaff']),
      limitRow(Icons.receipt_long_rounded, 'Orders / month',
          limits['maxOrdersPerMonth']),
      limitRow(Icons.store_rounded, 'Stores', limits['maxStores']),
    ];
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return n.toString();
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: AppTypography.labelSmall
              .copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Text(
            'All plans include a 7-day grace period if payment lapses.',
            style: AppTypography.caption
                .copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Questions? Contact ${AppConfig.supportEmail}',
            style: AppTypography.caption
                .copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
