import '../../domain/entity/product_entity.dart';
import '../../domain/repo/product_repository.dart';
import '../../core/pagination/page_result.dart';
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
  Future<PageResult<ProductEntity>> getStoreProductsPage(
      String storeId, PageParams params) async {
    final page = await ds.fetchProductsPage(storeId, params);
    return PageResult(
      items:      page.items.map(ProductModel.fromJson).toList(),
      hasNext:    page.hasNext,
      nextCursor: page.nextCursor,
      totalCount: page.totalCount,
    );
  }

  @override
  Future<ProductEntity> createProduct({
    required String storeId, required String barcode, String? sku, required String name,
    String? description, String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    required double price, double? mrp, required int stock, int? reorderLevel,
  }) async {
    final json = await ds.createProduct(
      storeId: storeId, barcode: barcode, sku: sku, name: name,
      description: description, brand: brand, gender: gender, color: color,
      categoryMain: categoryMain, categorySub: categorySub,
      sizeGarment: sizeGarment, sizeActual: sizeActual,
      price: price, mrp: mrp, stock: stock, reorderLevel: reorderLevel,
    );
    return ProductModel.fromJson(json);
  }

  @override
  Future<ProductEntity> updateProduct({
    required String id, String? sku, String? name, String? description,
    String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    double? price, double? mrp, int? stock, int? reorderLevel, bool? isAvailable,
  }) async {
    final json = await ds.updateProduct(
      id: id, sku: sku, name: name, description: description,
      brand: brand, gender: gender, color: color,
      categoryMain: categoryMain, categorySub: categorySub,
      sizeGarment: sizeGarment, sizeActual: sizeActual,
      price: price, mrp: mrp, stock: stock, reorderLevel: reorderLevel, isAvailable: isAvailable,
    );
    return ProductModel.fromJson(json);
  }

  @override
  Future<bool> deleteProduct(String id) => ds.deleteProduct(id);

  @override
  Future<BulkUpsertResultEntity> bulkUpsertProducts({required String storeId, required List<BulkProductInput> products, String? fileName, int? totalRows, int? totalColumns}) async {
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

    final json = await ds.bulkUpsertProducts(storeId: storeId, products: productMaps, fileName: fileName, totalRows: totalRows, totalColumns: totalColumns);
    final errors = (json['errors'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => BulkProductErrorEntity(barcode: e['barcode'] as String, message: e['message'] as String))
        .toList();
    return BulkUpsertResultEntity(
      created: json['created'] as int,
      updated: json['updated'] as int,
      skipped: json['skipped'] as int,
      errors: errors,
    );
  }

  @override
  Future<List<UploadLogEntity>> getUploadLogs(String storeId) async {
    final list = await ds.getUploadLogs(storeId);
    return list.map((l) {
      final errors = (l['errors'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map((e) => BulkProductErrorEntity(barcode: e['barcode'] as String, message: e['message'] as String))
          .toList();
      return UploadLogEntity(
        id: l['id'] as String,
        storeId: l['storeId'] as String,
        storeName: l['storeName'] as String?,
        uploadedByName: l['uploadedByName'] as String? ?? 'Unknown',
        fileName: l['fileName'] as String,
        uploadedAt: DateTime.parse(l['uploadedAt'] as String),
        totalRows: l['totalRows'] as int,
        totalColumns: l['totalColumns'] as int,
        created: l['created'] as int,
        updated: l['updated'] as int,
        skipped: l['skipped'] as int,
        errorCount: l['errorCount'] as int,
        errors: errors,
      );
    }).toList();
  }
}
