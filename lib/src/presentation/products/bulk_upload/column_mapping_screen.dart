import 'package:dq_admin/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../data/services/excel_parser_service.dart';
import '../../../theme/app_theme.dart';

/// Column mapping screen — shown when auto-mapping could not resolve all
/// required fields.
///
/// Returns `Map<String, String>` (fieldKey → excelColumnName) via
/// [Navigator.pop] when the user confirms, or `null` if they cancel.
class ColumnMappingScreen extends StatefulWidget {
  /// Actual column names read from the uploaded Excel file.
  final List<String> excelHeaders;

  /// Partial mapping from auto-detection — used to pre-fill dropdowns.
  final Map<String, String> initialMapping;

  const ColumnMappingScreen({
    super.key,
    required this.excelHeaders,
    required this.initialMapping,
  });

  @override
  State<ColumnMappingScreen> createState() => _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends State<ColumnMappingScreen> {
  static const _skip = '-- Skip --';

  // fieldKey → selected excelColumnName (null = not assigned / skipped)
  late final Map<String, String?> _mapping;
  bool _optionalExpanded = false;

  @override
  void initState() {
    super.initState();
    _mapping = {
      for (final f in ExcelParserService.allFields)
        f: _safeInitial(f),
    };
    // Auto-expand optional section when at least one optional field was
    // auto-detected — gives the admin a chance to review it.
    _optionalExpanded = ExcelParserService.optionalFields
        .any((f) => _mapping[f] != null);
  }

  /// Returns the initial value only if the header still exists in the file.
  String? _safeInitial(String field) {
    final v = widget.initialMapping[field];
    if (v == null) return null;
    return widget.excelHeaders.contains(v) ? v : null;
  }

  bool get _canConfirm =>
      ExcelParserService.requiredFields.every((f) => _mapping[f] != null);

  void _confirm() {
    final confirmed = <String, String>{
      for (final e in _mapping.entries)
        if (e.value != null) e.key: e.value!,
    };
    Navigator.pop(context, confirmed);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0622),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0622),
        title: const Text('Map Your Columns'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoBanner(excelHeaders: widget.excelHeaders),
                    const SizedBox(height: 20),
                    _sectionLabel('REQUIRED FIELDS', Colors.redAccent),
                    const SizedBox(height: 10),
                    ...ExcelParserService.requiredFields
                        .map((f) => _FieldRow(
                              field: f,
                              label: ExcelParserService.fieldLabels[f] ?? f,
                              value: _mapping[f],
                              headers: widget.excelHeaders,
                              isRequired: true,
                              skipValue: _skip,
                              onChanged: (v) => setState(
                                  () => _mapping[f] = v == _skip ? null : v),
                            )),
                    const SizedBox(height: 20),
                    _OptionalHeader(
                      expanded: _optionalExpanded,
                      mappedCount: ExcelParserService.optionalFields
                          .where((f) => _mapping[f] != null)
                          .length,
                      onTap: () =>
                          setState(() => _optionalExpanded = !_optionalExpanded),
                    ),
                    if (_optionalExpanded) ...[
                      const SizedBox(height: 10),
                      ...ExcelParserService.optionalFields
                          .map((f) => _FieldRow(
                                field: f,
                                label:
                                    ExcelParserService.fieldLabels[f] ?? f,
                                value: _mapping[f],
                                headers: widget.excelHeaders,
                                isRequired: false,
                                skipValue: _skip,
                                onChanged: (v) => setState(
                                    () => _mapping[f] =
                                        v == _skip ? null : v),
                              )),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _ConfirmBar(canConfirm: _canConfirm, onConfirm: _confirm),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final List<String> excelHeaders;
  const _InfoBanner({required this.excelHeaders});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.infoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_fix_high_rounded, color: AppColors.info, size: 16),
              SizedBox(width: 8),
              Text(
                'Column Mapping Required',
                style: TextStyle(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your file has ${excelHeaders.length} columns. '
            'We couldn\'t auto-detect all required fields. '
            'Select which column in your file corresponds to each product field.',
            style: const TextStyle(
                color: Color(0xFFCDB4DB), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: excelHeaders
                .map((h) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.infoSubtle,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        h,
                        style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String field;
  final String label;
  final String? value;
  final List<String> headers;
  final bool isRequired;
  final String skipValue;
  final void Function(String?) onChanged;

  const _FieldRow({
    required this.field,
    required this.label,
    required this.value,
    required this.headers,
    required this.isRequired,
    required this.skipValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMissing = isRequired && value == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMissing
            ? AppColors.errorSubtle
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMissing
              ? AppColors.errorBorder
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Row(
              children: [
                Icon(
                  isMissing
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: isMissing ? AppColors.error : AppColors.success,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isMissing ? Colors.redAccent : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _Dropdown(
            value: value,
            headers: headers,
            isRequired: isRequired,
            skipValue: skipValue,
            onChanged: onChanged,
          )),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value;
  final List<String> headers;
  final bool isRequired;
  final String skipValue;
  final void Function(String?) onChanged;

  const _Dropdown({
    required this.value,
    required this.headers,
    required this.isRequired,
    required this.skipValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: if current value is no longer in headers, treat as null
    final safeValue = (value != null && headers.contains(value)) ? value : null;
    // For optional dropdowns we always show skipValue as the "nothing selected" state
    final displayValue = isRequired ? safeValue : (safeValue ?? skipValue);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A0D35),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          hint: const Text(
            'Select column...',
            style: TextStyle(color: Color(0xFF7A6B8A), fontSize: 12),
          ),
          icon: const Icon(Icons.expand_more_rounded,
              color: Color(0xFFCDB4DB), size: 18),
          items: [
            if (!isRequired)
              DropdownMenuItem(
                value: skipValue,
                child: Text(
                  skipValue,
                  style: const TextStyle(
                      color: Color(0xFF7A6B8A), fontSize: 12),
                ),
              ),
            ...headers.map(
              (h) => DropdownMenuItem(
                value: h,
                child: Text(
                  h,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OptionalHeader extends StatelessWidget {
  final bool expanded;
  final int mappedCount;
  final VoidCallback onTap;

  const _OptionalHeader({
    required this.expanded,
    required this.mappedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Text(
              'OPTIONAL FIELDS',
              style: TextStyle(
                color: Color(0xFFCDB4DB),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(width: 8),
            if (mappedCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$mappedCount auto-detected',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            const Spacer(),
            Icon(
              expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: const Color(0xFFCDB4DB),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  final bool canConfirm;
  final VoidCallback onConfirm;

  const _ConfirmBar({required this.canConfirm, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0622),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canConfirm)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 14),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Assign all required fields before continuing.',
                      style: TextStyle(color: AppColors.warning, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canConfirm ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppTheme.primary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Confirm Mapping  →  Preview Data',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
