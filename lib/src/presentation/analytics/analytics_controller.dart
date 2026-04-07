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

      final results = await Future.wait([
        getStoreAnalyticsUseCase.execute(storeId),
        repo.getCustomerRetention(storeId),
        repo.getStaffPerformance(storeId),
        repo.getBasketAbandonment(storeId),
        repo.getCustomerLTV(storeId),
        repo.getMonthlyRevenue(storeId, year),
      ]);

      analytics.value = results[0] as StoreAnalyticsEntity;
      retention.value = results[1] as CustomerRetentionEntity;
      staffPerformance.value = results[2] as List<StaffPerformanceStatEntity>;
      basketAbandonment.value = results[3] as BasketAbandonmentEntity;
      customerLTV.value = results[4] as CustomerLTVEntity;
      monthlyRevenue.value = results[5] as List<MonthlyRevenueStatEntity>;
    } catch (e) {
      debugPrint('AnalyticsController.loadAnalytics: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
