import 'package:get/get.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/usecase/get_all_orders_usecase.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';

class OrdersController extends GetxController {
  final GetAllOrdersUseCase getAllOrdersUseCase;
  final GetAllStoresUseCase getAllStoresUseCase;

  OrdersController({required this.getAllOrdersUseCase, required this.getAllStoresUseCase});

  final isLoading = false.obs;
  final orders = <OrderEntity>[].obs;
  final stores = <StoreEntity>[].obs;

  final selectedStoreId = Rx<String?>(null);
  final selectedStatus = Rx<String?>(null);

  final statusOptions = ['All', 'pending', 'preparing', 'ready', 'completed', 'cancelled'];

  @override
  void onInit() {
    super.onInit();
    loadStores();
    loadOrders();
  }

  Future<void> loadStores() async {
    try {
      stores.value = await getAllStoresUseCase.execute();
    } catch (_) {}
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      orders.value = await getAllOrdersUseCase.execute(
        storeId: selectedStoreId.value,
        status: selectedStatus.value,
      );
    } catch (e) {
      orders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStore(String? storeId) {
    selectedStoreId.value = storeId;
    loadOrders();
  }

  void filterByStatus(String? status) {
    selectedStatus.value = (status == null || status == 'All') ? null : status;
    loadOrders();
  }
}
