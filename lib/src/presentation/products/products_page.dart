import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../core/widgets/app_loading_widget.dart';
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          onPressed: c.showCreateDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Obx(() {
          if (c.isLoading.value) return const AppLoadingWidget();
          if (c.products.isEmpty) {
            return Center(
              child: Text(
                'No products. Tap + to add one.',
                style: AppTypography.body
                    .copyWith(color: AppTheme.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: c.loadProducts,
            color: AppTheme.primary,
            child: context.isTabletOrLarger
                ? _ProductsGrid(c: c)
                : _ProductsList(c: c),
          );
        }),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  final ProductsController c;
  const _ProductsList({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          context.pagePadding, AppSpacing.md, context.pagePadding, 100),
      itemCount: c.products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: c.products[i],
        onEdit: () => c.showEditDialog(c.products[i]),
        onDelete: () => c.confirmDelete(c.products[i]),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final ProductsController c;
  const _ProductsGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
          context.pagePadding, AppSpacing.md, context.pagePadding, 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.6,
      ),
      itemCount: c.products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: c.products[i],
        onEdit: () => c.showEditDialog(c.products[i]),
        onDelete: () => c.confirmDelete(c.products[i]),
      ),
    );
  }
}

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
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.orange, size: AppSizes.iconMd - 4),
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
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm - 2),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 10),
                            SizedBox(width: 3),
                            Text('Low Stock',
                                style: TextStyle(
                                    color: Colors.red,
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
                  child:
                      Text('Edit', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
