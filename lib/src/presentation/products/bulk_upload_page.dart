import 'package:dq_admin/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/services/excel_parser_service.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/usecase/bulk_upsert_products_usecase.dart';
import '../../domain/usecase/get_upload_logs_usecase.dart';
import '../../service_core/subscription/feature_keys.dart';
import '../../service_core/subscription/subscription_manager.dart';
import '../../theme/app_theme.dart';
import 'bulk_upload/bulk_upload_controller.dart';
import 'bulk_upload/column_mapping_screen.dart';
import '../../routes/app_routes.dart';

class BulkUploadPage extends StatefulWidget {
  final String storeId;
  final String storeName;
  final BulkUpsertProductsUseCase useCase;
  final GetUploadLogsUseCase getLogsUseCase;

  const BulkUploadPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.useCase,
    required this.getLogsUseCase,
  });

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  late final BulkUploadController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(BulkUploadController(
      storeId: widget.storeId,
      storeName: widget.storeName,
      bulkUseCase: widget.useCase,
      logsUseCase: widget.getLogsUseCase,
    ));
  }

  @override
  void dispose() {
    Get.delete<BulkUploadController>();
    super.dispose();
  }

  /// Picks a file, parses it, and — if needed — pushes the mapping screen.
  Future<void> _handlePickFile() async {
    await _ctrl.pickFile();
    if (!mounted) return;

    if (_ctrl.step.value == BulkStep.needsMapping) {
      final confirmed = await Navigator.push<Map<String, String>>(
        context,
        MaterialPageRoute(
          builder: (_) => ColumnMappingScreen(
            excelHeaders: _ctrl.excelHeaders.toList(),
            initialMapping: Map<String, String>.from(_ctrl.autoMapping),
          ),
        ),
      );

      if (!mounted) return;
      if (confirmed != null) {
        _ctrl.applyMapping(confirmed);
      } else {
        _ctrl.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0622),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0622),
        title: Text('Bulk Upload — ${widget.storeName}'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!Get.find<SubscriptionManager>().canUse(FeatureKeys.bulkUpload)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Bulk Excel Upload',
                        style: AppTypography.titleMedium
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to Starter or higher to upload your entire product catalogue from Excel in one click.',
                      style: AppTypography.body.copyWith(
                          color: AppTheme.textSecondary, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.plans),
                      icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                      label: const Text('View Plans',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final step = _ctrl.step.value;

          // ── Parsing spinner ──────────────────────────────────────────────
          if (step == BulkStep.parsing || step == BulkStep.needsMapping) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      color: AppTheme.primary, strokeWidth: 2),
                  SizedBox(height: 16),
                  Text('Reading file…',
                      style: TextStyle(
                          color: Color(0xFFCDB4DB), fontSize: 13)),
                ],
              ),
            );
          }

          // ── Scrollable body ──────────────────────────────────────────────
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                const _InfoCard(),
                const SizedBox(height: 20),

                // File pick button — visible when idle or after done (re-upload)
                if (step == BulkStep.idle || step == BulkStep.done)
                  _PickButton(onTap: _handlePickFile),

                // Parse error
                if (_ctrl.parseError.value != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(_ctrl.parseError.value!),
                ],

                // Mapping confirmation banner + preview + upload button
                if (step == BulkStep.preview ||
                    step == BulkStep.uploading) ...[
                  _MappingBanner(ctrl: _ctrl),
                  const SizedBox(height: 16),
                  _PreviewSection(products: _ctrl.parsedProducts),
                  const SizedBox(height: 20),
                  _UploadButton(
                    count: _ctrl.parsedProducts.length,
                    isUploading: step == BulkStep.uploading,
                    onTap: _ctrl.upload,
                  ),
                ],

                // Result card + done button
                if (step == BulkStep.done &&
                    _ctrl.result.value != null) ...[
                  const SizedBox(height: 20),
                  _ResultCard(result: _ctrl.result.value!),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Done — Continue Setup',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                _UploadHistorySection(
                  logs: _ctrl.logs.toList(),
                  isLoading: _ctrl.logsLoading.value,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Mapping confirmation banner ───────────────────────────────────────────────

class _MappingBanner extends StatelessWidget {
  final BulkUploadController ctrl;
  const _MappingBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final mapping = ctrl.confirmedMapping;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successSubtle,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd - 2),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ctrl.fileName.value ?? 'File loaded',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ExcelParserService.requiredFields.map((f) {
              final col = mapping[f] ?? '—';
              final label = ExcelParserService.fieldLabels[f] ?? f;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$label → $col',
                  style: const TextStyle(
                      color: AppColors.success, fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Presentational widgets (stateless, no business logic) ─────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoSubtle,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 18),
              SizedBox(width: 8),
              Text(
                'Bulk Product Upload',
                style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Upload any Excel file (.xlsx / .xls) from your POS or inventory system.\n'
            'Required columns: Barcode, Product Name, MRP, Stock\n'
            'If your column names differ, you\'ll get a one-time mapping screen.',
            style: TextStyle(
                color: Color(0xFFCDB4DB), fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PickButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl - 2),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file_rounded,
                color: AppTheme.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              'Tap to select Excel file',
              style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('.xlsx or .xls',
                style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorSubtle,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd - 2),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style:
                    const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final List<BulkProductInput> products;
  const _PreviewSection({required this.products});

  @override
  Widget build(BuildContext context) {
    final preview = products.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.preview_rounded,
                color: Color(0xFFCDB4DB), size: 16),
            const SizedBox(width: 6),
            Text(
              '${products.length} products ready to upload',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...preview.map((p) => _PreviewRow(p)),
        if (products.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '… and ${products.length - 5} more',
              style: const TextStyle(
                  color: Color(0xFFCDB4DB), fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final BulkProductInput p;
  const _PreviewRow(this.p);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${p.barcode}  ·  ₹${p.price.toStringAsFixed(0)}  ·  Stock: ${p.stock}',
                  style: const TextStyle(
                      color: Color(0xFFCDB4DB), fontSize: 11),
                ),
              ],
            ),
          ),
          if (p.brand != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(p.brand!,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final int count;
  final bool isUploading;
  final VoidCallback onTap;
  const _UploadButton(
      {required this.count,
      required this.isUploading,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUploading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          disabledBackgroundColor:
              AppTheme.primary.withValues(alpha: 0.5),
        ),
        child: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(
                'Upload $count Products',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final BulkUpsertResultEntity result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final hasErrors = result.errors.isNotEmpty;
    final nothingCreated =
        result.created == 0 && result.updated == 0;

    final Color statusColor = hasErrors
        ? AppColors.error
        : nothingCreated
            ? AppColors.warning
            : AppColors.success;

    final IconData statusIcon = hasErrors
        ? Icons.error_outline_rounded
        : nothingCreated
            ? Icons.warning_amber_rounded
            : Icons.check_circle_rounded;

    final String statusText = hasErrors
        ? 'Upload Failed — see errors below'
        : nothingCreated
            ? 'Nothing saved — check column mapping'
            : 'Upload Successful!';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          if (nothingCreated && !hasErrors) ...[
            const SizedBox(height: 8),
            Text(
              'Skipped ${result.skipped} rows. '
              'Try re-uploading with corrected column mapping.',
              style: TextStyle(
                  color: statusColor, fontSize: 12, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                  label: 'Created',
                  value: result.created,
                  color: AppColors.success),
              const SizedBox(width: 10),
              _StatChip(
                  label: 'Updated',
                  value: result.updated,
                  color: AppColors.info),
              const SizedBox(width: 10),
              if (result.skipped > 0)
                _StatChip(
                    label: 'Skipped',
                    value: result.skipped,
                    color: AppColors.warning),
              if (hasErrors) ...[
                const SizedBox(width: 10),
                _StatChip(
                    label: 'Errors',
                    value: result.errors.length,
                    color: AppColors.error),
              ],
            ],
          ),
          if (hasErrors) ...[
            const SizedBox(height: 12),
            const Text('Failed rows:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...result.errors.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${e.barcode}: ${e.message}',
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 11),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Upload history ────────────────────────────────────────────────────────────

class _UploadHistorySection extends StatelessWidget {
  final List<UploadLogEntity> logs;
  final bool isLoading;
  const _UploadHistorySection(
      {required this.logs, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded,
                color: Color(0xFFCDB4DB), size: 16),
            SizedBox(width: 6),
            Text('Upload History',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2))
        else if (logs.isEmpty)
          const Text('No uploads yet.',
              style:
                  TextStyle(color: Color(0xFFCDB4DB), fontSize: 13))
        else
          ...logs.map((l) => _LogCard(log: l)),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  final UploadLogEntity log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final hasErrors = log.errorCount > 0;
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insert_drive_file_rounded,
                  color: Color(0xFFCDB4DB), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(log.fileName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: Color(0xFFCDB4DB), size: 12),
              const SizedBox(width: 4),
              Text(fmt.format(log.uploadedAt.toLocal()),
                  style: const TextStyle(
                      color: Color(0xFFCDB4DB), fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline_rounded,
                  color: Color(0xFFCDB4DB), size: 12),
              const SizedBox(width: 4),
              Text(log.uploadedByName,
                  style: const TextStyle(
                      color: Color(0xFFCDB4DB), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${log.totalRows} rows · ${log.totalColumns} columns',
            style: const TextStyle(
                color: Color(0xFFCDB4DB), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniChip(
                  label: '${log.created} created',
                  color: AppColors.success),
              const SizedBox(width: 6),
              _MiniChip(
                  label: '${log.updated} updated',
                  color: AppColors.info),
              if (log.skipped > 0) ...[
                const SizedBox(width: 6),
                _MiniChip(
                    label: '${log.skipped} skipped',
                    color: AppColors.warning),
              ],
              if (hasErrors) ...[
                const SizedBox(width: 6),
                _MiniChip(
                    label: '${log.errorCount} errors',
                    color: AppColors.error),
              ],
            ],
          ),
          if (hasErrors) ...[
            const SizedBox(height: 8),
            ...log.errors.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• ${e.barcode}: ${e.message}',
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 10),
                  ),
                )),
            if (log.errors.length > 3)
              Text(
                '… and ${log.errors.length - 3} more errors',
                style: const TextStyle(
                    color: AppColors.error, fontSize: 10),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Chips ─────────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
