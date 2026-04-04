import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/order_entity.dart';
import '../../theme/app_theme.dart';
import '../order_detail/order_detail_binding.dart';
import '../order_detail/order_detail_page.dart';
import 'orders_controller.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrdersController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('All Orders')),
        body: Column(
          children: [
            // Filters
            Obx(() => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      // Store filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: c.selectedStoreId.value,
                          dropdownColor: const Color(0xFF1E1040),
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: AppTheme.cardSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                          ),
                          hint: const Text('All Stores', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Stores', style: TextStyle(color: AppTheme.textSecondary))),
                            ...c.stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(color: AppTheme.textPrimary)))),
                          ],
                          onChanged: c.filterByStore,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: c.selectedStatus.value ?? 'All',
                          dropdownColor: const Color(0xFF1E1040),
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: AppTheme.cardSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                          ),
                          items: c.statusOptions
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: AppTheme.textPrimary))))
                              .toList(),
                          onChanged: (v) => c.filterByStatus(v),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Stat chips
            Obx(() => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Active',
                        value: c.activeCount,
                        color: AppTheme.primary,
                        icon: Icons.receipt_long_rounded,
                        selected: c.selectedStatus.value == null,
                        onTap: () => c.filterByStatus('All'),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Completed',
                        value: c.completedCount,
                        color: Colors.teal,
                        icon: Icons.done_all_rounded,
                        selected: c.selectedStatus.value == 'completed',
                        onTap: () => c.filterByStatus('completed'),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Cancelled',
                        value: c.cancelledCount,
                        color: Colors.red,
                        icon: Icons.cancel_rounded,
                        selected: c.selectedStatus.value == 'cancelled',
                        onTap: () => c.filterByStatus('cancelled'),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (c.orders.isEmpty) {
                  return const Center(
                    child: Text('No orders found.',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.loadOrders,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    itemCount: c.orders.length,
                    itemBuilder: (_, i) => _OrderCard(
                      order: c.orders[i],
                      onTap: () => Get.to(
                        () => OrderDetailPage(order: c.orders[i]),
                        binding: OrderDetailBinding(order: c.orders[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.7) : color.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 15),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.toString(),
                      style: TextStyle(
                          color: color, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 10)),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 10, height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _statusColor(order.status),
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
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      if (order.isFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_rounded, color: Colors.red, size: 11),
                              SizedBox(width: 3),
                              Text('Issue', style: TextStyle(color: Colors.red, fontSize: 10)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(order.storeName ?? '—',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text('${order.items.length} item${order.items.length != 1 ? "s" : ""}  ·  ₹${order.grandTotal.toStringAsFixed(0)}  ·  ${order.formattedDate}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status.toLowerCase()) {
        'pending' => Colors.grey.shade400,
        'preparing' => Colors.orange.shade400,
        'ready' => Colors.blue.shade400,
        'completed' => Colors.green.shade400,
        'cancelled' => Colors.red.shade400,
        _ => Colors.orange.shade300,
      };
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}
