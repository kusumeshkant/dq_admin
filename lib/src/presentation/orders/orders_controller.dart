import 'package:get/get.dart';
import '../../core/pagination/page_result.dart';
import '../../core/pagination/paginated_controller.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/entity/store_entity.dart';
import '../../domain/repo/order_repository.dart';
import '../../domain/usecase/get_all_stores_usecase.dart';

class OrdersController extends PaginatedController<OrderEntity> {
  final OrderRepository _repo;
  final GetAllStoresUseCase getAllStoresUseCase;

  OrdersController({required OrderRepository repo, required this.getAllStoresUseCase})
      : _repo = repo;

  final stores = <StoreEntity>[].obs;

  // Selected values for the UI dropdowns (mirrors filters map)
  final selectedStoreId = Rx<String?>(null);
  final selectedStatus  = Rx<String?>(null);

  final statusOptions = ['All', 'pending', 'preparing', 'ready', 'completed', 'cancelled'];

  // Counts from the backend — updated on every initial load
  int get activeCount    => _activeCountRx.value;
  int get completedCount => _completedCountRx.value;
  int get cancelledCount => _cancelledCountRx.value;

  final _activeCountRx    = 0.obs;
  final _completedCountRx = 0.obs;
  final _cancelledCountRx = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try { stores.value = await getAllStoresUseCase.execute(); } catch (_) {}
  }

  @override
  Future<PageResult<OrderEntity>> fetchPage(PageParams params) async {
    final storeId = params.filters['storeId'] as String?;
    final result  = await _repo.getOrdersPage(storeId: storeId, params: params);
    if (params.cursor == null) {
      _activeCountRx.value    = result.activeCount;
      _completedCountRx.value = result.completedCount;
      _cancelledCountRx.value = result.cancelledCount;
    }
    return result.page;
  }

  void filterByStore(String? storeId) {
    selectedStoreId.value = storeId;
    applyFilter('storeId', storeId);
  }

  void filterByStatus(String? status) {
    final resolved       = (status == null || status == 'All') ? null : status;
    selectedStatus.value = resolved;
    applyFilter('status', resolved);
  }
}
