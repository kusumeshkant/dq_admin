import 'package:dq_admin/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/datasources/remote/permission_remote_ds.dart';
import '../../service_core/auth/session_manager.dart';

class PermissionsController extends GetxController {
  final PermissionRemoteDs _ds;

  PermissionsController(this._ds);

  // ── Pending requests ──────────────────────────────────────────────────────────
  final pendingRequests     = <Map<String, dynamic>>[].obs;
  final isLoadingPending    = false.obs;
  final pendingError        = ''.obs;

  // ── All requests (history) ────────────────────────────────────────────────────
  final allRequests         = <Map<String, dynamic>>[].obs;
  final isLoadingAll        = false.obs;
  final allError            = ''.obs;
  final selectedStatus      = Rx<String?>('pending');

  // ── Discount logs ─────────────────────────────────────────────────────────────
  final discountLogs        = <Map<String, dynamic>>[].obs;
  final isLoadingDiscount   = false.obs;
  final discountError       = ''.obs;

  // ── Product change logs ───────────────────────────────────────────────────────
  final changeLogs          = <Map<String, dynamic>>[].obs;
  final isLoadingChangeLogs = false.obs;
  final changeLogsError     = ''.obs;

  String get _storeId => Get.find<SessionManager>().storeId ?? '';

  @override
  void onInit() {
    super.onInit();
    loadPending();
    loadAll();
    loadDiscountLogs();
    loadChangeLogs();
  }

  Future<void> loadPending() async {
    if (_storeId.isEmpty) return;
    isLoadingPending.value = true;
    pendingError.value = '';
    try {
      pendingRequests.value = await _ds.getPendingRequests(_storeId);
    } catch (e) {
      pendingError.value = e.toString();
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> loadAll() async {
    if (_storeId.isEmpty) return;
    isLoadingAll.value = true;
    allError.value = '';
    try {
      allRequests.value = await _ds.getAllRequests(_storeId, status: selectedStatus.value);
    } catch (e) {
      allError.value = e.toString();
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> loadDiscountLogs() async {
    if (_storeId.isEmpty) return;
    isLoadingDiscount.value = true;
    discountError.value = '';
    try {
      discountLogs.value = await _ds.getDiscountLogs(_storeId);
    } catch (e) {
      discountError.value = e.toString();
    } finally {
      isLoadingDiscount.value = false;
    }
  }

  Future<void> loadChangeLogs() async {
    if (_storeId.isEmpty) return;
    isLoadingChangeLogs.value = true;
    changeLogsError.value = '';
    try {
      changeLogs.value = await _ds.getProductChangeLogs(_storeId);
    } catch (e) {
      changeLogsError.value = e.toString();
    } finally {
      isLoadingChangeLogs.value = false;
    }
  }

  void onStatusFilterChanged(String? status) {
    selectedStatus.value = status;
    loadAll();
  }

  // ── Approve ───────────────────────────────────────────────────────────────────

  void showApproveDialog(Map<String, dynamic> req) {
    final noteCtrl = TextEditingController();
    final discountCtrl = TextEditingController(
      text: req['requestedMaxDiscountPercent']?.toString() ?? '',
    );
    final isSaving = false.obs;

    final requestType = req['requestType'] as String? ?? '';
    final isDiscount = requestType == 'discount';
    final isProductEdit = requestType == 'product_edit';

    final requestedPerms = (req['requestedProductPerms'] as List?)?.cast<String>() ?? [];
    final selectedPerms = requestedPerms.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        title: Text(
          'Approve — ${_typeLabel(requestType)}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogLabel('Staff: ${req['staffName'] ?? '—'}'),
              _dialogLabel('Reason: ${req['reason'] ?? '—'}'),
              const SizedBox(height: 12),
              if (isDiscount) ...[
                _dialogLabel('Requested: ${req['requestedMaxDiscountPercent']}%'),
                const SizedBox(height: 6),
                _dialogInput(
                  controller: discountCtrl,
                  hint: 'Granted max discount %',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
              ],
              if (isProductEdit) ...[
                _dialogLabel('Select permissions to grant:'),
                const SizedBox(height: 4),
                ...['canEditProductInfo', 'canAddProduct', 'canDeleteProduct'].map((perm) {
                  return Obx(() => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: selectedPerms.contains(perm),
                    title: Text(_permLabel(perm),
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    checkColor: Colors.white,
                    activeColor: AppColors.success,
                    onChanged: (v) {
                      if (v == true) {
                        selectedPerms.add(perm);
                      } else {
                        selectedPerms.remove(perm);
                      }
                    },
                  ));
                }),
                const SizedBox(height: 8),
              ],
              _dialogInput(controller: noteCtrl, hint: 'Review note (optional)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: isSaving.value
                ? null
                : () async {
                    isSaving.value = true;
                    try {
                      await _ds.approveRequest(
                        requestId: req['id'],
                        reviewNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                        grantedMaxDiscountPercent: isDiscount
                            ? double.tryParse(discountCtrl.text.trim())
                            : null,
                        grantedProductPerms: isProductEdit ? selectedPerms.toList() : null,
                      );
                      Get.back();
                      Get.snackbar('Approved', 'Permission granted to ${req['staffName']}',
                          backgroundColor: AppColors.success, colorText: Colors.white);
                      await loadPending();
                      await loadAll();
                    } catch (e) {
                      Get.snackbar('Error', e.toString(),
                          backgroundColor: AppColors.error, colorText: Colors.white);
                    } finally {
                      isSaving.value = false;
                    }
                  },
            child: isSaving.value
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Approve'),
          )),
        ],
      ),
    );
  }

  // ── Reject ────────────────────────────────────────────────────────────────────

  void showRejectDialog(Map<String, dynamic> req) {
    final noteCtrl = TextEditingController();
    final isSaving = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        title: const Text('Reject Request', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogLabel('Staff: ${req['staffName'] ?? '—'}'),
            _dialogLabel('Request: ${_typeLabel(req['requestType'] ?? '')}'),
            const SizedBox(height: 12),
            _dialogInput(controller: noteCtrl, hint: 'Reason for rejection (optional)'),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: isSaving.value
                ? null
                : () async {
                    isSaving.value = true;
                    try {
                      await _ds.rejectRequest(
                        requestId: req['id'],
                        reviewNote: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                      );
                      Get.back();
                      Get.snackbar('Rejected', 'Request rejected',
                          backgroundColor: AppColors.warning, colorText: Colors.white);
                      await loadPending();
                      await loadAll();
                    } catch (e) {
                      Get.snackbar('Error', e.toString(),
                          backgroundColor: AppColors.error, colorText: Colors.white);
                    } finally {
                      isSaving.value = false;
                    }
                  },
            child: isSaving.value
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Reject'),
          )),
        ],
      ),
    );
  }

  // ── Revoke ────────────────────────────────────────────────────────────────────

  void showRevokeDialog(Map<String, dynamic> req) {
    final isSaving = false.obs;
    final permTypes = ['discount', 'product_edit', 'bulk_upload'];
    final selectedType = (req['requestType'] as String? ?? 'discount').obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        title: const Text('Revoke Permission', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogLabel('Staff: ${req['staffName'] ?? '—'}'),
            const SizedBox(height: 12),
            const Text('Permission type to revoke:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Obx(() => DropdownButtonFormField<String>(
              value: selectedType.value,
              dropdownColor: const Color(0xFF1E1040),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0x26FFFFFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0x33FFFFFF))),
              ),
              items: permTypes.map((t) => DropdownMenuItem(
                value: t, child: Text(_typeLabel(t)),
              )).toList(),
              onChanged: (v) => selectedType.value = v ?? 'discount',
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: isSaving.value
                ? null
                : () async {
                    isSaving.value = true;
                    try {
                      await _ds.revokePermission(
                        staffId: req['staffId'],
                        storeId: _storeId,
                        permissionType: selectedType.value,
                      );
                      Get.back();
                      Get.snackbar('Revoked', 'Permission revoked for ${req['staffName']}',
                          backgroundColor: AppColors.error, colorText: Colors.white);
                      await loadAll();
                    } catch (e) {
                      Get.snackbar('Error', e.toString(),
                          backgroundColor: AppColors.error, colorText: Colors.white);
                    } finally {
                      isSaving.value = false;
                    }
                  },
            child: isSaving.value
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Revoke'),
          )),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _typeLabel(String t) => switch (t) {
    'discount'     => 'Discount',
    'product_edit' => 'Product Edit',
    'bulk_upload'  => 'Bulk Upload',
    _              => t,
  };

  String _permLabel(String p) => switch (p) {
    'canEditProductInfo' => 'Edit product info',
    'canAddProduct'      => 'Add products',
    'canDeleteProduct'   => 'Delete products',
    _                    => p,
  };

  Widget _dialogLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  );

  Widget _dialogInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0x26FFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x33FFFFFF))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x33FFFFFF))),
        ),
      );
}
