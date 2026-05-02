import 'package:get/get.dart';
import '../../data/datasources/remote/permission_remote_ds.dart';
import 'permissions_controller.dart';

class PermissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PermissionsController(PermissionRemoteDs()));
  }
}
