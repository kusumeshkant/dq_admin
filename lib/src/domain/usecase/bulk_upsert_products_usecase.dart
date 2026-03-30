import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class BulkUpsertProductsUseCase {
  final ProductRepository repo;
  BulkUpsertProductsUseCase(this.repo);

  Future<BulkUpsertResultEntity> execute({required String storeId, required List<BulkProductInput> products}) =>
      repo.bulkUpsertProducts(storeId: storeId, products: products);
}
