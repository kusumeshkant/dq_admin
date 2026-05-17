import 'package:get/get.dart';
import '../../service_core/subscription/subscription_remote_ds.dart';
import 'plans_controller.dart';

class PlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PlansController(
      remoteDs: SubscriptionRemoteDs(),
    ));
  }
}
