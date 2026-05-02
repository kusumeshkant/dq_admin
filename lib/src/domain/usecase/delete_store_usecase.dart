import '../repo/store_repository.dart';

class DeleteStoreUseCase {
  final StoreRepository repo;
  DeleteStoreUseCase(this.repo);

  Future<bool> execute(String id) => repo.deleteStore(id);
}
