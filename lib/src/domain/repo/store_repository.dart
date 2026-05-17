import '../../core/pagination/page_result.dart';
import '../entity/store_entity.dart';

abstract class StoreRepository {
  Future<List<StoreEntity>> getAllStores();
  Future<PageResult<StoreEntity>> getStoresPage({required PageParams params, String? storeId});
  Future<StoreEntity> createStore({required String name, required String address, required double lat, required double lon, String? storeCode});
  Future<StoreEntity> updateStore({required String id, String? name, String? address, double? lat, double? lon, String? storeCode});
  Future<bool> deleteStore(String id);
}
