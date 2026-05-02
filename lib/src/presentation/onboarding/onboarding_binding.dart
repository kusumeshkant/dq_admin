import 'package:get/get.dart';
import '../../data/datasources/remote/product_remote_ds.dart';
import '../../data/datasources/remote/staff_remote_ds.dart';
import '../../data/datasources/remote/store_remote_ds.dart';
import '../../data/repo_impl/product_repository_impl.dart';
import '../../data/repo_impl/staff_repository_impl.dart';
import '../../data/repo_impl/store_repository_impl.dart';
import '../../domain/usecase/bulk_upsert_products_usecase.dart';
import '../../domain/usecase/create_store_usecase.dart';
import '../../domain/usecase/get_upload_logs_usecase.dart';
import '../../domain/usecase/update_user_role_usecase.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    final storeRepo = StoreRepositoryImpl(StoreRemoteDs());
    final staffRepo = StaffRepositoryImpl(StaffRemoteDs());
    final productRepo = ProductRepositoryImpl(ProductRemoteDs());

    Get.lazyPut(() => CreateStoreUseCase(storeRepo));
    Get.lazyPut(() => UpdateUserRoleUseCase(staffRepo));
    Get.lazyPut(() => BulkUpsertProductsUseCase(productRepo));
    Get.lazyPut(() => GetUploadLogsUseCase(productRepo));
  }
}
