import 'package:get/get.dart';
import '../../data/datasources/remote/order_remote_ds.dart';
import '../../data/datasources/remote/store_remote_ds.dart';
import '../../data/repo_impl/order_repository_impl.dart';
import '../../data/repo_impl/store_repository_impl.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import 'orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    final orderRepo = OrderRepositoryImpl(OrderRemoteDs());
    final storeRepo = StoreRepositoryImpl(StoreRemoteDs());
    Get.lazyPut(() => OrdersController(
          repo: orderRepo,
          getAllStoresUseCase: GetAllStoresUseCase(storeRepo),
        ));
  }
}
