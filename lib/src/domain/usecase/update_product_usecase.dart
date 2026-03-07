import '../entity/product_entity.dart';
import '../repo/admin_repository.dart';

class UpdateProductUseCase {
  final AdminRepository repo;
  UpdateProductUseCase(this.repo);

  Future<ProductEntity> execute({required String id, String? name, String? description, double? price, int? stock}) =>
      repo.updateProduct(id: id, name: name, description: description, price: price, stock: stock);
}
