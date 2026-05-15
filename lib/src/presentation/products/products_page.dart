import 'package:dq_admin/design_system/design_system.dart' show AppColors;
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/pagination/paginated_list_view.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../theme/app_theme.dart';
import 'products_controller.dart';

class ProductsPage extends StatelessWidget {
  final StoreEntity store;
  const ProductsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProductsController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('${store.name} — Products'),
          actions: [
            IconButton(
              tooltip: 'Bulk Upload',
              icon: const Icon(Icons.upload_file_rounded),
              onPressed: c.openBulkUpload,
            ),
            IconButton(
              tooltip: 'Filter',
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () => _showFilterSheet(context, c),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: c.showCreateDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Column(
          children: [
            _SearchBar(controller: c),
            Obx(() {
              final active = c.filters.isNotEmpty ||
                  c.searchQuery.value.isNotEmpty ||
                  c.sortBy.value != null;
              if (!active) return const SizedBox.shrink();
              return _ActiveFilterBar(controller: c);
            }),
            Expanded(
              child: context.isTabletOrLarger
                  ? AppPaginatedGridView<ProductEntity>(
                      controller: c,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.gridColumns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 2.6,
                      ),
                      padding: EdgeInsets.fromLTRB(
                          context.pagePadding, AppSpacing.md,
                          context.pagePadding, 100),
                      emptyTitle: 'No products found',
                      emptySubtitle: 'Try adjusting your search or filters.',
                      itemBuilder: (ctx, p, i) => _ProductCard(
                        product: p,
                        onEdit: () => c.showEditDialog(p),
                        onDelete: () => c.confirmDelete(p),
                      ),
                    )
                  : AppPaginatedListView<ProductEntity>(
                      controller: c,
                      padding: EdgeInsets.fromLTRB(
                          context.pagePadding, AppSpacing.sm,
                          context.pagePadding, 100),
                      emptyTitle: 'No products found',
                      emptySubtitle: 'Try adjusting your search or filters.',
                      emptyAction: TextButton.icon(
                        onPressed: c.clearFilters,
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        label: const Text('Clear filters'),
                      ),
                      itemBuilder: (ctx, p, i) => _ProductCard(
                        product: p,
                        onEdit: () => c.showEditDialog(p),
                        onDelete: () => c.confirmDelete(p),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  final ProductsController controller;
  const _SearchBar({required this.controller});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          context.pagePadding, AppSpacing.sm, context.pagePadding, AppSpacing.xs),
      child: TextField(
        controller: _ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: widget.controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, barcode, brand…',
          hintStyle: AppTypography.caption.copyWith(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textSecondary, size: 20),
          suffixIcon: Obx(() => widget.controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    widget.controller.onSearchChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary, size: 18),
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppTheme.primary)),
        ),
      ),
    );
  }
}

// ── Active filter chips ────────────────────────────────────────────────────────

class _ActiveFilterBar extends StatelessWidget {
  final ProductsController controller;
  const _ActiveFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
        children: [
          if (controller.filters['brand'] != null)
            _Chip(
                label: 'Brand: ${controller.filters['brand']}',
                onRemove: () => controller.applyFilter('brand', null)),
          if (controller.filters['gender'] != null)
            _Chip(
                label: 'Gender: ${controller.filters['gender']}',
                onRemove: () => controller.applyFilter('gender', null)),
          if (controller.filters['categoryMain'] != null)
            _Chip(
                label: 'Category: ${controller.filters['categoryMain']}',
                onRemove: () => controller.applyFilter('categoryMain', null)),
          if (controller.filters['inStock'] == true)
            _Chip(
                label: 'In Stock',
                onRemove: () => controller.applyFilter('inStock', null)),
          if (controller.filters['lowStock'] == true)
            _Chip(
                label: 'Low Stock',
                onRemove: () => controller.applyFilter('lowStock', null)),
          if (controller.sortBy.value != null)
            _Chip(
                label: 'Sort: ${controller.sortBy.value} ${controller.sortDir.value == 'asc' ? '↑' : '↓'}',
                onRemove: () => controller.applySort('createdAt', dir: 'desc')),
          _Chip(
              label: 'Clear all',
              color: AppColors.errorSubtle,
              onRemove: controller.clearFilters),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.onRemove, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
            color: (color ?? AppTheme.primary).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: AppTheme.textPrimary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Filter bottom sheet ────────────────────────────────────────────────────────

void _showFilterSheet(BuildContext context, ProductsController c) {
  final brand    = (c.filters['brand'] as String? ?? '').obs;
  final gender   = Rx<String?>(c.filters['gender'] as String?);
  final category = (c.filters['categoryMain'] as String? ?? '').obs;
  final inStock  = (c.filters['inStock'] as bool? ?? false).obs;
  final lowStock = (c.filters['lowStock'] as bool? ?? false).obs;
  final sortField= Rx<String?>(c.sortBy.value);
  final sortDir  = c.sortDir.value.obs;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter & Sort',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _SheetLabel('Brand'),
            const SizedBox(height: 6),
            Obx(() => _SheetTextField(
                  value: brand.value,
                  hint: 'e.g. Nike, Adidas',
                  onChanged: (v) => brand.value = v,
                )),
            const SizedBox(height: 14),

            _SheetLabel('Gender'),
            const SizedBox(height: 6),
            Obx(() => _GenderSelector(
                  value: gender.value,
                  onChange: (v) => gender.value = v,
                )),
            const SizedBox(height: 14),

            _SheetLabel('Category'),
            const SizedBox(height: 6),
            Obx(() => _SheetTextField(
                  value: category.value,
                  hint: 'e.g. Footwear, Tops',
                  onChanged: (v) => category.value = v,
                )),
            const SizedBox(height: 14),

            _SheetLabel('Stock Status'),
            const SizedBox(height: 6),
            Obx(() => Row(
                  children: [
                    _ToggleChip(
                        label: 'In Stock',
                        selected: inStock.value,
                        onTap: () {
                          inStock.value = !inStock.value;
                          if (inStock.value) lowStock.value = false;
                        }),
                    const SizedBox(width: 8),
                    _ToggleChip(
                        label: 'Low Stock',
                        selected: lowStock.value,
                        onTap: () {
                          lowStock.value = !lowStock.value;
                          if (lowStock.value) inStock.value = false;
                        }),
                  ],
                )),
            const SizedBox(height: 14),

            _SheetLabel('Sort By'),
            const SizedBox(height: 6),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    for (final f in ['name', 'price', 'stock', 'createdAt'])
                      _ToggleChip(
                          label: f == 'createdAt' ? 'Newest' : f[0].toUpperCase() + f.substring(1),
                          selected: sortField.value == f,
                          onTap: () => sortField.value = sortField.value == f ? null : f),
                  ],
                )),
            const SizedBox(height: 8),
            Obx(() => sortField.value != null && sortField.value != 'createdAt'
                ? Row(
                    children: [
                      _ToggleChip(
                          label: 'A → Z / Low → High',
                          selected: sortDir.value == 'asc',
                          onTap: () => sortDir.value = 'asc'),
                      const SizedBox(width: 8),
                      _ToggleChip(
                          label: 'Z → A / High → Low',
                          selected: sortDir.value == 'desc',
                          onTap: () => sortDir.value = 'desc'),
                    ],
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      c.clearFilters();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      final newFilters = <String, dynamic>{};
                      if (brand.value.trim().isNotEmpty)    newFilters['brand']        = brand.value.trim();
                      if (gender.value != null)             newFilters['gender']       = gender.value;
                      if (category.value.trim().isNotEmpty) newFilters['categoryMain'] = category.value.trim();
                      if (inStock.value)                    newFilters['inStock']      = true;
                      if (lowStock.value)                   newFilters['lowStock']     = true;
                      c.applyFilters(newFilters);
                      if (sortField.value != null) {
                        c.applySort(sortField.value!,
                            dir: sortField.value == 'createdAt' ? 'desc' : sortDir.value);
                      } else {
                        c.sortBy.value = null;
                      }
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Apply',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Color(0xFFCDB4DB),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8));
}

class _SheetTextField extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  const _SheetTextField(
      {required this.value, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChange;
  const _GenderSelector({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    const options = ['Male', 'Female', 'Unisex', 'Kids'];
    return Wrap(
      spacing: 8,
      children: [
        for (final g in options)
          _ToggleChip(
              label: g,
              selected: value == g,
              onTap: () => onChange(value == g ? null : g)),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
              color: selected
                  ? AppTheme.primary.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(label,
            style: AppTypography.caption.copyWith(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

// ── Product card ───────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard(
      {required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarMd - 2,
            height: AppSizes.avatarMd - 2,
            decoration: BoxDecoration(
              color: AppColors.warningSubtle,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppColors.warning, size: AppSizes.iconMd - 4),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: AppTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (product.isLowStock)
                      Container(
                        margin:
                            const EdgeInsets.only(left: AppSpacing.sm - 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm - 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warningSubtle,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm - 2),
                          border: Border.all(color: AppColors.warningBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 10),
                            SizedBox(width: 3),
                            Text('Low Stock',
                                style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                Text(
                  '${product.barcode}  ·  ₹${product.price.toStringAsFixed(0)}  ·  Stock: ${product.stock}',
                  style: AppTypography.labelSmall,
                ),
                if (product.brand != null && product.brand!.isNotEmpty)
                  Text(product.brand!,
                      style: AppTypography.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppTheme.surface,
            icon: const Icon(Icons.more_vert_rounded,
                color: AppTheme.textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }
}
