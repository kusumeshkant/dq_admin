import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class GetStoreProductsUseCase {
  final ProductRepository repo;
  GetStoreProductsUseCase(this.repo);

  Future<List<ProductEntity>> execute(String storeId) => repo.getStoreProducts(storeId);
}
