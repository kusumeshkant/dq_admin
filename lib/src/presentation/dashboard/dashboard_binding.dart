import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => DashboardController(
          getDashboardStatsUseCase: GetDashboardStatsUseCase(repo),
        ));
  }
}
