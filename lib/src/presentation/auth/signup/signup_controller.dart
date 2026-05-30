import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/model/user_model.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../service_core/networks/app_logger.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../../routes/app_routes.dart';

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
      // Sign out any stale session first (handles deleted-user edge case where
      // FirebaseAuth still has a cached currentUser for the deleted account).
      if (FirebaseAuth.instance.currentUser != null) {
        AppLogger.auth('signup: signing out stale Firebase session before creating new account');
        try { await FirebaseAuth.instance.signOut(); } catch (_) {}
      }

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
        // All retryable attempts failed — roll back Firebase.
        AppLogger.auth('signup: registerAdmin failed after all retries — rolling back Firebase user');
        await _rollbackFirebase(firebaseUser);
        errorMessage.value =
            'Account setup failed. Please tap "Create Account" to try again.';
        return;
      }

      AppLogger.auth('signup: backend user registered role=${userData['role']}');
      Get.find<SessionManager>().setUser(UserModel.fromJson(userData));

      // ── Step 4: Navigate to profile setup ───────────────────────────────
      Get.offAllNamed(AppRoutes.profileSetup, arguments: email);
    } on FirebaseAuthException catch (e) {
      // Firebase errors are clean — no backend state to roll back.
      errorMessage.value = _firebaseError(e.code);
    } on _ServerError catch (e) {
      // Definitive server rejection (FORBIDDEN, etc.) — roll back Firebase
      // and show the server's message directly.
      AppLogger.auth('signup: non-retryable server error — ${e.message}');
      await _rollbackFirebase(firebaseUser);
      errorMessage.value = e.message;
    } catch (e) {
      AppLogger.auth('signup: unexpected error — $e');
      if (firebaseUser != null) await _rollbackFirebase(firebaseUser);
      final isNetworkIssue = e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection');
      errorMessage.value = isNetworkIssue
          ? 'No internet connection. Please check your network and try again.'
          : 'Account setup failed. Please tap "Create Account" to try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── registerAdmin with retries (handles Vercel cold-start + token propagation)
  //
  // 3 attempts with progressive back-off: 5 s, then 10 s.
  // Only retries on network/timeout/UNAUTHENTICATED errors.
  // Non-retryable server errors (FORBIDDEN, BAD_USER_INPUT) are thrown
  // immediately so the caller can surface the server's message directly.

  static const _retryDelays = [5, 10]; // seconds before attempt 2, then attempt 3

  // Error codes that should never be retried — the server's response is definitive.
  static const _nonRetryableCodes = {'FORBIDDEN', 'BAD_USER_INPUT', 'NOT_FOUND'};

  Future<Map<String, dynamic>?> _registerAdminWithRetry() async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        AppLogger.auth('signup: registerAdmin attempt $attempt');

        final result = await GraphQLClientProvider.client.mutate(
          MutationOptions(document: gql(_registerAdminMutation)),
        );

        if (result.hasException) {
          final firstError = result.exception?.graphqlErrors.firstOrNull;
          final code = firstError?.extensions?['code'] as String?;
          final msg = firstError?.message ?? result.exception.toString();
          AppLogger.auth('signup: attempt $attempt error — code=$code msg=$msg');

          // Non-retryable: throw so signUp() shows the server message directly.
          if (code != null && _nonRetryableCodes.contains(code)) {
            throw _ServerError(msg);
          }

          if (attempt < 3) {
            await Future.delayed(Duration(seconds: _retryDelays[attempt - 1]));
            await GraphQLClientProvider.reinitWithToken();
            continue;
          }
          return null;
        }

        final data = result.data?['registerAdmin'] as Map<String, dynamic>?;
        AppLogger.auth('signup: registerAdmin attempt $attempt succeeded');
        return data;
      } on _ServerError {
        rethrow; // surface immediately, no retry
      } catch (e) {
        AppLogger.auth('signup: attempt $attempt threw — $e');
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: _retryDelays[attempt - 1]));
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

// Carries the server's error message out of _registerAdminWithRetry without
// being caught and retried by the generic catch block.
class _ServerError implements Exception {
  final String message;
  const _ServerError(this.message);
}
