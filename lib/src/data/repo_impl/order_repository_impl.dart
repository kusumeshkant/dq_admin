import '../../domain/entity/order_entity.dart';
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
}
