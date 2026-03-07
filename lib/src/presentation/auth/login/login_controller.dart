import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repo/auth_repository.dart';
import '../../../domain/usecase/get_profile_usecase.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../dashboard/dashboard_binding.dart';
import '../../dashboard/dashboard_page.dart';
import '../../profile_setup/profile_setup_binding.dart';
import '../../profile_setup/profile_setup_page.dart';

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

      if (!user.isAdmin) {
        await authRepo.signOut();
        GraphQLClientProvider.reset();
        errorMessage.value = 'Access denied. This app is for admins only.';
        return;
      }

      Get.find<SessionManager>().setUser(user);

      // If name or phone missing → collect before going to dashboard
      final profileIncomplete =
          (user.name == null || user.name!.isEmpty) ||
          (user.phone == null || user.phone!.isEmpty);

      if (profileIncomplete) {
        Get.offAll(
          () => const ProfileSetupPage(),
          binding: ProfileSetupBinding(email: email),
        );
      } else {
        Get.offAll(() => const DashboardPage(), binding: DashboardBinding());
      }
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
    if (raw.contains('network')) return 'Network error. Check your connection.';
    return 'Login failed. Please try again.';
  }
}
