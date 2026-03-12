import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../service_core/networks/app_logger.dart';
import '../auth/login/login_binding.dart';
import '../auth/login/login_page.dart';

class DashboardController extends GetxController {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final LogoutUseCase logoutUseCase;

  DashboardController({
    required this.getDashboardStatsUseCase,
    required this.logoutUseCase,
  });

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
    } catch (e, st) {
      AppLogger.error('DashboardController.loadStats', e, st);
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      Get.offAll(() => const LoginPage(), binding: LoginBinding());
    } catch (e, st) {
      AppLogger.error('DashboardController.logout', e, st);
    }
  }
}
