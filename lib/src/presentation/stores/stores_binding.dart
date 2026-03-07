import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/create_store_usecase.dart';
import '../../domain/usecase/update_store_usecase.dart';
import '../../domain/usecase/delete_store_usecase.dart';
import 'stores_controller.dart';

class StoresBinding extends Bindings {
  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => StoresController(
          getAllStoresUseCase: GetAllStoresUseCase(repo),
          createStoreUseCase: CreateStoreUseCase(repo),
          updateStoreUseCase: UpdateStoreUseCase(repo),
          deleteStoreUseCase: DeleteStoreUseCase(repo),
        ));
  }
}
