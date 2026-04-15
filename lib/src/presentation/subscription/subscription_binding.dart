import 'package:get/get.dart';
import '../../service_core/subscription/subscription_manager.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    // SubscriptionManager is already registered permanently in main.dart.
    // This binding is a no-op but follows the project convention of every
    // page having a binding so Get.to() calls are consistent.
    if (!Get.isRegistered<SubscriptionManager>()) {
      Get.put(SubscriptionManager());
    }
  }
}
