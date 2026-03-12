import '../repo/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repo;
  DeleteProductUseCase(this.repo);

  Future<bool> execute(String id) => repo.deleteProduct(id);
}
