import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_stats_usecase.dart';

class StoreDetailController extends GetxController {
  final StoreEntity store;
  final GetStoreStatsUseCase getStoreStatsUseCase;

  StoreDetailController({required this.store, required this.getStoreStatsUseCase});

  final isLoading = false.obs;
  final Rx<StoreStatsEntity?> stats = Rx(null);

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      stats.value = await getStoreStatsUseCase.execute(store.id);
    } catch (_) {
      // stats may be empty for new stores — not fatal
    } finally {
      isLoading.value = false;
    }
  }
}
