import 'package:get/get.dart';
import '../../data/datasources/remote/dashboard_remote_ds.dart';
import '../../data/repo_impl/dashboard_repository_impl.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_stats_usecase.dart';
import 'store_detail_controller.dart';

class StoreDetailBinding extends Bindings {
  final StoreEntity store;
  StoreDetailBinding({required this.store});

  @override
  void dependencies() {
    final dashboardRepo = DashboardRepositoryImpl(DashboardRemoteDs());
    Get.lazyPut(() => StoreDetailController(
          store: store,
          getStoreStatsUseCase: GetStoreStatsUseCase(dashboardRepo),
        ));
  }
}
