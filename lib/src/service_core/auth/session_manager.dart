import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/user_model.dart';
import '../../domain/entity/user_entity.dart';
import '../../presentation/auth/login/login_binding.dart';
import '../../presentation/auth/login/login_page.dart';
import '../subscription/subscription_manager.dart';

class SessionManager extends GetxService {
  static const _cacheKey = 'dq_admin_profile_v1';

  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);

  // Guard: prevents duplicate expireSession() calls when multiple
  // concurrent requests all hit 401 and all try to expire the session.
  bool _isExpiring = false;

  bool get isLoggedIn => currentUser.value != null;
  String? get adminName => currentUser.value?.name;
  String? get adminId => currentUser.value?.id;
  String? get storeId => currentUser.value?.storeId;

  void setUser(UserEntity user) {
    _isExpiring = false; // reset so future expiry works after re-login
    currentUser.value = user;
  }
  void clearUser() => currentUser.value = null;

  // ── Profile cache (shared_preferences) ──────────────────────────────────────
  // Allows cold start to succeed even when the network / backend is unavailable.

  Future<void> cacheProfile(UserEntity user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'role': user.role,
          'roles': user.roles,
          'storeId': user.storeId,
        }),
      );
    } catch (e) {
      // Non-fatal: offline cold start will fall back to login instead of cache.
      debugPrint('[SessionManager] cacheProfile failed: $e');
    }
  }

  Future<UserEntity?> loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (_) {}
  }

  // ── Session expiry ───────────────────────────────────────────────────────────
  // Called by GraphQLClientProvider when token refresh fails mid-session,
  // and by main.dart when the user explicitly signs out.

  Future<void> expireSession() async {
    if (_isExpiring) return;
    _isExpiring = true;

    // Sign out from Firebase so the next cold start finds no live credential.
    // Must happen before clearing local cache to prevent a race where a fast
    // cold start reads a non-null FirebaseAuth.instance.currentUser.
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    await clearCache();
    clearUser();
    try { Get.find<SubscriptionManager>().clear(); } catch (_) {}
    Get.closeAllSnackbars();
    if (Get.isDialogOpen ?? false) Get.back();
    if (Get.isBottomSheetOpen ?? false) Get.back();
    // Deferred to avoid "setState() called after dispose()" when dialog/sheet
    // animation is still in progress when Get.offAll fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(
        () => const LoginPage(),
        binding: LoginBinding(),
        transition: Transition.fadeIn,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Session Expired',
          'Please sign in again to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.lock_outline, color: Colors.white),
        );
        _isExpiring = false; // reset so future logins can expire again
      });
    });
  }
}
