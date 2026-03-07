import '../entity/order_entity.dart';
import '../repo/admin_repository.dart';

class GetAllOrdersUseCase {
  final AdminRepository repo;
  GetAllOrdersUseCase(this.repo);

  Future<List<OrderEntity>> execute({String? storeId, String? status}) =>
      repo.getAllOrders(storeId: storeId, status: status);
}
