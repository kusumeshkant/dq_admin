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

      final user = await getProfileUseCase.execute();

      // Reject non-admin accounts with a clear message so the user knows
      // they are using the wrong app or need to sign up as an admin.
      if (!user.isAdmin) {
        await authRepo.signOut();
        GraphQLClientProvider.reset();
        errorMessage.value =
            'This account is not registered as a store admin. '
            'Please sign up to create a new admin account, or use the correct app.';
        return;
      }

      final session = Get.find<SessionManager>();
      session.setUser(user);

      // Persist the fresh profile so offline cold-starts serve correct data.
      // Without this, a user who logs in and then reopens the app offline
      // would get stale cached data (e.g. storeId: null from before onboarding).
      await session.cacheProfile(user);

      // AuthRouter is the single source of truth for routing — it also loads
      // the subscription before navigating to Dashboard.
      AuthRouter.navigateAfterLogin(user, email);
    } catch (e) {
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
    return 'Login failed. Please try again.';
  }
}
