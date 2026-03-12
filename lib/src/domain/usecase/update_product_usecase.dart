import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repo;
  UpdateProductUseCase(this.repo);

  Future<ProductEntity> execute({required String id, String? sku, String? name, String? description, double? price, int? stock}) =>
      repo.updateProduct(id: id, sku: sku, name: name, description: description, price: price, stock: stock);
}
