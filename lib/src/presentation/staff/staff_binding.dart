import 'package:get/get.dart';
import '../../data/datasources/remote/admin_remote_ds.dart';
import '../../data/repo_impl/admin_repository_impl.dart';
import '../../domain/usecase/get_all_staff_usecase.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';
import '../../domain/usecase/get_user_by_email_usecase.dart';
import '../../domain/usecase/update_user_role_usecase.dart';
import 'staff_controller.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    final ds = AdminRemoteDs();
    final repo = AdminRepositoryImpl(ds);
    Get.lazyPut(() => StaffController(
          getAllStaffUseCase: GetAllStaffUseCase(repo),
          getAllStoresUseCase: GetAllStoresUseCase(repo),
          getUserByEmailUseCase: GetUserByEmailUseCase(repo),
          updateUserRoleUseCase: UpdateUserRoleUseCase(repo),
        ));
  }
}
