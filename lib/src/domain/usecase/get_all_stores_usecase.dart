import '../entity/store_entity.dart';
import '../repo/admin_repository.dart';

class GetAllStoresUseCase {
  final AdminRepository repo;
  GetAllStoresUseCase(this.repo);

  Future<List<StoreEntity>> execute() => repo.getAllStores();
}
