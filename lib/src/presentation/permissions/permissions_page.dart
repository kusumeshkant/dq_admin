import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/app_loading_widget.dart';
import '../../theme/app_theme.dart';
import 'permissions_controller.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Permissions & Logs'),
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppTheme.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'History'),
                Tab(text: 'Discounts'),
                Tab(text: 'Product Log'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _PendingTab(),
              _HistoryTab(),
              _DiscountLogsTab(),
              _ProductChangeLogsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pending Requests Tab ───────────────────────────────────────────────────────

class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PermissionsController>();
    return RefreshIndicator(
      onRefresh: c.loadPending,
      color: AppTheme.primary,
      child: Obx(() {
        if (c.isLoadingPending.value) return const AppLoadingWidget();
        if (c.pendingError.value.isNotEmpty) {
          return AppErrorWidget(message: c.pendingError.value, onRetry: c.loadPending);
        }
        if (c.pendingRequests.isEmpty) {
          return _EmptyState(
            icon: Icons.check_circle_rounded,
            message: 'No pending requests',
            color: AppColors.success,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: c.pendingRequests.length,
          itemBuilder: (_, i) => _RequestCard(
            req: c.pendingRequests[i],
            showActions: true,
            onApprove: () => c.showApproveDialog(c.pendingRequests[i]),
            onReject: () => c.showRejectDialog(c.pendingRequests[i]),
          ),
        );
      }),
    );
  }
}

// ── History Tab ────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  static const _statusOptions = [
    null, 'pending', 'approved', 'rejected', 'revoked',
  ];
  static const _statusLabels = [
    'All', 'Pending', 'Approved', 'Rejected', 'Revoked',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PermissionsController>();
    return Column(
      children: [
        // Status filter chips
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Row(
            children: List.generate(_statusOptions.length, (i) {
              final isSelected = c.selectedStatus.value == _statusOptions[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_statusLabels[i]),
                  selected: isSelected,
                  onSelected: (_) => c.onStatusFilterChanged(_statusOptions[i]),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.25),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primary : Colors.white70,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.6)
                        : Colors.white24,
                  ),
                ),
              );
            }),
          ),
        )),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: RefreshIndicator(
            onRefresh: c.loadAll,
            color: AppTheme.primary,
            child: Obx(() {
              if (c.isLoadingAll.value) return const AppLoadingWidget();
              if (c.allError.value.isNotEmpty) {
                return AppErrorWidget(message: c.allError.value, onRetry: c.loadAll);
              }
              if (c.allRequests.isEmpty) {
                return _EmptyState(
                  icon: Icons.history_rounded,
                  message: 'No requests found',
                  color: AppColors.info,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                itemCount: c.allRequests.length,
                itemBuilder: (_, i) => _RequestCard(
                  req: c.allRequests[i],
                  showActions: false,
                  onRevoke: c.allRequests[i]['status'] == 'approved'
                      ? () => c.showRevokeDialog(c.allRequests[i])
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Discount Logs Tab ──────────────────────────────────────────────────────────

class _DiscountLogsTab extends StatelessWidget {
  const _DiscountLogsTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PermissionsController>();
    return RefreshIndicator(
      onRefresh: c.loadDiscountLogs,
      color: AppTheme.primary,
      child: Obx(() {
        if (c.isLoadingDiscount.value) return const AppLoadingWidget();
        if (c.discountError.value.isNotEmpty) {
          return AppErrorWidget(message: c.discountError.value, onRetry: c.loadDiscountLogs);
        }
        if (c.discountLogs.isEmpty) {
          return _EmptyState(
            icon: Icons.percent_rounded,
            message: 'No discount logs yet',
            color: AppColors.warning,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: c.discountLogs.length,
          itemBuilder: (_, i) => _DiscountLogCard(log: c.discountLogs[i]),
        );
      }),
    );
  }
}

// ── Product Change Logs Tab ────────────────────────────────────────────────────

class _ProductChangeLogsTab extends StatelessWidget {
  const _ProductChangeLogsTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PermissionsController>();
    return RefreshIndicator(
      onRefresh: c.loadChangeLogs,
      color: AppTheme.primary,
      child: Obx(() {
        if (c.isLoadingChangeLogs.value) return const AppLoadingWidget();
        if (c.changeLogsError.value.isNotEmpty) {
          return AppErrorWidget(message: c.changeLogsError.value, onRetry: c.loadChangeLogs);
        }
        if (c.changeLogs.isEmpty) {
          return _EmptyState(
            icon: Icons.inventory_2_rounded,
            message: 'No product changes logged yet',
            color: AppColors.primary,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: c.changeLogs.length,
          itemBuilder: (_, i) => _ChangeLogCard(log: c.changeLogs[i]),
        );
      }),
    );
  }
}

// ── Request Card ───────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> req;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRevoke;

  const _RequestCard({
    required this.req,
    required this.showActions,
    this.onApprove,
    this.onReject,
    this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    final status = req['status'] as String? ?? 'pending';
    final statusColor = _statusColor(status);
    final typeLabel = _typeLabel(req['requestType'] as String? ?? '');

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(typeLabel,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(req['staffName'] ?? '—',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          if (req['staffEmail'] != null)
            Text(req['staffEmail'],
                style: AppTypography.caption),
          const SizedBox(height: 4),
          Text('Reason: ${req['reason'] ?? '—'}',
              style: AppTypography.caption.copyWith(height: 1.4)),
          if (req['requestedMaxDiscountPercent'] != null) ...[
            const SizedBox(height: 4),
            Text('Requested discount: ${req['requestedMaxDiscountPercent']}%',
                style: AppTypography.caption),
          ],
          if ((req['requestedProductPerms'] as List?)?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Requested perms: ${(req['requestedProductPerms'] as List).join(', ')}',
              style: AppTypography.caption,
            ),
          ],
          if (req['reviewNote'] != null && (req['reviewNote'] as String).isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Note: ${req['reviewNote']}',
                style: AppTypography.caption.copyWith(
                    color: statusColor.withValues(alpha: 0.9))),
          ],
          const SizedBox(height: 4),
          Text(_formatDate(req['createdAt']), style: AppTypography.caption),

          if (showActions && (onApprove != null || onReject != null)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.errorBorder),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],

          if (!showActions && onRevoke != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRevoke,
                icon: const Icon(Icons.block_rounded, size: 14, color: AppColors.error),
                label: const Text('Revoke',
                    style: TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
    'pending'  => AppColors.warning,
    'approved' => AppColors.success,
    'rejected' => AppColors.error,
    'revoked'  => AppColors.error,
    _          => AppColors.neutral,
  };

  String _typeLabel(String t) => switch (t) {
    'discount'     => 'Discount',
    'product_edit' => 'Product Edit',
    'bulk_upload'  => 'Bulk Upload',
    _              => t,
  };

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }
}

// ── Discount Log Card ──────────────────────────────────────────────────────────

class _DiscountLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  const _DiscountLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${log['discountPercent']}% OFF',
                  style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                log['discountCode'] ?? '—',
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Staff: ${log['staffName'] ?? '—'}', style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              _amountChip('Original', log['originalAmount'], AppColors.neutral),
              const SizedBox(width: 8),
              _amountChip('Discount', log['discountAmount'], AppColors.error),
              const SizedBox(width: 8),
              _amountChip('Final', log['finalAmount'], AppColors.success),
            ],
          ),
          const SizedBox(height: 4),
          Text(_formatDate(log['appliedAt']), style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _amountChip(String label, dynamic amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 9)),
        Text(
          '₹${_fmt(amount)}',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '—';
    try {
      return (v as num).toStringAsFixed(2);
    } catch (_) {
      return v.toString();
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }
}

// ── Product Change Log Card ────────────────────────────────────────────────────

class _ChangeLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  const _ChangeLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final changeType = log['changeType'] as String? ?? '';
    final typeColor = switch (changeType) {
      'created'       => AppColors.success,
      'updated'       => AppColors.info,
      'deleted'       => AppColors.error,
      'bulk_uploaded' => AppColors.primary,
      _               => AppColors.neutral,
    };

    final changedFields = (log['changedFields'] as List?)?.cast<String>() ?? [];

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: typeColor.withValues(alpha: 0.4)),
                ),
                child: Text(changeType.toUpperCase(),
                    style: TextStyle(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text(
                log['barcode'] ?? '—',
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('By: ${log['changedByName'] ?? '—'} (${log['changedByRole'] ?? ''})',
              style: AppTypography.bodySmall),
          if (changedFields.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Fields: ${changedFields.join(', ')}',
                style: AppTypography.caption),
          ],
          const SizedBox(height: 4),
          Text(_formatDate(log['createdAt']), style: AppTypography.caption),
        ],
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.toString();
    }
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 52),
          const SizedBox(height: 12),
          Text(message,
              style: AppTypography.body.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
