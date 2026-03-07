import '../repo/admin_repository.dart';

class DeleteStoreUseCase {
  final AdminRepository repo;
  DeleteStoreUseCase(this.repo);

  Future<bool> execute(String id) => repo.deleteStore(id);
}
