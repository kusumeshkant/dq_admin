import '../../core/pagination/page_result.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/entity/order_page_result.dart';
import '../../domain/repo/order_repository.dart';
import '../datasources/remote/order_remote_ds.dart';
import '../model/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDs ds;
  OrderRepositoryImpl(this.ds);

  @override
  Future<List<OrderEntity>> getAllOrders({String? storeId, String? status}) async {
    final list = await ds.getAllOrders(storeId: storeId, status: status);
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<OrdersPageResult> getOrdersPage({String? storeId, required PageParams params}) async {
    final data = await ds.fetchOrdersPage(params, storeId: storeId);
    final meta = data['meta'] as Map<String, dynamic>;
    final page = PageResult<OrderEntity>(
      items: (data['items'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasNext: meta['hasNext'] as bool,
      nextCursor: meta['nextCursor'] as String?,
      totalCount: meta['totalCount'] as int?,
    );
    return OrdersPageResult(
      page: page,
      activeCount: data['activeCount'] as int? ?? 0,
      completedCount: data['completedCount'] as int? ?? 0,
      cancelledCount: data['cancelledCount'] as int? ?? 0,
    );
  }
}
