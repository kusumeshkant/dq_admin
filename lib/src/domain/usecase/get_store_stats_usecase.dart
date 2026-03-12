import '../entity/dashboard_entity.dart';
import '../repo/dashboard_repository.dart';

class GetStoreStatsUseCase {
  final DashboardRepository repo;
  GetStoreStatsUseCase(this.repo);

  Future<StoreStatsEntity> execute(String storeId) => repo.getStoreStats(storeId);
}
