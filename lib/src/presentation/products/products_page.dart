import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          if (c.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (c.products.isEmpty) {
            return const Center(
              child: Text('No products. Tap + to add one.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return RefreshIndicator(
            onRefresh: c.loadProducts,
            color: AppTheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: c.products.length,
              itemBuilder: (_, i) => _ProductCard(
                product: c.products[i],
                onEdit: () => c.showEditDialog(c.products[i]),
                onDelete: () => c.confirmDelete(c.products[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('${product.barcode}  ·  ₹${product.price.toStringAsFixed(0)}  ·  Stock: ${product.stock}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                if (product.description != null && product.description!.isNotEmpty)
                  Text(product.description!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: const Color(0xFF1E1040),
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
