import '../entity/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStatsEntity> getDashboardStats();
  Future<StoreStatsEntity> getStoreStats(String storeId);
}
