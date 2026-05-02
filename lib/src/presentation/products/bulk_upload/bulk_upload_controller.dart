import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/excel_parser_service.dart';
import '../../../domain/entity/product_entity.dart';
import '../../../domain/usecase/bulk_upsert_products_usecase.dart';
import '../../../domain/usecase/get_upload_logs_usecase.dart';

enum BulkStep { idle, parsing, needsMapping, preview, uploading, done }

class BulkUploadController extends GetxController {
  final String storeId;
  final String storeName;
  final BulkUpsertProductsUseCase bulkUseCase;
  final GetUploadLogsUseCase logsUseCase;

  BulkUploadController({
    required this.storeId,
    required this.storeName,
    required this.bulkUseCase,
    required this.logsUseCase,
  });

  // ── Reactive state ────────────────────────────────────────────────────────
  final step = BulkStep.idle.obs;
  final parseError = Rx<String?>(null);
  final fileName = Rx<String?>(null);
  final totalRows = 0.obs;
  final totalColumns = 0.obs;
  final excelHeaders = <String>[].obs;

  /// Auto-resolved mapping from parseBytes + autoMap (may be partial).
  final autoMapping = <String, String>{}.obs;

  /// Final confirmed mapping used to build the product list.
  final confirmedMapping = <String, String>{}.obs;

  final parsedProducts = <BulkProductInput>[].obs;
  final result = Rx<BulkUpsertResultEntity?>(null);
  final logs = <UploadLogEntity>[].obs;
  final logsLoading = false.obs;

  /// Raw Excel data held in memory until products are built.
  ExcelParseResult? _rawParsed;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadLogs();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Pick file → parse in background → auto-map → update step.
  ///
  /// After this returns, the caller should check [step]:
  /// - [BulkStep.needsMapping] → push the mapping screen
  /// - [BulkStep.preview]      → show preview inline
  /// - [BulkStep.idle]         → parse failed, [parseError] is set
  Future<void> pickFile() async {
    parseError.value = null;
    result.value = null;

    try {
      final pick = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      if (pick == null || pick.files.isEmpty) return;

      final file = pick.files.first;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('Could not read file bytes');

      step.value = BulkStep.parsing;
      fileName.value = file.name;

      _rawParsed = await ExcelParserService.parseBytes(bytes);

      if (_rawParsed!.headers.isEmpty) {
        throw Exception('Excel sheet is empty or has no header row');
      }
      if (_rawParsed!.rows.isEmpty) {
        throw Exception('No data rows found — the sheet only has a header');
      }

      totalColumns.value = _rawParsed!.headers.length;
      totalRows.value = _rawParsed!.rows.length;
      excelHeaders.value =
          _rawParsed!.headers.where((h) => h.isNotEmpty).toList();

      final mapped = ExcelParserService.autoMap(_rawParsed!.headers);
      autoMapping.value = mapped;

      final missingRequired = ExcelParserService.requiredFields
          .where((f) => !mapped.containsKey(f))
          .toList();

      if (missingRequired.isEmpty) {
        // All required fields resolved — skip the mapping screen
        _applyMappingInternal(mapped);
      } else {
        step.value = BulkStep.needsMapping;
      }
    } catch (e) {
      parseError.value = e.toString().replaceAll('Exception: ', '');
      step.value = BulkStep.idle;
    }
  }

  /// Called by the page after the mapping screen returns a confirmed mapping.
  void applyMapping(Map<String, String> mapping) {
    _applyMappingInternal(mapping);
  }

  /// Execute the upload with the current [parsedProducts].
  Future<void> upload() async {
    if (parsedProducts.isEmpty) return;
    step.value = BulkStep.uploading;
    try {
      final res = await bulkUseCase.execute(
        storeId: storeId,
        products: List.unmodifiable(parsedProducts),
        fileName: fileName.value,
        totalRows: totalRows.value,
        totalColumns: totalColumns.value,
      );
      result.value = res;
      step.value = BulkStep.done;
      await _loadLogs();
    } catch (e) {
      step.value = BulkStep.preview;
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withValues(alpha: 0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Reset all state so the user can pick a new file.
  void reset() {
    step.value = BulkStep.idle;
    parseError.value = null;
    fileName.value = null;
    totalRows.value = 0;
    totalColumns.value = 0;
    excelHeaders.clear();
    autoMapping.clear();
    confirmedMapping.clear();
    parsedProducts.clear();
    result.value = null;
    _rawParsed = null;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _applyMappingInternal(Map<String, String> mapping) {
    confirmedMapping.value = mapping;
    final products =
        ExcelParserService.buildProducts(_rawParsed!, mapping);

    if (products.isEmpty) {
      parseError.value =
          'No valid product rows found after mapping. '
          'Make sure the Barcode and Product Name columns contain data.';
      step.value = BulkStep.idle;
      return;
    }

    parsedProducts.value = products;
    step.value = BulkStep.preview;
  }

  Future<void> _loadLogs() async {
    logsLoading.value = true;
    try {
      logs.value = await logsUseCase.execute(storeId);
    } catch (_) {}
    logsLoading.value = false;
  }
}
