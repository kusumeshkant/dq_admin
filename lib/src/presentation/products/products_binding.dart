import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_store_products_usecase.dart';
import '../../domain/usecase/create_product_usecase.dart';
import '../../domain/usecase/update_product_usecase.dart';
import '../../domain/usecase/delete_product_usecase.dart';
import 'products_controller.dart';

class ProductsBinding extends Bindings {
  final StoreEntity store;
  ProductsBinding({required this.store});

  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => ProductsController(
          store: store,
          getStoreProductsUseCase: GetStoreProductsUseCase(repo),
          createProductUseCase: CreateProductUseCase(repo),
          updateProductUseCase: UpdateProductUseCase(repo),
          deleteProductUseCase: DeleteProductUseCase(repo),
        ));
  }
}
