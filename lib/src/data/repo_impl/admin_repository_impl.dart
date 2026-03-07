import '../../domain/entity/store_entity.dart';
import '../../domain/entity/product_entity.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/admin_repository.dart';
import '../datasources/remote/admin_remote_ds.dart';
import '../model/store_model.dart';
import '../model/product_model.dart';
import '../model/order_model.dart';
import '../model/dashboard_model.dart';
import '../model/user_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDs ds;
  AdminRepositoryImpl(this.ds);

  @override
  Future<DashboardStatsEntity> getDashboardStats() async {
    final json = await ds.getDashboardStats();
    return DashboardStatsModel.fromJson(json);
  }

  @override
  Future<StoreStatsEntity> getStoreStats(String storeId) async {
    final json = await ds.getStoreStats(storeId);
    return StoreStatsModel.fromJson(json);
  }

  @override
  Future<List<StoreEntity>> getAllStores() async {
    final list = await ds.getAllStores();
    return list.map((e) => StoreModel.fromJson(e)).toList();
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

  @override
  Future<List<ProductEntity>> getStoreProducts(String storeId) async {
    final list = await ds.getStoreProducts(storeId);
    return list.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<ProductEntity> createProduct({required String storeId, required String barcode, String? sku, required String name, String? description, required double price, required int stock}) async {
    final json = await ds.createProduct(storeId: storeId, barcode: barcode, sku: sku, name: name, description: description, price: price, stock: stock);
    return ProductModel.fromJson(json);
  }

  @override
  Future<ProductEntity> updateProduct({required String id, String? sku, String? name, String? description, double? price, int? stock}) async {
    final json = await ds.updateProduct(id: id, sku: sku, name: name, description: description, price: price, stock: stock);
    return ProductModel.fromJson(json);
  }

  @override
  Future<bool> deleteProduct(String id) => ds.deleteProduct(id);

  @override
  Future<List<OrderEntity>> getAllOrders({String? storeId, String? status}) async {
    final list = await ds.getAllOrders(storeId: storeId, status: status);
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<List<UserEntity>> getAllStaff() async {
    final list = await ds.getAllStaff();
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    final json = await ds.getUserByEmail(email);
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  @override
  Future<UserEntity> updateUserRole({required String userId, required String role, String? storeId}) async {
    final json = await ds.updateUserRole(userId: userId, role: role, storeId: storeId);
    return UserModel.fromJson(json);
  }
}
