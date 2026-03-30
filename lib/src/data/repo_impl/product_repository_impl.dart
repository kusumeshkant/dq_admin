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

  @override
  Future<BulkUpsertResultEntity> bulkUpsertProducts({required String storeId, required List<BulkProductInput> products}) async {
    final productMaps = products.map((p) {
      final map = <String, dynamic>{
        'barcode': p.barcode,
        'name': p.name,
        'price': p.price,
        'stock': p.stock,
      };
      if (p.sku != null) map['sku'] = p.sku;
      if (p.mrp != null) map['mrp'] = p.mrp;
      if (p.brand != null) map['brand'] = p.brand;
      if (p.gender != null) map['gender'] = p.gender;
      if (p.color != null) map['color'] = p.color;
      if (p.categoryMain != null) map['categoryMain'] = p.categoryMain;
      if (p.categorySub != null) map['categorySub'] = p.categorySub;
      if (p.sizeGarment != null) map['sizeGarment'] = p.sizeGarment;
      if (p.sizeActual != null) map['sizeActual'] = p.sizeActual;
      return map;
    }).toList();

    final json = await ds.bulkUpsertProducts(storeId: storeId, products: productMaps);
    final errors = (json['errors'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => BulkProductErrorEntity(barcode: e['barcode'] as String, message: e['message'] as String))
        .toList();
    return BulkUpsertResultEntity(
      created: json['created'] as int,
      updated: json['updated'] as int,
      errors: errors,
    );
  }
}
