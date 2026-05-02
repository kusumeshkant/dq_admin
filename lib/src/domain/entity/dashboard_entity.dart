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

class CustomerRetentionEntity {
  final int totalCustomers;
  final int returningCustomers;
  final double retentionRate;
  final double? avgRepeatIntervalDays;
  final int newCustomersThisWeek;
  final int newCustomersLastWeek;

  const CustomerRetentionEntity({
    required this.totalCustomers,
    required this.returningCustomers,
    required this.retentionRate,
    required this.avgRepeatIntervalDays,
    required this.newCustomersThisWeek,
    required this.newCustomersLastWeek,
  });
}

class StaffPerformanceStatEntity {
  final String staffId;
  final String staffName;
  final int ordersCompleted;
  final int ordersCancelled;
  final int flagsRaised;
  final int totalOrdersHandled;
  final double? avgFulfillmentTime;
  final double cancellationRate;

  const StaffPerformanceStatEntity({
    required this.staffId,
    required this.staffName,
    required this.ordersCompleted,
    required this.ordersCancelled,
    required this.flagsRaised,
    required this.totalOrdersHandled,
    required this.avgFulfillmentTime,
    required this.cancellationRate,
  });
}

class BasketAbandonmentEntity {
  final int totalChecks;
  final int convertedChecks;
  final int abandonedChecks;
  final double abandonmentRate;
  final double conversionRate;
  final double thisWeekAbandonmentRate;
  final double lastWeekAbandonmentRate;

  const BasketAbandonmentEntity({
    required this.totalChecks,
    required this.convertedChecks,
    required this.abandonedChecks,
    required this.abandonmentRate,
    required this.conversionRate,
    required this.thisWeekAbandonmentRate,
    required this.lastWeekAbandonmentRate,
  });
}

class TopCustomerStatEntity {
  final String userId;
  final String name;
  final String? phone;
  final double totalSpend;
  final int totalOrders;

  const TopCustomerStatEntity({
    required this.userId,
    required this.name,
    required this.phone,
    required this.totalSpend,
    required this.totalOrders,
  });
}

class CustomerLTVEntity {
  final int totalCustomers;
  final double avgRevenuePerCustomer;
  final double avgOrdersPerCustomer;
  final double? avgDaysActive;
  final double? projectedMonthlyLTV;
  final List<TopCustomerStatEntity> topCustomers;

  const CustomerLTVEntity({
    required this.totalCustomers,
    required this.avgRevenuePerCustomer,
    required this.avgOrdersPerCustomer,
    required this.avgDaysActive,
    required this.projectedMonthlyLTV,
    required this.topCustomers,
  });
}

class MonthlyRevenueStatEntity {
  final int month;
  final int year;
  final double revenue;
  final int orders;

  const MonthlyRevenueStatEntity({
    required this.month,
    required this.year,
    required this.revenue,
    required this.orders,
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
