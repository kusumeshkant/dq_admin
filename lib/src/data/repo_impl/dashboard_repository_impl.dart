import '../../domain/entity/dashboard_entity.dart';
import '../../domain/repo/dashboard_repository.dart';
import '../datasources/remote/dashboard_remote_ds.dart';
import '../model/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDs ds;
  DashboardRepositoryImpl(this.ds);

  @override
  Future<DashboardStatsEntity> getDashboardStats() async {
    final json = await ds.getDashboardStats();
    return DashboardStatsModel.fromJson(json);
  }

  @override
  Future<StoreStatsEntity> getStoreStats(String storeId) async {
    final json = await ds.getStoreStats(storeId);
    return StoreStatsModel.fromJson(json);
  }

  @override
  Future<StoreAnalyticsEntity> getStoreAnalytics(String? storeId) async {
    final json = await ds.getStoreAnalytics(storeId);
    return StoreAnalyticsModel.fromJson(json);
  }
}
