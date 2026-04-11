import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../core/widgets/app_loading_widget.dart';
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
          if (c.isLoading.value) return const AppLoadingWidget();
          if (c.stores.isEmpty) {
            return Center(
              child: Text(
                'No stores yet. Tap + to add one.',
                style: AppTypography.body
                    .copyWith(color: AppTheme.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: c.loadStores,
            color: AppTheme.primary,
            child: context.isTabletOrLarger
                ? _StoresGrid(c: c)
                : _StoresList(c: c),
          );
        }),
      ),
    );
  }
}

class _StoresList extends StatelessWidget {
  final StoresController c;
  const _StoresList({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          context.pagePadding, AppSpacing.md, context.pagePadding, 100),
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
    );
  }
}

class _StoresGrid extends StatelessWidget {
  final StoresController c;
  const _StoresGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
          context.pagePadding, AppSpacing.md, context.pagePadding, 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.8,
      ),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.store_rounded,
                  color: AppTheme.primary, size: AppSizes.iconMd - 2),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(store.name,
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.bold)),
                      ),
                      if (store.storeCode != null) ...[
                        const SizedBox(width: AppSpacing.sm - 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm - 2,
                              vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm - 3),
                            border: Border.all(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            store.storeCode!,
                            style: AppTypography.caption.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (store.address != null)
                    Text(store.address!,
                        style:
                            AppTypography.label,
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
                    child: Text('Edit',
                        style: TextStyle(color: Colors.white))),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
