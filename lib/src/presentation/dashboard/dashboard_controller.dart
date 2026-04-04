import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';
import '../../domain/usecase/get_store_stats_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/networks/app_logger.dart';
import '../auth/login/login_binding.dart';
import '../auth/login/login_page.dart';

class DashboardController extends GetxController {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetStoreStatsUseCase getStoreStatsUseCase;
  final LogoutUseCase logoutUseCase;

  DashboardController({
    required this.getDashboardStatsUseCase,
    required this.getStoreStatsUseCase,
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
      final storeId = Get.find<SessionManager>().storeId;
      if (storeId != null && storeId.isNotEmpty) {
        // Scoped admin — show only their store's stats
        final s = await getStoreStatsUseCase.execute(storeId);
        stats.value = DashboardStatsEntity(
          totalRevenue: s.totalRevenue,
          totalOrders: s.totalOrders,
          pendingOrders: s.pendingOrders,
          completedOrders: s.completedOrders,
          activeStores: 1,
          topStores: const [],
          recentOrders: s.recentOrders,
        );
      } else {
        stats.value = await getDashboardStatsUseCase.execute();
      }
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
