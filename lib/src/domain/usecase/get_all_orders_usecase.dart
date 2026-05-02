import '../entity/order_entity.dart';
import '../repo/order_repository.dart';

class GetAllOrdersUseCase {
  final OrderRepository repo;
  GetAllOrdersUseCase(this.repo);

  Future<List<OrderEntity>> execute({String? storeId, String? status}) =>
      repo.getAllOrders(storeId: storeId, status: status);
}
