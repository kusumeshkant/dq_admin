import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repo;
  UpdateProductUseCase(this.repo);

  Future<ProductEntity> execute({
    required String id, String? sku, String? name, String? description,
    String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    double? price, double? mrp, int? stock, int? reorderLevel, bool? isAvailable,
  }) => repo.updateProduct(
    id: id, sku: sku, name: name, description: description,
    brand: brand, gender: gender, color: color,
    categoryMain: categoryMain, categorySub: categorySub,
    sizeGarment: sizeGarment, sizeActual: sizeActual,
    price: price, mrp: mrp, stock: stock, reorderLevel: reorderLevel, isAvailable: isAvailable,
  );
}
