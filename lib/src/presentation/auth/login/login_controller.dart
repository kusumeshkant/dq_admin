import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repo/auth_repository.dart';
import '../../../domain/usecase/get_profile_usecase.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../dashboard/dashboard_binding.dart';
import '../../dashboard/dashboard_page.dart';
import '../../onboarding/onboarding_binding.dart';
import '../../onboarding/onboarding_page.dart';
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
      Get.find<SessionManager>().setUser(user);

      final profileIncomplete =
          (user.name == null || user.name!.isEmpty) ||
          (user.phone == null || user.phone!.isEmpty);

      if (user.isAdmin) {
        // ── Returning store owner ────────────────────────────────────────
        if (profileIncomplete) {
          Get.offAll(
            () => const ProfileSetupPage(),
            binding: ProfileSetupBinding(email: email),
          );
        } else if (user.storeId == null || user.storeId!.isEmpty) {
          Get.offAll(() => const OnboardingPage(), binding: OnboardingBinding());
        } else {
          Get.offAll(() => const DashboardPage(), binding: DashboardBinding());
        }
      } else {
        // ── Customer trying to use admin app — offer to upgrade ──────────
        final confirm = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: const Color(0xFF1A0D35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              'Register as Store Owner?',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This email is already registered as a customer on DQ.\n\nWould you like to also register as a store owner and onboard your store?',
              style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No, Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FBE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Yes, Register Store'),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (confirm != true) {
          await authRepo.signOut();
          GraphQLClientProvider.reset();
          return;
        }

        // Proceed through onboarding — upgradeToAdmin is called after store creation
        if (profileIncomplete) {
          Get.offAll(
            () => const ProfileSetupPage(),
            binding: ProfileSetupBinding(email: email),
          );
        } else {
          Get.offAll(() => const OnboardingPage(), binding: OnboardingBinding());
        }
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
