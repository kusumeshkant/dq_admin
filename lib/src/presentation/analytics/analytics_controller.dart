import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/get_store_analytics_usecase.dart';
import '../../service_core/auth/session_manager.dart';

class AnalyticsController extends GetxController {
  final GetStoreAnalyticsUseCase getStoreAnalyticsUseCase;
  AnalyticsController({required this.getStoreAnalyticsUseCase});

  final isLoading = false.obs;
  final Rx<StoreAnalyticsEntity?> analytics = Rx(null);
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
      analytics.value = await getStoreAnalyticsUseCase.execute(session.storeId);
    } catch (e) {
      debugPrint('AnalyticsController.loadAnalytics: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
