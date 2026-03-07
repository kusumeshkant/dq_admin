import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/store_entity.dart';
import '../../theme/app_theme.dart';
import '../store_detail/store_detail_binding.dart';
import '../store_detail/store_detail_page.dart';
import 'stores_controller.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StoresController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Stores')),
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
          if (c.stores.isEmpty) {
            return const Center(
              child: Text('No stores yet. Tap + to add one.',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return RefreshIndicator(
            onRefresh: c.loadStores,
            color: AppTheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: c.stores.length,
              itemBuilder: (_, i) => _StoreCard(
                store: c.stores[i],
                onTap: () => Get.to(
                  () => StoreDetailPage(store: c.stores[i]),
                  binding: StoreDetailBinding(store: c.stores[i]),
                )?.then((_) => c.loadStores()),
                onEdit: () => c.showEditDialog(c.stores[i]),
                onDelete: () => c.confirmDelete(c.stores[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StoreCard({
    required this.store,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store_rounded, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(store.name,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                      if (store.storeCode != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            store.storeCode!,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (store.address != null)
                    Text(store.address!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
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
      ),
    );
  }
}
