import '../entity/product_entity.dart';
import '../repo/product_repository.dart';

class BulkUpsertProductsUseCase {
  final ProductRepository repo;
  BulkUpsertProductsUseCase(this.repo);

  Future<BulkUpsertResultEntity> execute({required String storeId, required List<BulkProductInput> products, String? fileName, int? totalRows, int? totalColumns}) =>
      repo.bulkUpsertProducts(storeId: storeId, products: products, fileName: fileName, totalRows: totalRows, totalColumns: totalColumns);
}
