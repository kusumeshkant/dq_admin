import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: c.searchEmailCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Find user by email…',
                        hintStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: const Color(0x26FFFFFF),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                      ),
                      onSubmitted: (_) => c.searchByEmail(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => c.isSearching.value
                      ? const SizedBox(
                          width: 40, height: 40,
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                        )
                      : IconButton(
                          onPressed: c.searchByEmail,
                          icon: const Icon(Icons.person_search, color: AppTheme.primary),
                          tooltip: 'Find user',
                        )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (c.staff.isEmpty) {
                  return const Center(
                    child: Text('No staff users found.',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.loadData,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: c.staff.length,
                    itemBuilder: (_, i) => _StaffCard(
                      user: c.staff[i],
                      storeName: c.storeNameFor(c.staff[i].storeId),
                      onTap: () => c.showEditDialog(c.staff[i]),
                    ),
                  ),
                );
              }),
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

  const _StaffCard({required this.user, required this.storeName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final roleColor = user.isAdmin ? Colors.purple.shade300 : Colors.blue.shade300;

    return GestureDetector(
      onTap: onTap,
      child: AppGlassCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user.name ?? user.email ?? '?')[0].toUpperCase(),
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? '(No name)',
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                  if (user.email != null)
                    Text(user.email!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(storeName,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: roleColor.withValues(alpha: 0.4)),
              ),
              child: Text(user.role,
                  style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
