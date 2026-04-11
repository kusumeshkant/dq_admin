import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:flutter/foundation.dart';

import '../../domain/entity/product_entity.dart';

/// Raw output from the Excel isolate — headers and rows as sendable primitives.
class ExcelParseResult {
  final List<String> headers; // exact header text from row 0
  final List<List<String?>> rows; // trimmed string values per data row
  const ExcelParseResult({required this.headers, required this.rows});
}

/// Top-level function required by compute() — runs in a background isolate.
Map<String, dynamic> _parseExcelIsolate(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables.values.first;
  final sheetRows = sheet.rows;
  if (sheetRows.isEmpty) {
    return {'headers': <String>[], 'rows': <List<String?>>[]};
  }

  final headers = sheetRows.first
      .map((c) => c?.value?.toString().trim() ?? '')
      .toList();

  final rows = <List<String?>>[];
  for (int r = 1; r < sheetRows.length; r++) {
    rows.add(sheetRows[r].map((c) => c?.value?.toString().trim()).toList());
  }

  return {'headers': headers, 'rows': rows};
}

class ExcelParserService {
  // ── Known column name aliases → internal field key ───────────────────────
  static const Map<String, String> colMap = {
    // Barcode
    'barcode': 'barcode',
    'bar code': 'barcode',
    'barcode number': 'barcode',
    'barcode no': 'barcode',
    'item code': 'barcode',
    'itemcode': 'barcode',
    'product code': 'barcode',
    'productcode': 'barcode',
    'code': 'barcode',
    'ean': 'barcode',
    'upc': 'barcode',
    // Product name
    'product name': 'name',
    'productname': 'name',
    'item name': 'name',
    'itemname': 'name',
    'description': 'name',
    'item description': 'name',
    'product description': 'name',
    'name': 'name',
    'title': 'name',
    'article name': 'name',
    // MRP / Price
    'mrp': 'mrp',
    'price': 'mrp',
    'sale price': 'mrp',
    'selling price': 'mrp',
    'unit price': 'mrp',
    'retail price': 'mrp',
    'cost price': 'mrp',
    // Stock / Qty
    'instock': 'stock',
    'in stock': 'stock',
    'stock': 'stock',
    'opening': 'stock',
    'opening stock': 'stock',
    'closing': 'stock',
    'closing stock': 'stock',
    'qty': 'stock',
    'quantity': 'stock',
    'available qty': 'stock',
    'available': 'stock',
    'stock on hand': 'stock',
    'quantity on hand': 'stock',
    'qty on hand': 'stock',
    'on hand': 'stock',
    'on-hand': 'stock',
    'units on hand': 'stock',
    'balance': 'stock',
    // SKU
    'sku code': 'sku',
    'skucode': 'sku',
    'sku': 'sku',
    'sku no': 'sku',
    'article code': 'sku',
    // Category
    'category': 'categoryMain',
    'main category': 'categoryMain',
    'maincategory': 'categoryMain',
    'product category': 'categoryMain',
    // Sub-category
    'subcategory': 'categorySub',
    'sub category': 'categorySub',
    'sub-category': 'categorySub',
    'product sub category': 'categorySub',
    // Brand
    'brand': 'brand',
    'manufacturer': 'brand',
    'make': 'brand',
    // Color
    'color': 'color',
    'colour': 'color',
    'product color': 'color',
    // Garment size
    'garmentsize': 'sizeGarment',
    'garment size': 'sizeGarment',
    'size': 'sizeGarment',
    'clothing size': 'sizeGarment',
    // Actual size
    'actualsize': 'sizeActual',
    'actual size': 'sizeActual',
    'numeric size': 'sizeActual',
    // Gender
    'gender': 'gender',
    'sex': 'gender',
  };

  static const List<String> requiredFields = ['barcode', 'name', 'mrp', 'stock'];

  static const List<String> optionalFields = [
    'sku',
    'brand',
    'color',
    'categoryMain',
    'categorySub',
    'sizeGarment',
    'sizeActual',
    'gender',
  ];

  static const List<String> allFields = [
    'barcode',
    'name',
    'mrp',
    'stock',
    'sku',
    'brand',
    'color',
    'categoryMain',
    'categorySub',
    'sizeGarment',
    'sizeActual',
    'gender',
  ];

  static const Map<String, String> fieldLabels = {
    'barcode': 'Barcode',
    'name': 'Product Name',
    'mrp': 'MRP / Price',
    'stock': 'Stock / Qty',
    'sku': 'SKU Code',
    'brand': 'Brand',
    'color': 'Color',
    'categoryMain': 'Category',
    'categorySub': 'Sub-category',
    'sizeGarment': 'Size (Garment)',
    'sizeActual': 'Size (Actual)',
    'gender': 'Gender',
  };

  // ── Public API ────────────────────────────────────────────────────────────

  /// Parse an Excel file in a background isolate. Non-blocking.
  static Future<ExcelParseResult> parseBytes(Uint8List bytes) async {
    final map = await compute(_parseExcelIsolate, bytes);
    return ExcelParseResult(
      headers: List<String>.from(map['headers'] as List),
      rows: (map['rows'] as List)
          .map((r) => (r as List).map((v) => v as String?).toList())
          .toList(),
    );
  }

  /// Auto-map file headers to field keys using colMap + bigram similarity.
  ///
  /// Returns a map of fieldKey to excelColumnName for every field that could be
  /// resolved. Missing fields need the manual mapping screen.
  static Map<String, String> autoMap(List<String> headers) {
    final result = <String, String>{};

    // Pass 1 — exact match via colMap (normalise to lowercase + trim)
    for (final header in headers) {
      if (header.isEmpty) continue;
      final key = header.toLowerCase().trim();
      final fieldKey = colMap[key];
      if (fieldKey != null && !result.containsKey(fieldKey)) {
        result[fieldKey] = header;
      }
    }

    // Pass 2 — fuzzy bigram similarity for still-unresolved fields
    for (final field in allFields) {
      if (result.containsKey(field)) continue;

      String? bestHeader;
      double bestScore = 0.68; // minimum threshold to accept a match

      for (final header in headers) {
        if (header.isEmpty) continue;
        final hLower = header.toLowerCase().trim();

        // Compare against the field key itself
        _checkScore(hLower, field.toLowerCase(), bestScore, (s) {
          bestScore = s;
          bestHeader = header;
        });

        // Compare against every known alias for this field
        for (final entry in colMap.entries) {
          if (entry.value != field) continue;
          _checkScore(hLower, entry.key, bestScore, (s) {
            bestScore = s;
            bestHeader = header;
          });
        }
      }

      if (bestHeader != null) result[field] = bestHeader!;
    }

    return result;
  }

  /// Build products from raw parsed data and a confirmed mapping.
  ///
  /// [mapping] is fieldKey to excelColumnName (only confirmed, non-null entries).
  static List<BulkProductInput> buildProducts(
    ExcelParseResult parsed,
    Map<String, String> mapping,
  ) {
    // Build header-name → colIndex lookup
    final colIndex = <String, int>{};
    for (int i = 0; i < parsed.headers.length; i++) {
      if (parsed.headers[i].isNotEmpty) colIndex[parsed.headers[i]] = i;
    }

    // Resolve fieldKey → colIndex
    final fieldIdx = <String, int>{};
    for (final entry in mapping.entries) {
      final idx = colIndex[entry.value];
      if (idx != null) fieldIdx[entry.key] = idx;
    }

    String? getValue(List<String?> row, String key) {
      final idx = fieldIdx[key];
      if (idx == null || idx >= row.length) return null;
      final v = row[idx];
      return (v == null || v.trim().isEmpty) ? null : v.trim();
    }

    final products = <BulkProductInput>[];
    for (final row in parsed.rows) {
      final barcode = getValue(row, 'barcode') ?? '';
      final name = getValue(row, 'name') ?? '';
      if (barcode.isEmpty || name.isEmpty) continue;

      final mrp = double.tryParse(getValue(row, 'mrp') ?? '') ?? 0.0;
      final stock = int.tryParse(getValue(row, 'stock') ?? '') ?? 0;

      products.add(BulkProductInput(
        barcode: barcode,
        name: name,
        sku: getValue(row, 'sku'),
        price: mrp,
        mrp: mrp,
        stock: stock,
        brand: getValue(row, 'brand'),
        gender: getValue(row, 'gender'),
        color: getValue(row, 'color'),
        categoryMain: getValue(row, 'categoryMain'),
        categorySub: getValue(row, 'categorySub'),
        sizeGarment: getValue(row, 'sizeGarment'),
        sizeActual: getValue(row, 'sizeActual'),
      ));
    }
    return products;
  }

  // ── Similarity helpers ────────────────────────────────────────────────────

  static void _checkScore(
    String a,
    String b,
    double current,
    void Function(double) onBetter,
  ) {
    final s = _similarity(a, b);
    if (s > current) onBetter(s);
  }

  /// Dice coefficient on character bigrams (0.0–1.0).
  static double _similarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a.contains(b) || b.contains(a)) return 0.88;

    final ba = _bigrams(a);
    final bb = _bigrams(b);
    if (ba.isEmpty || bb.isEmpty) return 0.0;

    int hits = 0;
    final bCopy = List<String>.from(bb);
    for (final g in ba) {
      final i = bCopy.indexOf(g);
      if (i != -1) {
        hits++;
        bCopy.removeAt(i);
      }
    }
    return (2.0 * hits) / (ba.length + bb.length);
  }

  static List<String> _bigrams(String s) {
    if (s.length < 2) return [s];
    return [for (int i = 0; i < s.length - 1; i++) s.substring(i, i + 2)];
  }
}
