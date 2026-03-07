import '../entity/product_entity.dart';
import '../repo/admin_repository.dart';

class CreateProductUseCase {
  final AdminRepository repo;
  CreateProductUseCase(this.repo);

  Future<ProductEntity> execute({required String storeId, required String barcode, required String name, String? description, required double price, required int stock}) =>
      repo.createProduct(storeId: storeId, barcode: barcode, name: name, description: description, price: price, stock: stock);
}
