import 'package:get/get.dart';
import 'staff_management_controller.dart';

class StaffManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffManagementController());
  }
}
