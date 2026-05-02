import '../../core/pagination/page_result.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/repo/store_repository.dart';
import '../datasources/remote/store_remote_ds.dart';
import '../model/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDs ds;
  StoreRepositoryImpl(this.ds);

  @override
  Future<List<StoreEntity>> getAllStores() async {
    final list = await ds.getAllStores();
    return list.map((e) => StoreModel.fromJson(e)).toList();
  }

  @override
  Future<PageResult<StoreEntity>> getStoresPage({required PageParams params, String? storeId}) async {
    final data = await ds.fetchStoresPage(params, storeId: storeId);
    final meta = data['meta'] as Map<String, dynamic>;
    return PageResult<StoreEntity>(
      items: (data['items'] as List).map((e) => StoreModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasNext: meta['hasNext'] as bool,
      nextCursor: meta['nextCursor'] as String?,
      totalCount: meta['totalCount'] as int?,
    );
  }

  @override
  Future<StoreEntity> createStore({required String name, required String address, required double lat, required double lon, String? storeCode}) async {
    final json = await ds.createStore(name: name, address: address, lat: lat, lon: lon, storeCode: storeCode);
    return StoreModel.fromJson(json);
  }

  @override
  Future<StoreEntity> updateStore({required String id, String? name, String? address, double? lat, double? lon, String? storeCode}) async {
    final json = await ds.updateStore(id: id, name: name, address: address, lat: lat, lon: lon, storeCode: storeCode);
    return StoreModel.fromJson(json);
  }

  @override
  Future<bool> deleteStore(String id) => ds.deleteStore(id);
}
