import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_dashboard_stats_usecase.dart';
import '../../domain/usecase/get_store_stats_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../service_core/auth/session_manager.dart';
import '../../routes/app_routes.dart';
import '../../service_core/networks/app_logger.dart';

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
      final msg = e.toString();
      if (_isForbidden(msg)) {
        // Permissions revoked or session invalid — force re-login.
        await logout();
      } else {
        // Network or other transient error — keep stale stats (if loaded before),
        // surface a human-readable message so the UI can show a banner.
        errorMessage.value = _isNetworkError(msg)
            ? 'Cannot connect to server. Check your connection.'
            : msg;
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool _isForbidden(String msg) =>
      msg.contains('FORBIDDEN') ||
      msg.contains('Insufficient permissions') ||
      msg.contains('Not authorized');

  bool _isNetworkError(String msg) =>
      msg.contains('Network error') ||
      msg.contains('SocketException') ||
      msg.contains('network') ||
      msg.contains('Connection refused');

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      AppLogger.error('DashboardController.logout', e, st);
    }
  }
}
