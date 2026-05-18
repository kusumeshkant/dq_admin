import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../domain/entity/user_entity.dart';
import '../../presentation/auth/login/login_binding.dart';
import '../../presentation/auth/login/login_page.dart';
import '../../presentation/dashboard/dashboard_binding.dart';
import '../../presentation/dashboard/dashboard_page.dart';
import '../../presentation/onboarding/onboarding_binding.dart';
import '../../presentation/onboarding/onboarding_page.dart';
import '../../presentation/profile_setup/profile_setup_binding.dart';
import '../../presentation/profile_setup/profile_setup_page.dart';
import '../../routes/app_routes.dart';
import '../subscription/subscription_manager.dart';
import 'session_manager.dart';

/// Single source of truth for all post-auth routing decisions.
///
/// Route matrix:
///   isAdmin + profile complete + storeId    → Dashboard  (+ subscription load)
///   isAdmin + profile complete + no storeId → Onboarding (store creation step)
///   isAdmin + profile incomplete            → ProfileSetup
///   !isAdmin + profile complete             → Onboarding (role upgrade pending)
///   !isAdmin + profile incomplete           → Login      (partial/failed signup)
class AuthRouter {
  AuthRouter._();

  static bool _profileIncomplete(UserEntity u) =>
      (u.name == null || u.name!.isEmpty) ||
      (u.phone == null || u.phone!.isEmpty);

  // ── Explicit login / signup ─────────────────────────────────────────────────
  // Called after the user actively authenticates. Replaces the entire back-stack.
  // Caller must have already validated isAdmin (and shown a UI error if not admin).
  // This method only handles confirmed-admin routing.
  static void navigateAfterLogin(UserEntity user, String email) {
    assert(user.isAdmin, 'navigateAfterLogin must only be called for admin users');

    if (_profileIncomplete(user)) {
      Get.offAllNamed(AppRoutes.profileSetup, arguments: email);
      return;
    }

    if (user.storeId == null || user.storeId!.isEmpty) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    _loadSubscriptionAndGoToDashboard(user.storeId!);
  }

  // ── Cold-start / session restore ────────────────────────────────────────────
  // Called before runApp — returns a config instead of calling Get.offAll
  // because the navigator is not yet mounted.
  // Sets the session user as a side-effect before returning.
  static AuthStartConfig resolveStartConfig(
      SessionManager session, UserEntity user, String email) {
    session.setUser(user);

    final incomplete = _profileIncomplete(user);

    if (!user.isAdmin) {
      if (incomplete) {
        // Partial/failed signup: Firebase account exists but backend registration
        // never completed. Do not auto-route into setup — require re-auth.
        session.clearUser();
        return AuthStartConfig(
            page: const LoginPage(), binding: LoginBinding());
      }
      // Profile done but admin role not yet set (mid-onboarding).
      return AuthStartConfig(
          page: const OnboardingPage(), binding: OnboardingBinding());
    }

    if (incomplete) {
      return AuthStartConfig(
        page: const ProfileSetupPage(),
        binding: ProfileSetupBinding(email: email),
      );
    }

    if (user.storeId == null || user.storeId!.isEmpty) {
      return AuthStartConfig(
          page: const OnboardingPage(), binding: OnboardingBinding());
    }

    // Fully onboarded — load subscription in background so Dashboard renders
    // immediately and subscription data arrives reactively.
    Get.find<SubscriptionManager>().load(user.storeId!);
    return AuthStartConfig(
        page: const DashboardPage(), binding: DashboardBinding());
  }

  // ── Shared helper ───────────────────────────────────────────────────────────
  static void _loadSubscriptionAndGoToDashboard(String storeId) {
    Get.find<SubscriptionManager>().load(storeId);
    Get.offAllNamed(AppRoutes.dashboard);
  }
}

/// Carries the initial page + bindings for the cold-start route.
class AuthStartConfig {
  final Widget page;
  final Bindings binding;
  const AuthStartConfig({required this.page, required this.binding});
}
