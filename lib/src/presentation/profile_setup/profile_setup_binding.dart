import 'package:get/get.dart';
import 'profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  final String? _email;
  ProfileSetupBinding({String? email}) : _email = email;

  @override
  void dependencies() {
    final email = _email ?? (Get.arguments is String ? Get.arguments as String : '');
    Get.lazyPut(() => ProfileSetupController(email: email));
  }
}
