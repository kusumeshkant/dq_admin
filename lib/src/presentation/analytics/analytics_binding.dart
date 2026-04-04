import 'package:get/get.dart';
import '../../data/datasources/remote/dashboard_remote_ds.dart';
import '../../data/repo_impl/dashboard_repository_impl.dart';
import '../../domain/usecase/get_store_analytics_usecase.dart';
import 'analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    final repo = DashboardRepositoryImpl(DashboardRemoteDs());
    Get.lazyPut(() => AnalyticsController(
          getStoreAnalyticsUseCase: GetStoreAnalyticsUseCase(repo),
        ));
  }
}
