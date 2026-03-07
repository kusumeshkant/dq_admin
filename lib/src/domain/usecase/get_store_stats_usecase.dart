import '../entity/dashboard_entity.dart';
import '../repo/admin_repository.dart';

class GetStoreStatsUseCase {
  final AdminRepository repo;
  GetStoreStatsUseCase(this.repo);

  Future<StoreStatsEntity> execute(String storeId) => repo.getStoreStats(storeId);
}
