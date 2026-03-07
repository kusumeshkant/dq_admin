import '../repo/admin_repository.dart';

class DeleteProductUseCase {
  final AdminRepository repo;
  DeleteProductUseCase(this.repo);

  Future<bool> execute(String id) => repo.deleteProduct(id);
}
