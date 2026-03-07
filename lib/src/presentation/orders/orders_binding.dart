import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/usecase/get_all_orders_usecase.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import 'orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => OrdersController(
          getAllOrdersUseCase: GetAllOrdersUseCase(repo),
          getAllStoresUseCase: GetAllStoresUseCase(repo),
        ));
  }
}
