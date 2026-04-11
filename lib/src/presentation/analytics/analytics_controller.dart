import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_store_analytics_usecase.dart';
import '../../domain/repo/dashboard_repository.dart';
import '../../service_core/auth/session_manager.dart';

class AnalyticsController extends GetxController {
  final GetStoreAnalyticsUseCase getStoreAnalyticsUseCase;
  final DashboardRepository repo;

  AnalyticsController({
    required this.getStoreAnalyticsUseCase,
    required this.repo,
  });

  final isLoading = false.obs;
  final Rx<StoreAnalyticsEntity?> analytics = Rx(null);
  final Rx<CustomerRetentionEntity?> retention = Rx(null);
  final RxList<StaffPerformanceStatEntity> staffPerformance = <StaffPerformanceStatEntity>[].obs;
  final Rx<BasketAbandonmentEntity?> basketAbandonment = Rx(null);
  final Rx<CustomerLTVEntity?> customerLTV = Rx(null);
  final RxList<MonthlyRevenueStatEntity> monthlyRevenue = <MonthlyRevenueStatEntity>[].obs;
  final errorMessage = ''.obs;

  Future<void> _safe(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('AnalyticsController secondary load: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final session = Get.find<SessionManager>();
      final storeId = session.storeId;
      final year = DateTime.now().year;

      // Core KPIs — if this fails, show the error/retry UI
      analytics.value = await getStoreAnalyticsUseCase.execute(storeId);

      // Secondary data — load in parallel; individual failures are logged but
      // don't block the rest of the screen from rendering.
      await Future.wait([
        _safe(() async => retention.value = await repo.getCustomerRetention(storeId)),
        _safe(() async => staffPerformance.value = await repo.getStaffPerformance(storeId)),
        _safe(() async => basketAbandonment.value = await repo.getBasketAbandonment(storeId)),
        _safe(() async => customerLTV.value = await repo.getCustomerLTV(storeId)),
        _safe(() async => monthlyRevenue.value = await repo.getMonthlyRevenue(storeId, year)),
      ]);
    } catch (e) {
      debugPrint('AnalyticsController.loadAnalytics: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
