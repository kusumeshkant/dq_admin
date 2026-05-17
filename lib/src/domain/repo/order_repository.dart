import '../../core/pagination/page_result.dart';
import '../entity/order_entity.dart';
import '../entity/order_page_result.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getAllOrders({String? storeId, String? status});
  Future<OrdersPageResult> getOrdersPage({String? storeId, required PageParams params});
}
