import '../entity/store_entity.dart';
import '../repo/admin_repository.dart';

class CreateStoreUseCase {
  final AdminRepository repo;
  CreateStoreUseCase(this.repo);

  Future<StoreEntity> execute({required String name, required String address, required double lat, required double lon, String? storeCode}) =>
      repo.createStore(name: name, address: address, lat: lat, lon: lon, storeCode: storeCode);
}
