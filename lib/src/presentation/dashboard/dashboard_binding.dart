import 'package:get/get.dart';
import '../../data/datasources/remote/dashboard_remote_ds.dart';
import '../../data/repo_impl/auth_repository_impl.dart';
import '../../data/repo_impl/dashboard_repository_impl.dart';
import '../../data/datasources/remote/auth_remote_ds.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../service_core/auth/session_manager.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    final dashboardRepo = DashboardRepositoryImpl(DashboardRemoteDs());
    final authRepo = AuthRepositoryImpl(AuthRemoteDs());
    Get.lazyPut(() => DashboardController(
          getDashboardStatsUseCase: GetDashboardStatsUseCase(dashboardRepo),
          logoutUseCase: LogoutUseCase(
            authRepository: authRepo,
            sessionManager: Get.find<SessionManager>(),
          ),
        ));
  }
}
