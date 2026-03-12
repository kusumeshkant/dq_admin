import '../entity/store_entity.dart';
import '../repo/store_repository.dart';

class GetAllStoresUseCase {
  final StoreRepository repo;
  GetAllStoresUseCase(this.repo);

  Future<List<StoreEntity>> execute() => repo.getAllStores();
}
