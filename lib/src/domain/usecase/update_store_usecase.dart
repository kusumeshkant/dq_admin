import '../entity/store_entity.dart';
import '../repo/admin_repository.dart';

class UpdateStoreUseCase {
  final AdminRepository repo;
  UpdateStoreUseCase(this.repo);

  Future<StoreEntity> execute({required String id, String? name, String? address, double? lat, double? lon, String? storeCode}) =>
      repo.updateStore(id: id, name: name, address: address, lat: lat, lon: lon, storeCode: storeCode);
}
