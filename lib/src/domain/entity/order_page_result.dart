import '../../core/pagination/page_result.dart';
import 'order_entity.dart';

class OrdersPageResult {
  final PageResult<OrderEntity> page;
  final int activeCount;
  final int completedCount;
  final int cancelledCount;

  const OrdersPageResult({
    required this.page,
    required this.activeCount,
    required this.completedCount,
    required this.cancelledCount,
  });
}
