import 'package:dq_admin/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_admin/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_admin/src/domain/usecase/get_profile_usecase.dart';
import 'package:dq_admin/src/presentation/auth/login/login_binding.dart';
import 'package:dq_admin/src/presentation/auth/login/login_page.dart';
import 'package:dq_admin/src/service_core/auth/auth_router.dart';
import 'package:dq_admin/src/service_core/auth/session_manager.dart';
import 'package:dq_admin/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_admin/src/service_core/subscription/subscription_manager.dart';
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
  Get.put(SubscriptionManager());

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
Future<AuthStartConfig> _resolveStartPage(SessionManager session) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    await session.clearCache();
    return AuthStartConfig(page: const LoginPage(), binding: LoginBinding());
  }

  try {
    await GraphQLClientProvider.reinitWithToken();

    // Role gate: throws _ForbiddenException on FORBIDDEN, other exceptions
    // on network/server error (handled in catch below).
    await _assertAdminAccess();

    final user = await GetProfileUseCase(
      AuthRepositoryImpl(AuthRemoteDs()),
    ).execute();

    // Cache on every successful fetch so offline cold-starts serve correct data.
    await session.cacheProfile(user);
    return AuthRouter.resolveStartConfig(session, user, firebaseUser.email ?? '');
  } on _ForbiddenException {
    await FirebaseAuth.instance.signOut();
    await session.clearCache();
    GraphQLClientProvider.reset();
    return AuthStartConfig(page: const LoginPage(), binding: LoginBinding());
  } catch (_) {
    // Network / transient error — fall back to cached profile so the user is
    // not kicked out because the backend was briefly unreachable.
    final cached = await session.loadCachedProfile();
    if (cached != null) {
      return AuthRouter.resolveStartConfig(session, cached, firebaseUser.email ?? '');
    }
    // No cache and no network — show login, preserve Firebase session for retry.
    return AuthStartConfig(page: const LoginPage(), binding: LoginBinding());
  }
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
