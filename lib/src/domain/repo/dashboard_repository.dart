import '../entity/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStatsEntity> getDashboardStats();
  Future<StoreStatsEntity> getStoreStats(String storeId);
  Future<StoreAnalyticsEntity> getStoreAnalytics(String? storeId);
  Future<CustomerRetentionEntity> getCustomerRetention(String? storeId);
  Future<List<StaffPerformanceStatEntity>> getStaffPerformance(String? storeId);
  Future<BasketAbandonmentEntity> getBasketAbandonment(String? storeId);
  Future<CustomerLTVEntity> getCustomerLTV(String? storeId);
  Future<List<MonthlyRevenueStatEntity>> getMonthlyRevenue(String? storeId, int year);
}
