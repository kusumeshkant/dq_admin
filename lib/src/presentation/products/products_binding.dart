import 'package:get/get.dart';
import '../../data/datasources/remote/product_remote_ds.dart';
import '../../data/repo_impl/product_repository_impl.dart';
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
    final productRepo = ProductRepositoryImpl(ProductRemoteDs());
    Get.lazyPut(() => ProductsController(
          store: store,
          getStoreProductsUseCase: GetStoreProductsUseCase(productRepo),
          createProductUseCase: CreateProductUseCase(productRepo),
          updateProductUseCase: UpdateProductUseCase(productRepo),
          deleteProductUseCase: DeleteProductUseCase(productRepo),
        ));
  }
}
