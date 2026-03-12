import '../entity/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getAllOrders({String? storeId, String? status});
}
