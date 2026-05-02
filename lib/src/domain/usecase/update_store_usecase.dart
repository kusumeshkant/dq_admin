import '../entity/store_entity.dart';
import '../repo/store_repository.dart';

class UpdateStoreUseCase {
  final StoreRepository repo;
  UpdateStoreUseCase(this.repo);

  Future<StoreEntity> execute({required String id, String? name, String? address, double? lat, double? lon, String? storeCode}) =>
      repo.updateStore(id: id, name: name, address: address, lat: lat, lon: lon, storeCode: storeCode);
}
