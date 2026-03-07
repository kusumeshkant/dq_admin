import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';

class DashboardController extends GetxController {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;

  DashboardController({required this.getDashboardStatsUseCase});

  final isLoading = false.obs;
  final Rx<DashboardStatsEntity?> stats = Rx(null);
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      stats.value = await getDashboardStatsUseCase.execute();
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard.';
    } finally {
      isLoading.value = false;
    }
  }
}
