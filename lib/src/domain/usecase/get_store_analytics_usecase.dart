import '../entity/dashboard_entity.dart';
import '../repo/dashboard_repository.dart';

class GetStoreAnalyticsUseCase {
  final DashboardRepository repo;
  GetStoreAnalyticsUseCase(this.repo);

  Future<StoreAnalyticsEntity> execute(String? storeId) => repo.getStoreAnalytics(storeId);
}
