import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repo;
  CreateProductUseCase(this.repo);

  Future<ProductEntity> execute({
    required String storeId, required String barcode, String? sku, required String name,
    String? description, String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    required double price, double? mrp, required int stock, int? reorderLevel,
  }) => repo.createProduct(
    storeId: storeId, barcode: barcode, sku: sku, name: name,
    description: description, brand: brand, gender: gender, color: color,
    categoryMain: categoryMain, categorySub: categorySub,
    sizeGarment: sizeGarment, sizeActual: sizeActual,
    price: price, mrp: mrp, stock: stock, reorderLevel: reorderLevel,
  );
}
