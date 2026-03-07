import '../entity/store_entity.dart';
import '../entity/product_entity.dart';
import '../entity/order_entity.dart';
import '../entity/dashboard_entity.dart';
import '../entity/user_entity.dart';

abstract class AdminRepository {
  // Dashboard
  Future<DashboardStatsEntity> getDashboardStats();
  Future<StoreStatsEntity> getStoreStats(String storeId);

  // Stores
  Future<List<StoreEntity>> getAllStores();
  Future<StoreEntity> createStore({required String name, required String address, required double lat, required double lon, String? storeCode});
  Future<StoreEntity> updateStore({required String id, String? name, String? address, double? lat, double? lon, String? storeCode});
  Future<bool> deleteStore(String id);

  // Products
  Future<List<ProductEntity>> getStoreProducts(String storeId);
  Future<ProductEntity> createProduct({required String storeId, required String barcode, String? sku, required String name, String? description, required double price, required int stock});
  Future<ProductEntity> updateProduct({required String id, String? sku, String? name, String? description, double? price, int? stock});
  Future<bool> deleteProduct(String id);

  // Orders
  Future<List<OrderEntity>> getAllOrders({String? storeId, String? status});

  // Staff
  Future<List<UserEntity>> getAllStaff();
  Future<UserEntity?> getUserByEmail(String email);
  Future<UserEntity> updateUserRole({required String userId, required String role, String? storeId});
}
