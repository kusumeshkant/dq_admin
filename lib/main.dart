import 'package:dq_admin/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_admin/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_admin/src/domain/entity/user_entity.dart';
import 'package:dq_admin/src/domain/usecase/get_profile_usecase.dart';
import 'package:dq_admin/src/presentation/auth/login/login_binding.dart';
import 'package:dq_admin/src/presentation/auth/login/login_page.dart';
import 'package:dq_admin/src/presentation/dashboard/dashboard_binding.dart';
import 'package:dq_admin/src/presentation/dashboard/dashboard_page.dart';
import 'package:dq_admin/src/presentation/onboarding/onboarding_binding.dart';
import 'package:dq_admin/src/presentation/onboarding/onboarding_page.dart';
import 'package:dq_admin/src/presentation/profile_setup/profile_setup_binding.dart';
import 'package:dq_admin/src/presentation/profile_setup/profile_setup_page.dart';
import 'package:dq_admin/src/service_core/auth/session_manager.dart';
import 'package:dq_admin/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_admin/src/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final sessionManager = Get.put(SessionManager());

  final startConfig = await _resolveStartPage(sessionManager);

  runApp(DQAdminApp(
    home: startConfig.page,
    binding: startConfig.binding,
  ));
}

/// Cold-start routing.
///
/// Priority:
///   1. Live backend profile (if reachable)  → cache it and route
///   2. Cached profile (if network fails)    → route from cache
///   3. No cache + no network                → login (Firebase session kept)
Future<_StartConfig> _resolveStartPage(SessionManager session) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    // Not signed into Firebase — clear any stale cache and go to login.
    await session.clearCache();
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  }

  try {
    await GraphQLClientProvider.reinitWithToken();

    final user = await GetProfileUseCase(
      AuthRepositoryImpl(AuthRemoteDs()),
    ).execute();

    // Cache on every successful fetch so offline cold starts work.
    await session.cacheProfile(user);
    return _routeFrom(session, user, firebaseUser.email ?? '');
  } catch (_) {
    // Network / auth error — fall back to cached profile so the user is not
    // kicked to the login screen just because the backend was momentarily
    // unreachable.
    final cached = await session.loadCachedProfile();
    if (cached != null) {
      return _routeFrom(session, cached, firebaseUser.email ?? '');
    }
    // No cache and backend unreachable — ask user to sign in when online.
    // Do NOT call FirebaseAuth.signOut(): the Firebase session is valid and
    // will work again once the network recovers.
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  }
}

/// Determines which page to open based on profile completeness and role.
///
/// Role + completeness matrix:
///   isAdmin + complete        → Dashboard
///   isAdmin + incomplete      → ProfileSetup  (mid-onboarding resume)
///   !isAdmin + complete       → Onboarding    (role set after profile done)
///   !isAdmin + incomplete     → Login         (partial/failed signup — do not
///                                              auto-route into setup without
///                                              explicit re-authentication)
_StartConfig _routeFrom(
    SessionManager session, UserEntity user, String email) {
  session.setUser(user);

  final profileIncomplete = (user.name == null || user.name!.isEmpty) ||
      (user.phone == null || user.phone!.isEmpty);

  if (!user.isAdmin) {
    if (profileIncomplete) {
      // Backend user exists but has no admin role and no profile data.
      // This is the state left by a partial/failed signup:
      //   - Firebase account was created ✅
      //   - registerAdmin never completed (or rolled back) ❌
      //   - getOrCreateUser in 'me' query auto-created a customer record
      // Routing directly to ProfileSetup here would let an incomplete
      // customer-role user continue admin onboarding silently — wrong.
      // Send to Login: user explicitly re-authenticates, then LoginController
      // routes them through the correct path.
      session.clearUser();
      return _StartConfig(page: const LoginPage(), binding: LoginBinding());
    }
    // Profile is complete but admin role not yet assigned — mid-onboarding.
    return _StartConfig(
      page: const OnboardingPage(),
      binding: OnboardingBinding(),
    );
  }

  // Confirmed admin.
  if (profileIncomplete) {
    return _StartConfig(
      page: const ProfileSetupPage(),
      binding: ProfileSetupBinding(email: email),
    );
  }

  // Profile complete but store not yet created (killed app between ProfileSetup
  // and OnboardingPage, or upgradeToAdmin not yet called).
  if (user.storeId == null || user.storeId!.isEmpty) {
    return _StartConfig(
      page: const OnboardingPage(),
      binding: OnboardingBinding(),
    );
  }

  return _StartConfig(
    page: const DashboardPage(),
    binding: DashboardBinding(),
  );
}

class _StartConfig {
  final Widget page;
  final Bindings binding;
  _StartConfig({required this.page, required this.binding});
}

class DQAdminApp extends StatelessWidget {
  final Widget home;
  final Bindings binding;

  const DQAdminApp({super.key, required this.home, required this.binding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DQ Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialBinding: binding,
      home: home,
    );
  }
}
