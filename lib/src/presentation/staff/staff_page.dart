import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/pagination/paginated_list_view.dart';
import '../../core/responsive/app_responsive.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_sizes.dart';
import '../../core/responsive/app_typography.dart';
import '../../domain/entity/user_entity.dart';
import '../../theme/app_theme.dart';
import 'staff_controller.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StaffController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Staff Management')),
        body: Column(
          children: [
            // Email lookup (separate from list search)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  context.pagePadding, AppSpacing.md, context.pagePadding, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.searchEmailCtrl,
                      style: AppTypography.body,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Find user by email…',
                        hintStyle: AppTypography.body
                            .copyWith(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.cardSurface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md + 2,
                            vertical: AppSpacing.sm + 2),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          borderSide:
                              const BorderSide(color: AppTheme.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          borderSide:
                              const BorderSide(color: AppTheme.cardBorder),
                        ),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textSecondary,
                            size: AppSizes.iconMd - 4),
                      ),
                      onSubmitted: (_) => c.searchByEmail(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Obx(() => c.isSearching.value
                      ? const SizedBox(
                          width: AppSizes.touchTarget,
                          height: AppSizes.touchTarget,
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.primary)),
                        )
                      : IconButton(
                          onPressed: c.searchByEmail,
                          icon: const Icon(Icons.person_search,
                              color: AppTheme.primary),
                          tooltip: 'Find user',
                        )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Paginated staff list
            Expanded(
              child: AppPaginatedListView<UserEntity>(
                controller: c,
                emptyTitle: 'No staff users found',
                padding: EdgeInsets.fromLTRB(
                    context.pagePadding, AppSpacing.xs,
                    context.pagePadding, 40),
                itemBuilder: (_, user, __) => _StaffCard(
                  user: user,
                  storeName: c.storeNameFor(user.storeId),
                  onTap: () => c.showEditDialog(user),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final UserEntity user;
  final String storeName;
  final VoidCallback onTap;

  const _StaffCard(
      {required this.user, required this.storeName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final roleColor = user.isAdmin ? AppColors.primary : AppColors.info;

    return GestureDetector(
      onTap: onTap,
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Row(
          children: [
            Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user.name ?? user.email ?? '?')[0].toUpperCase(),
                  style: AppTypography.titleSmall.copyWith(color: roleColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? '(No name)',
                      style: AppTypography.bodySmall
                          .copyWith(fontWeight: FontWeight.bold)),
                  if (user.email != null)
                    Text(user.email!, style: AppTypography.labelSmall),
                  Text(storeName, style: AppTypography.labelSmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(color: roleColor.withValues(alpha: 0.4)),
              ),
              child: Text(user.role,
                  style: AppTypography.labelSmall.copyWith(
                      color: roleColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
