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

  @override
  Future<CustomerRetentionEntity> getCustomerRetention(String? storeId) async {
    final json = await ds.getCustomerRetention(storeId);
    return CustomerRetentionModel.fromJson(json);
  }

  @override
  Future<List<StaffPerformanceStatEntity>> getStaffPerformance(String? storeId) async {
    final list = await ds.getStaffPerformance(storeId);
    return list.map((e) => StaffPerformanceStatModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<BasketAbandonmentEntity> getBasketAbandonment(String? storeId) async {
    final json = await ds.getBasketAbandonment(storeId);
    return BasketAbandonmentModel.fromJson(json);
  }

  @override
  Future<CustomerLTVEntity> getCustomerLTV(String? storeId) async {
    final json = await ds.getCustomerLTV(storeId);
    return CustomerLTVModel.fromJson(json);
  }

  @override
  Future<List<MonthlyRevenueStatEntity>> getMonthlyRevenue(String? storeId, int year) async {
    final list = await ds.getMonthlyRevenue(storeId, year);
    return list.map((e) => MonthlyRevenueStatModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
