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
import 'package:graphql_flutter/graphql_flutter.dart';
import 'firebase_options.dart';

/// Thrown only when the backend explicitly returns FORBIDDEN for the admin
/// app access check. Distinguished from generic network/server errors so that
/// the cold-start handler can sign the user out rather than falling back to
/// the cached profile.
class _ForbiddenException implements Exception {}

/// Calls validateAppAccess("ADMIN") and throws [_ForbiddenException] if the
/// backend rejects this session with FORBIDDEN.
///
/// Any non-FORBIDDEN exception (network error, 500, timeout) is rethrown as-is
/// so the caller can treat it as a transient failure and fall back to cache.
Future<void> _assertAdminAccess() async {
  const query = '''
    query ValidateAdminAccess {
      validateAppAccess(appId: "ADMIN") { id }
    }
  ''';
  final result = await GraphQLClientProvider.client.query(
    QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );
  if (result.hasException) {
    final isForbidden = result.exception?.graphqlErrors
            .any((e) => e.extensions?['code'] == 'FORBIDDEN') ??
        false;
    if (isForbidden) throw _ForbiddenException();
    // Non-FORBIDDEN (network failure, server error) — propagate so the outer
    // catch can fall back to the cached profile instead of signing out.
    throw result.exception!;
  }
}

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
///   1. Backend FORBIDDEN          → sign out, clear cache, go to login
///   2. Live backend profile       → validate access, cache profile, route
///   3. Cached profile             → route from cache (network was unreachable)
///   4. No cache + no network      → login (Firebase session kept for retry)
Future<_StartConfig> _resolveStartPage(SessionManager session) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    // Not signed into Firebase — clear any stale cache and go to login.
    await session.clearCache();
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  }

  try {
    await GraphQLClientProvider.reinitWithToken();

    // Role gate: verify this session has admin access before routing.
    // This catches revoked admins, staff/customer accounts using the wrong app,
    // and any other case where the Firebase session is valid but the backend
    // no longer grants admin access.
    //
    // Throws _ForbiddenException on FORBIDDEN → handled below (sign out).
    // Throws any other exception on network/server error → falls through to
    // the catch block where we fall back to cached profile.
    await _assertAdminAccess();

    final user = await GetProfileUseCase(
      AuthRepositoryImpl(AuthRemoteDs()),
    ).execute();

    // Cache on every successful fetch so offline cold starts work.
    await session.cacheProfile(user);
    return _routeFrom(session, user, firebaseUser.email ?? '');
  } on _ForbiddenException {
    // Definitive backend rejection (role revoked, wrong app, etc.).
    // Sign out and clear cache — do not fall back to stale cached data.
    await FirebaseAuth.instance.signOut();
    await session.clearCache();
    GraphQLClientProvider.reset();
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  } catch (_) {
    // Network / transient server error — fall back to cached profile so the
    // user is not kicked out just because the backend was briefly unreachable.
    // The Firebase session is valid; it will succeed once connectivity returns.
    final cached = await session.loadCachedProfile();
    if (cached != null) {
      return _routeFrom(session, cached, firebaseUser.email ?? '');
    }
    // No cache and backend unreachable — show login without signing out.
    // The Firebase session is preserved for the next launch.
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
