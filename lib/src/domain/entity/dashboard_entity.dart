import 'store_entity.dart';
import 'order_entity.dart';

class StoreRevenueEntity {
  final StoreEntity? store;
  final double revenue;
  final int orderCount;

  const StoreRevenueEntity({
    this.store,
    required this.revenue,
    required this.orderCount,
  });
}

class DashboardStatsEntity {
  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int activeStores;
  final List<StoreRevenueEntity> topStores;
  final List<OrderEntity> recentOrders;

  const DashboardStatsEntity({
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.activeStores,
    required this.topStores,
    required this.recentOrders,
  });
}

class StoreStatsEntity {
  final StoreEntity? store;
  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final List<OrderEntity> recentOrders;

  const StoreStatsEntity({
    this.store,
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.recentOrders,
  });
}
