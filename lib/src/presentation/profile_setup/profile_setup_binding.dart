import 'package:get/get.dart';
import 'profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  final String email;
  ProfileSetupBinding({required this.email});

  @override
  void dependencies() {
    Get.lazyPut(() => ProfileSetupController(email: email));
  }
}
