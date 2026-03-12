import 'package:get/get.dart';
import '../../data/datasources/remote/staff_remote_ds.dart';
import '../../data/datasources/remote/store_remote_ds.dart';
import '../../data/repo_impl/staff_repository_impl.dart';
import '../../data/repo_impl/store_repository_impl.dart';
import '../../domain/usecase/get_all_staff_usecase.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/get_user_by_email_usecase.dart';
import '../../domain/usecase/update_user_role_usecase.dart';
import 'staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    final staffRepo = StaffRepositoryImpl(StaffRemoteDs());
    final storeRepo = StoreRepositoryImpl(StoreRemoteDs());
    Get.lazyPut(() => StaffController(
          getAllStaffUseCase: GetAllStaffUseCase(staffRepo),
          getAllStoresUseCase: GetAllStoresUseCase(storeRepo),
          getUserByEmailUseCase: GetUserByEmailUseCase(staffRepo),
          updateUserRoleUseCase: UpdateUserRoleUseCase(staffRepo),
        ));
  }
}
