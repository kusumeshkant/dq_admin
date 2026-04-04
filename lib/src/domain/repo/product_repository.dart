import '../entity/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getStoreProducts(String storeId);
  Future<ProductEntity> createProduct({
    required String storeId, required String barcode, String? sku, required String name,
    String? description, String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    required double price, double? mrp, required int stock, int? reorderLevel,
  });
  Future<ProductEntity> updateProduct({
    required String id, String? sku, String? name, String? description,
    String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    double? price, double? mrp, int? stock, int? reorderLevel, bool? isAvailable,
  });
  Future<bool> deleteProduct(String id);
  Future<BulkUpsertResultEntity> bulkUpsertProducts({required String storeId, required List<BulkProductInput> products, String? fileName, int? totalRows, int? totalColumns});
  Future<List<UploadLogEntity>> getUploadLogs(String storeId);
}
