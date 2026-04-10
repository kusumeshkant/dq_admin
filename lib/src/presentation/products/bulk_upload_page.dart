import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/usecase/bulk_upsert_products_usecase.dart';
import '../../domain/usecase/get_upload_logs_usecase.dart';
import '../../theme/app_theme.dart';

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
  List<BulkProductInput>? _parsed;
  String? _parseError;
  bool _isUploading = false;
  BulkUpsertResultEntity? _result;

  // File metadata
  String? _fileName;
  int _totalRows = 0;
  int _totalColumns = 0;

  // Upload history
  List<UploadLogEntity> _logs = [];
  bool _logsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _logsLoading = true);
    try {
      _logs = await widget.getLogsUseCase.execute(widget.storeId);
    } catch (_) {}
    if (mounted) setState(() => _logsLoading = false);
  }

  // ── StockReport column name → normalised key ──────────────────────────────
  static const _colMap = {
    'barcode': 'barcode',
    'product name': 'name',
    'productname': 'name',
    'sku code': 'sku',
    'skucode': 'sku',
    'sku': 'sku',
    'mrp': 'mrp',
    'price': 'mrp',
    // Stock column — covers all common export formats
    'instock': 'stock',
    'in stock': 'stock',
    'stock': 'stock',
    'opening': 'stock',        // StockReport-Export format
    'opening stock': 'stock',
    'closing': 'stock',
    'closing stock': 'stock',
    'qty': 'stock',
    'quantity': 'stock',
    'available qty': 'stock',
    'available': 'stock',
    'stock on hand': 'stock',
    'quantity on hand': 'stock',
    'category': 'categoryMain',
    'subcategory': 'categorySub',
    'brand': 'brand',
    'color': 'color',
    'colour': 'color',
    'garmentsize': 'sizeGarment',
    'garment size': 'sizeGarment',
    'actualsize': 'sizeActual',
    'actual size': 'sizeActual',
    'gender': 'gender',
  };

  Future<void> _pickAndParse() async {
    setState(() { _parseError = null; _parsed = null; _result = null; });
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

      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;
      final rows = sheet.rows;
      if (rows.isEmpty) throw Exception('Excel sheet is empty');

      _fileName = file.name;
      _totalColumns = rows.first.length;

      // Read header row
      final headerRow = rows.first;
      final headers = <int, String>{};
      for (int c = 0; c < headerRow.length; c++) {
        final cell = headerRow[c];
        if (cell?.value != null) {
          final key = cell!.value.toString().trim().toLowerCase();
          final mapped = _colMap[key];
          if (mapped != null) headers[c] = mapped;
        }
      }

      if (!headers.values.contains('barcode')) {
        throw Exception('No "Barcode" column found. Check the Excel format.');
      }
      if (!headers.values.contains('name')) {
        throw Exception('No "Product Name" column found. Check the Excel format.');
      }
      if (!headers.values.contains('mrp') && !headers.values.contains('stock')) {
        throw Exception('Missing required columns (MRP, InStock).');
      }

      // Parse data rows
      final products = <BulkProductInput>[];
      for (int r = 1; r < rows.length; r++) {
        final row = rows[r];
        final vals = <String, String>{};
        for (final entry in headers.entries) {
          final idx = entry.key;
          if (idx < row.length) {
            final v = row[idx]?.value?.toString().trim() ?? '';
            if (v.isNotEmpty) vals[entry.value] = v;
          }
        }
        final barcode = vals['barcode'] ?? '';
        final name = vals['name'] ?? '';
        if (barcode.isEmpty || name.isEmpty) continue; // skip empty rows

        final mrp = double.tryParse(vals['mrp'] ?? '') ?? 0.0;
        final stock = int.tryParse(vals['stock'] ?? '') ?? 0;

        products.add(BulkProductInput(
          barcode: barcode,
          name: name,
          sku: vals['sku'],
          price: mrp,
          mrp: mrp,
          stock: stock,
          brand: vals['brand'],
          gender: vals['gender'],
          color: vals['color'],
          categoryMain: vals['categoryMain'],
          categorySub: vals['categorySub'],
          sizeGarment: vals['sizeGarment'],
          sizeActual: vals['sizeActual'],
        ));
      }

      if (products.isEmpty) throw Exception('No valid product rows found in the file.');
      _totalRows = rows.length - 1; // exclude header
      setState(() => _parsed = products);
    } catch (e) {
      setState(() => _parseError = e.toString());
    }
  }

  Future<void> _upload() async {
    if (_parsed == null) return;
    setState(() { _isUploading = true; _result = null; });
    try {
      final result = await widget.useCase.execute(
        storeId: widget.storeId,
        products: _parsed!,
        fileName: _fileName,
        totalRows: _totalRows,
        totalColumns: _totalColumns,
      );
      setState(() => _result = result);
      await _loadLogs(); // refresh history
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString(),
          backgroundColor: Colors.red.withValues(alpha: 0.85),
          colorText: Colors.white,
          duration: const Duration(seconds: 5));
    } finally {
      setState(() => _isUploading = false);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(),
              const SizedBox(height: 20),
              _PickButton(onTap: _pickAndParse),
              if (_parseError != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(_parseError!),
              ],
              if (_parsed != null) ...[
                const SizedBox(height: 20),
                _PreviewSection(products: _parsed!),
                const SizedBox(height: 20),
                _UploadButton(
                  count: _parsed!.length,
                  isUploading: _isUploading,
                  onTap: _upload,
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 20),
                _ResultCard(result: _result!),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Done — Continue Setup', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _UploadHistorySection(logs: _logs, isLoading: _logsLoading),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('Expected Excel Format',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your store\'s StockReport Excel file (.xlsx / .xls).\n'
            'Required columns: Barcode, Product Name, MRP, InStock\n'
            'Optional: Sku Code, Category, Subcategory, Brand, Color, GarmentSize, ActualSize, Gender',
            style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 12, height: 1.5),
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file_rounded, color: AppTheme.primary, size: 36),
            const SizedBox(height: 8),
            Text('Tap to select Excel file',
                style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
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
            const Icon(Icons.preview_rounded, color: Color(0xFFCDB4DB), size: 16),
            const SizedBox(width: 6),
            Text('${products.length} products ready to upload',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        ...preview.map((p) => _PreviewRow(p)),
        if (products.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('... and ${products.length - 5} more',
                style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 12)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${p.barcode}  ·  ₹${p.price.toStringAsFixed(0)}  ·  Stock: ${p.stock}',
                    style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 11)),
              ],
            ),
          ),
          if (p.brand != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(p.brand!, style: const TextStyle(color: Colors.purple, fontSize: 10)),
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
  const _UploadButton({required this.count, required this.isUploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUploading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
        ),
        child: isUploading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Upload $count Products',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
    final nothingCreated = result.created == 0 && result.updated == 0;

    final Color statusColor = hasErrors
        ? Colors.red
        : nothingCreated
            ? Colors.orange
            : Colors.green;

    final IconData statusIcon = hasErrors
        ? Icons.error_outline_rounded
        : nothingCreated
            ? Icons.warning_amber_rounded
            : Icons.check_circle_rounded;

    final String statusText = hasErrors
        ? 'Upload Failed — see errors below'
        : nothingCreated
            ? 'Nothing saved — check column names in your file'
            : 'Upload Successful!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
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
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (nothingCreated && !hasErrors) ...[
            const SizedBox(height: 8),
            Text(
              'Skipped ${result.skipped} rows. '
              'Make sure your file has columns: Barcode, Product Name, MRP, and a stock column '
              '(Opening / Stock / Qty / InStock).',
              style: TextStyle(color: statusColor, fontSize: 12, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(label: 'Created', value: result.created, color: Colors.green),
              const SizedBox(width: 10),
              _StatChip(label: 'Updated', value: result.updated, color: Colors.blue),
              const SizedBox(width: 10),
              if (result.skipped > 0)
                _StatChip(label: 'Skipped', value: result.skipped, color: Colors.orange),
              if (hasErrors) ...[
                const SizedBox(width: 10),
                _StatChip(label: 'Errors', value: result.errors.length, color: Colors.red),
              ],
            ],
          ),
          if (hasErrors) ...[
            const SizedBox(height: 12),
            const Text('Failed rows:',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...result.errors.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${e.barcode}: ${e.message}',
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Upload History ────────────────────────────────────────────────────────────

class _UploadHistorySection extends StatelessWidget {
  final List<UploadLogEntity> logs;
  final bool isLoading;
  const _UploadHistorySection({required this.logs, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, color: Color(0xFFCDB4DB), size: 16),
            SizedBox(width: 6),
            Text('Upload History',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
        else if (logs.isEmpty)
          const Text('No uploads yet.', style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 13))
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File name + timestamp
          Row(
            children: [
              const Icon(Icons.insert_drive_file_rounded, color: Color(0xFFCDB4DB), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(log.fileName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFFCDB4DB), size: 12),
              const SizedBox(width: 4),
              Text(fmt.format(log.uploadedAt.toLocal()),
                  style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline_rounded, color: Color(0xFFCDB4DB), size: 12),
              const SizedBox(width: 4),
              Text(log.uploadedByName,
                  style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          // Row/col info
          Text(
            '${log.totalRows} rows · ${log.totalColumns} columns',
            style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 11),
          ),
          const SizedBox(height: 8),
          // Stats chips
          Row(
            children: [
              _MiniChip(label: '${log.created} created', color: Colors.green),
              const SizedBox(width: 6),
              _MiniChip(label: '${log.updated} updated', color: Colors.blue),
              const SizedBox(width: 6),
              if (log.skipped > 0) ...[
                _MiniChip(label: '${log.skipped} skipped', color: Colors.orange),
                const SizedBox(width: 6),
              ],
              if (hasErrors)
                _MiniChip(label: '${log.errorCount} errors', color: Colors.red),
            ],
          ),
          if (hasErrors) ...[
            const SizedBox(height: 8),
            ...log.errors.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('• ${e.barcode}: ${e.message}',
                      style: const TextStyle(color: Colors.red, fontSize: 10)),
                )),
            if (log.errors.length > 3)
              Text('... and ${log.errors.length - 3} more errors',
                  style: const TextStyle(color: Colors.red, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
