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

class ProductStatEntity {
  final String name;
  final String barcode;
  final int totalSold;
  final double revenue;

  const ProductStatEntity({
    required this.name,
    required this.barcode,
    required this.totalSold,
    required this.revenue,
  });
}

class DailyRevenueStatEntity {
  final String date;
  final double revenue;
  final int orders;

  const DailyRevenueStatEntity({
    required this.date,
    required this.revenue,
    required this.orders,
  });
}

class StoreAnalyticsEntity {
  final double totalRevenue;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double avgOrderValue;
  final double avgItemsPerOrder;
  final int totalUnitsSold;
  final double thisWeekRevenue;
  final double lastWeekRevenue;
  final int lowStockCount;
  final List<ProductStatEntity> topProducts;
  final List<DailyRevenueStatEntity> dailyRevenue;

  const StoreAnalyticsEntity({
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.avgOrderValue,
    required this.avgItemsPerOrder,
    required this.totalUnitsSold,
    required this.thisWeekRevenue,
    required this.lastWeekRevenue,
    required this.lowStockCount,
    required this.topProducts,
    required this.dailyRevenue,
  });

  double get completionRate =>
      totalOrders > 0 ? completedOrders / totalOrders * 100 : 0;

  double get cancellationRate =>
      totalOrders > 0 ? cancelledOrders / totalOrders * 100 : 0;

  /// +ve = growth, -ve = decline, null = no last week data
  double? get weekOverWeekPct {
    if (lastWeekRevenue <= 0) return null;
    return (thisWeekRevenue - lastWeekRevenue) / lastWeekRevenue * 100;
  }
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
