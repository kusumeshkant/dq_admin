import 'package:get/get.dart';
import '../../data/datasources/remote/store_remote_ds.dart';
import '../../data/repo_impl/store_repository_impl.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/create_store_usecase.dart';
import '../../domain/usecase/update_store_usecase.dart';
import '../../domain/usecase/delete_store_usecase.dart';
import 'stores_controller.dart';

class StoresBinding extends Bindings {
  @override
  void dependencies() {
    final storeRepo = StoreRepositoryImpl(StoreRemoteDs());
    Get.lazyPut(() => StoresController(
          getAllStoresUseCase: GetAllStoresUseCase(storeRepo),
          createStoreUseCase: CreateStoreUseCase(storeRepo),
          updateStoreUseCase: UpdateStoreUseCase(storeRepo),
          deleteStoreUseCase: DeleteStoreUseCase(storeRepo),
        ));
  }
}
