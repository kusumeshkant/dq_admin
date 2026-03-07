import 'package:dq_admin/src/data/datasources/remote/auth_remote_ds.dart';
import 'package:dq_admin/src/data/repo_impl/auth_repository_impl.dart';
import 'package:dq_admin/src/domain/usecase/get_profile_usecase.dart';
import 'package:dq_admin/src/presentation/auth/login/login_binding.dart';
import 'package:dq_admin/src/presentation/auth/login/login_page.dart';
import 'package:dq_admin/src/presentation/dashboard/dashboard_binding.dart';
import 'package:dq_admin/src/presentation/dashboard/dashboard_page.dart';
import 'package:dq_admin/src/presentation/profile_setup/profile_setup_binding.dart';
import 'package:dq_admin/src/presentation/profile_setup/profile_setup_page.dart';
import 'package:dq_admin/src/service_core/auth/session_manager.dart';
import 'package:dq_admin/src/service_core/networks/graphql_client_provider.dart';
import 'package:dq_admin/src/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

/// Determines where to send the user on cold start.
Future<_StartConfig> _resolveStartPage(SessionManager session) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  }

  try {
    await GraphQLClientProvider.reinitWithToken();

    final user = await GetProfileUseCase(
      AuthRepositoryImpl(AuthRemoteDs()),
    ).execute();

    if (!user.isAdmin) {
      await FirebaseAuth.instance.signOut();
      GraphQLClientProvider.reset();
      return _StartConfig(page: const LoginPage(), binding: LoginBinding());
    }

    session.setUser(user);

    final profileIncomplete =
        (user.name == null || user.name!.isEmpty) ||
        (user.phone == null || user.phone!.isEmpty);

    if (profileIncomplete) {
      return _StartConfig(
        page: const ProfileSetupPage(),
        binding: ProfileSetupBinding(email: firebaseUser.email ?? ''),
      );
    }

    return _StartConfig(
      page: const DashboardPage(),
      binding: DashboardBinding(),
    );
  } catch (_) {
    // If profile fetch fails (e.g. network error on cold start),
    // fall back to login so the user can try again.
    return _StartConfig(page: const LoginPage(), binding: LoginBinding());
  }
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
