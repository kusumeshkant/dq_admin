import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_stats_usecase.dart';
import 'store_detail_controller.dart';

class StoreDetailBinding extends Bindings {
  final StoreEntity store;
  StoreDetailBinding({required this.store});

  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => StoreDetailController(
          store: store,
          getStoreStatsUseCase: GetStoreStatsUseCase(repo),
        ));
  }
}
