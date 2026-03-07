import '../entity/product_entity.dart';
import '../repo/admin_repository.dart';

class GetStoreProductsUseCase {
  final AdminRepository repo;
  GetStoreProductsUseCase(this.repo);

  Future<List<ProductEntity>> execute(String storeId) => repo.getStoreProducts(storeId);
}
