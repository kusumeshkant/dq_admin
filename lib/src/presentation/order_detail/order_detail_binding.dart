import 'package:get/get.dart';
import '../../domain/entity/order_entity.dart';

class OrderDetailBinding extends Bindings {
  final OrderEntity order;
  OrderDetailBinding({required this.order});

  @override
  void dependencies() {
    // Read-only detail — no controller needed; order is passed directly
  }
}
