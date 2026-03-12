import '../../domain/entity/product_entity.dart';
import '../../domain/repo/product_repository.dart';
import '../datasources/remote/product_remote_ds.dart';
import '../model/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDs ds;
  ProductRepositoryImpl(this.ds);

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
}
