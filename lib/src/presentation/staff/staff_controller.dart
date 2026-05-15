import 'package:dq_admin/design_system/design_system.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/pagination/page_result.dart';
import '../../core/pagination/paginated_controller.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/staff_repository.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/get_user_by_email_usecase.dart';
import '../../domain/usecase/update_user_role_usecase.dart';

class StaffController extends PaginatedController<UserEntity> {
  final StaffRepository _repo;
  final GetAllStoresUseCase getAllStoresUseCase;
  final GetUserByEmailUseCase getUserByEmailUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;

  StaffController({
    required StaffRepository repo,
    required this.getAllStoresUseCase,
    required this.getUserByEmailUseCase,
    required this.updateUserRoleUseCase,
  }) : _repo = repo;

  final isSearching     = false.obs;
  final stores          = <StoreEntity>[].obs;
  final searchEmailCtrl = TextEditingController();

  final roleOptions = ['customer', 'staff', 'admin'];

  @override
  void onInit() {
    super.onInit();
    _loadStores();
  }

  @override
  void onClose() {
    searchEmailCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadStores() async {
    try { stores.value = await getAllStoresUseCase.execute(); } catch (_) {}
  }

  @override
  Future<PageResult<UserEntity>> fetchPage(PageParams params) => _repo.getStaffPage(params);

  Future<void> searchByEmail() async {
    final email = searchEmailCtrl.text.trim();
    if (email.isEmpty) return;
    isSearching.value = true;
    try {
      final user = await getUserByEmailUseCase.execute(email);
      if (user == null) {
        Get.snackbar('Not Found', 'No user found with that email.',
            backgroundColor: AppColors.warning,
            colorText: Colors.white);
        return;
      }
      showEditDialog(user);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isSearching.value = false;
    }
  }

  String storeNameFor(String? storeId) {
    if (storeId == null) return 'Unassigned';
    return stores.firstWhereOrNull((s) => s.id == storeId)?.name ?? 'Unknown';
  }

  void showEditDialog(UserEntity user) {
    final selectedRole    = (user.role).obs;
    final selectedStoreId = Rx<String?>(user.storeId);
    final isSaving        = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        title: Text(user.name ?? user.email ?? 'Staff Member',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null)
              Text(user.email!, style: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 13)),
            const SizedBox(height: 16),

            const Text('Role', style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 12)),
            const SizedBox(height: 6),
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedRole.value,
                  dropdownColor: const Color(0xFF1E1040),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0x26FFFFFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                  ),
                  items: roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => selectedRole.value = v ?? 'customer',
                )),
            const SizedBox(height: 12),

            const Text('Assigned Store', style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 12)),
            const SizedBox(height: 6),
            Obx(() => DropdownButtonFormField<String?>(
                  value: selectedStoreId.value,
                  dropdownColor: const Color(0xFF1E1040),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0x26FFFFFF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => selectedStoreId.value = v,
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        try {
                          final updated = await updateUserRoleUseCase.execute(
                            userId: user.id,
                            role: selectedRole.value,
                            storeId: selectedStoreId.value,
                          );
                          final idx = items.indexWhere((u) => u.id == user.id);
                          if (idx != -1) items[idx] = updated;
                          Get.back();
                          Get.snackbar('Done', 'Updated successfully',
                              backgroundColor: AppColors.success,
                              colorText: Colors.white);
                        } catch (e) {
                          Get.snackbar('Error', e.toString(),
                              backgroundColor: AppColors.error,
                              colorText: Colors.white);
                        } finally {
                          isSaving.value = false;
                        }
                      },
                child: isSaving.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              )),
        ],
      ),
    );
  }
}
