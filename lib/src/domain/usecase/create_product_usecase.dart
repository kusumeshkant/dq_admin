import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repo;
  CreateProductUseCase(this.repo);

  Future<ProductEntity> execute({required String storeId, required String barcode, String? sku, required String name, String? description, required double price, required int stock}) =>
      repo.createProduct(storeId: storeId, barcode: barcode, sku: sku, name: name, description: description, price: price, stock: stock);
}
