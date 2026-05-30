import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repo/auth_repository.dart';
import '../../../domain/usecase/get_profile_usecase.dart';
import '../../../service_core/auth/auth_router.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class LoginController extends GetxController {
  final AuthRepository authRepo;
  final GetProfileUseCase getProfileUseCase;

  LoginController({required this.authRepo, required this.getProfileUseCase});

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await authRepo.loginWithEmail(email, password);
      await GraphQLClientProvider.reinitWithToken();

      // validateAppAccess enforces role separation on the backend and returns
      // specific error messages when the wrong account type is used
      // (e.g. customer account, staff account, or unregistered account).
      final user = await authRepo.validateAppAccess();

      final session = Get.find<SessionManager>();
      session.setUser(user);

      // Persist the fresh profile so offline cold-starts serve correct data.
      // Without this, a user who logs in and then reopens the app offline
      // would get stale cached data (e.g. storeId: null from before onboarding).
      await session.cacheProfile(user);

      // AuthRouter is the single source of truth for routing — it also loads
      // the subscription before navigating to Dashboard.
      AuthRouter.navigateAfterLogin(user, email);
    } on FirebaseAuthException catch (e) {
      // Firebase never created a session — no cleanup needed.
      errorMessage.value = _friendlyError(e.toString());
    } catch (e) {
      // loginWithEmail succeeded (Firebase session created) but backend
      // validation failed. Clear the dangling Firebase session so a future
      // cold start doesn't bypass the login screen.
      try { await FirebaseAuth.instance.signOut(); } catch (_) {}
      GraphQLClientProvider.reset();
      errorMessage.value = _friendlyError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (raw.contains('network') || raw.contains('NO_NETWORK')) {
      return 'Network error. Check your connection.';
    }
    if (raw.contains('SESSION_EXPIRED')) {
      return 'Session expired. Please sign in again.';
    }
    // Pass through backend-originated messages verbatim — they are already
    // user-readable (account separation errors, role errors, etc.).
    if (raw.contains('Customer and admin accounts must be separate') ||
        raw.contains('Staff and admin accounts must be separate') ||
        raw.contains('No admin account found') ||
        raw.contains('does not have admin access')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return 'Login failed. Please try again.';
  }
}
