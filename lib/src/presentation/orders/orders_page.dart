import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/pagination/paginated_list_view.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../domain/entity/order_entity.dart';
import '../../theme/app_theme.dart';
import '../order_detail/order_detail_binding.dart';
import '../order_detail/order_detail_page.dart';
import 'orders_controller.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<OrdersController>();
    final hPad = context.pagePadding;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('All Orders')),
        body: Column(
          children: [
            // Store + Status filters
            Obx(() => Padding(
                  padding: EdgeInsets.fromLTRB(hPad, AppSpacing.sm, hPad, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: c.selectedStoreId.value,
                          dropdownColor: AppTheme.surface,
                          style: AppTypography.bodySmall,
                          decoration: _dropdownDecoration,
                          hint: Text('All Stores',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppTheme.textSecondary)),
                          items: [
                            DropdownMenuItem(
                                value: null,
                                child: Text('All Stores',
                                    style: AppTypography.bodySmall.copyWith(
                                        color: AppTheme.textSecondary))),
                            ...c.stores.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name,
                                    style: AppTypography.bodySmall))),
                          ],
                          onChanged: c.filterByStore,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: c.selectedStatus.value ?? 'All',
                          dropdownColor: AppTheme.surface,
                          style: AppTypography.bodySmall,
                          decoration: _dropdownDecoration,
                          items: c.statusOptions
                              .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s,
                                      style: AppTypography.bodySmall)))
                              .toList(),
                          onChanged: (v) => c.filterByStatus(v),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.sm),

            // Stat chips
            Obx(() => Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Active',
                        value: c.activeCount,
                        color: AppColors.primary,
                        icon: Icons.receipt_long_rounded,
                        selected: c.selectedStatus.value == null,
                        onTap: () => c.filterByStatus('All'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatChip(
                        label: 'Completed',
                        value: c.completedCount,
                        color: AppColors.success,
                        icon: Icons.done_all_rounded,
                        selected: c.selectedStatus.value == 'completed',
                        onTap: () => c.filterByStatus('completed'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatChip(
                        label: 'Cancelled',
                        value: c.cancelledCount,
                        color: AppColors.error,
                        icon: Icons.cancel_rounded,
                        selected: c.selectedStatus.value == 'cancelled',
                        onTap: () => c.filterByStatus('cancelled'),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.sm),

            // Paginated list
            Expanded(
              child: AppPaginatedListView<OrderEntity>(
                controller: c,
                emptyTitle: 'No orders found',
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 40),
                itemBuilder: (_, order, __) => _OrderCard(
                  order: order,
                  onTap: () => Get.to(
                    () => OrderDetailPage(order: order),
                    binding: OrderDetailBinding(order: order),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _dropdownDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    filled: true,
    fillColor: AppTheme.cardSurface,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd - 2)),
        borderSide: BorderSide(color: AppTheme.cardBorder)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd - 2)),
        borderSide: BorderSide(color: AppTheme.cardBorder)),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd - 2),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.7)
                  : color.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconSm - 3),
              const SizedBox(width: AppSpacing.sm - 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.toString(),
                      style: AppTypography.bodyLarge
                          .copyWith(color: color, fontWeight: FontWeight.bold)),
                  Text(label, style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.statusColor(order.status),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                          style: AppTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (order.isFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm - 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorSubtle,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm - 2),
                            border: Border.all(color: AppColors.errorBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_rounded,
                                  color: AppColors.error, size: 11),
                              SizedBox(width: 3),
                              Text('Issue',
                                  style: TextStyle(
                                      color: AppColors.error, fontSize: 10)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(order.storeName ?? '—', style: AppTypography.labelSmall),
                  Text(
                    '${order.items.length} item${order.items.length != 1 ? "s" : ""}  ·  ₹${order.grandTotal.toStringAsFixed(0)}  ·  ${order.formattedDate}',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DsStatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }
}
