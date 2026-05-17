import 'package:get/get.dart';
import '../../data/datasources/remote/product_remote_ds.dart';
import '../../data/repo_impl/product_repository_impl.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/create_product_usecase.dart';
import '../../domain/usecase/update_product_usecase.dart';
import '../../domain/usecase/delete_product_usecase.dart';
import '../../domain/usecase/bulk_upsert_products_usecase.dart';
import '../../domain/usecase/get_upload_logs_usecase.dart';
import 'products_controller.dart';

class ProductsBinding extends Bindings {
  final StoreEntity store;
  ProductsBinding({required this.store});

  @override
  void dependencies() {
    final repo = ProductRepositoryImpl(ProductRemoteDs());
    Get.lazyPut(() => ProductsController(
          store: store,
          repo: repo,
          createProductUseCase: CreateProductUseCase(repo),
          updateProductUseCase: UpdateProductUseCase(repo),
          deleteProductUseCase: DeleteProductUseCase(repo),
          bulkUpsertProductsUseCase: BulkUpsertProductsUseCase(repo),
          getUploadLogsUseCase: GetUploadLogsUseCase(repo),
        ));
  }
}
