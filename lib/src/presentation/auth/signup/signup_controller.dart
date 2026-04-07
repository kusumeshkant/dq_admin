import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/model/user_model.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../service_core/networks/app_logger.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../profile_setup/profile_setup_binding.dart';
import '../../profile_setup/profile_setup_page.dart';

class SignupController extends GetxController {
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl  = TextEditingController();

  final isLoading       = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm  = true.obs;
  final errorMessage    = ''.obs;

  static const _registerAdminMutation = r'''
    mutation RegisterAdmin {
      registerAdmin {
        id name email role roles storeId
      }
    }
  ''';

  Future<void> signUp() async {
    final name     = nameCtrl.text.trim();
    final email    = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm  = confirmCtrl.text;

    // ── Client-side validation (no network) ─────────────────────────────────
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address.';
      return;
    }
    if (password != confirm) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }
    if (password.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters.';
      return;
    }

    isLoading.value    = true;
    errorMessage.value = '';

    // Track Firebase user so we can roll it back if backend registration fails.
    User? firebaseUser;

    try {
      // ── Step 1: Firebase account ─────────────────────────────────────────
      AppLogger.auth('signup: creating Firebase account for $email');
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = cred.user;
      await firebaseUser?.updateDisplayName(name);
      AppLogger.auth('signup: Firebase account created uid=${firebaseUser?.uid}');

      // ── Step 2: Build GraphQL client with fresh token ────────────────────
      await GraphQLClientProvider.reinitWithToken();

      // ── Step 3: Backend registration (retry once for cold-start/latency) ─
      final userData = await _registerAdminWithRetry();

      if (userData == null) {
        // Both attempts failed — roll back Firebase to keep state consistent.
        AppLogger.auth('signup: registerAdmin failed after retry — rolling back Firebase user');
        await _rollbackFirebase(firebaseUser);
        errorMessage.value =
            'Account setup failed. Please check your connection and try again.';
        return;
      }

      AppLogger.auth('signup: backend user registered role=${userData['role']}');
      Get.find<SessionManager>().setUser(UserModel.fromJson(userData));

      // ── Step 4: Navigate to profile setup ───────────────────────────────
      Get.offAll(
        () => const ProfileSetupPage(),
        binding: ProfileSetupBinding(email: email),
      );
    } on FirebaseAuthException catch (e) {
      // Firebase errors are clean — no backend state to roll back.
      errorMessage.value = _firebaseError(e.code);
    } catch (e) {
      AppLogger.auth('signup: unexpected error — $e');
      // Roll back Firebase if it was already created.
      if (firebaseUser != null) await _rollbackFirebase(firebaseUser);
      errorMessage.value =
          'Account setup failed. Please check your connection and try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── registerAdmin with one retry (handles Vercel/backend cold-start) ───────

  Future<Map<String, dynamic>?> _registerAdminWithRetry() async {
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        AppLogger.auth('signup: registerAdmin attempt $attempt');

        final result = await GraphQLClientProvider.client.mutate(
          MutationOptions(document: gql(_registerAdminMutation)),
        );

        if (result.hasException) {
          final msg = result.exception?.graphqlErrors.firstOrNull?.message
              ?? result.exception.toString();
          AppLogger.auth('signup: registerAdmin attempt $attempt GraphQL error — $msg');

          if (attempt == 1) {
            // Brief pause then force-refresh token before retry.
            // This handles: backend cold-start, transient network hiccup,
            // Firebase token propagation delay on newly created account.
            await Future.delayed(const Duration(seconds: 2));
            await GraphQLClientProvider.reinitWithToken();
            continue;
          }
          return null;
        }

        final data = result.data?['registerAdmin'] as Map<String, dynamic>?;
        AppLogger.auth('signup: registerAdmin attempt $attempt succeeded');
        return data;
      } catch (e) {
        AppLogger.auth('signup: registerAdmin attempt $attempt threw — $e');
        if (attempt == 1) {
          await Future.delayed(const Duration(seconds: 2));
          await GraphQLClientProvider.reinitWithToken();
          continue;
        }
        return null;
      }
    }
    return null;
  }

  // ── Firebase rollback ────────────────────────────────────────────────────────

  Future<void> _rollbackFirebase(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
      AppLogger.auth('signup: Firebase user rolled back successfully');
    } catch (e) {
      // If delete fails (e.g. session already gone), log and move on.
      // The user will see "email already in use" if they try again, which
      // the error message handles.
      AppLogger.auth('signup: Firebase rollback failed — $e');
    }
  }

  // ── Firebase error messages ───────────────────────────────────────────────

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and retry.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
