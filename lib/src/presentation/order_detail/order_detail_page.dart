import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import '../../domain/entity/order_entity.dart';
import '../../theme/app_theme.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderEntity order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('#${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Header card
            AppGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.storeName ?? '—',
                                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(order.formattedDate,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                  if (order.isFlagged) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_rounded, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Issue: ${order.flaggedIssue!.reason}${order.flaggedIssue!.note != null ? " — ${order.flaggedIssue!.note}" : ""}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items
            const Text('Items', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            AppGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                children: [
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                                  Text(item.barcode, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text('x${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            const SizedBox(width: 12),
                            Text('₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      )),
                  const Divider(color: AppTheme.cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      Text('₹${order.total.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      Text('₹${order.tax.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                      Text('₹${order.grandTotal.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),

            // Staff activity log
            if (order.staffActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Activity Log', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...order.staffActions.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded, color: AppTheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${a.action.replaceAll('_', ' ')}${a.staffName != null ? " by ${a.staffName}" : ""}${a.note != null ? " — ${a.note}" : ""}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
