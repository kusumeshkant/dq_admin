import '../../domain/entity/dashboard_entity.dart';
import 'store_model.dart';
import 'order_model.dart';

class StoreRevenueModel extends StoreRevenueEntity {
  const StoreRevenueModel({
    super.store,
    required super.revenue,
    required super.orderCount,
  });

  factory StoreRevenueModel.fromJson(Map<String, dynamic> json) => StoreRevenueModel(
        store: json['store'] != null
            ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
            : null,
        revenue: (json['revenue'] as num).toDouble(),
        orderCount: json['orderCount'] as int,
      );
}

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalRevenue,
    required super.totalOrders,
    required super.pendingOrders,
    required super.completedOrders,
    required super.activeStores,
    required super.topStores,
    required super.recentOrders,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => DashboardStatsModel(
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        totalOrders: json['totalOrders'] as int,
        pendingOrders: json['pendingOrders'] as int,
        completedOrders: json['completedOrders'] as int,
        activeStores: json['activeStores'] as int,
        topStores: (json['topStores'] as List<dynamic>)
            .map((e) => StoreRevenueModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentOrders: (json['recentOrders'] as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ProductStatModel extends ProductStatEntity {
  const ProductStatModel({
    required super.name,
    required super.barcode,
    required super.totalSold,
    required super.revenue,
  });

  factory ProductStatModel.fromJson(Map<String, dynamic> json) => ProductStatModel(
        name: json['name'] as String,
        barcode: json['barcode'] as String,
        totalSold: json['totalSold'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class DailyRevenueStatModel extends DailyRevenueStatEntity {
  const DailyRevenueStatModel({
    required super.date,
    required super.revenue,
    required super.orders,
  });

  factory DailyRevenueStatModel.fromJson(Map<String, dynamic> json) => DailyRevenueStatModel(
        date: json['date'] as String,
        revenue: (json['revenue'] as num).toDouble(),
        orders: json['orders'] as int,
      );
}

class StoreAnalyticsModel extends StoreAnalyticsEntity {
  const StoreAnalyticsModel({
    required super.totalRevenue,
    required super.totalOrders,
    required super.completedOrders,
    required super.cancelledOrders,
    required super.avgOrderValue,
    required super.avgItemsPerOrder,
    required super.totalUnitsSold,
    required super.thisWeekRevenue,
    required super.lastWeekRevenue,
    required super.lowStockCount,
    required super.topProducts,
    required super.dailyRevenue,
  });

  factory StoreAnalyticsModel.fromJson(Map<String, dynamic> json) => StoreAnalyticsModel(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
        completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
        cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
        avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0.0,
        avgItemsPerOrder: (json['avgItemsPerOrder'] as num?)?.toDouble() ?? 0.0,
        totalUnitsSold: (json['totalUnitsSold'] as num?)?.toInt() ?? 0,
        thisWeekRevenue: (json['thisWeekRevenue'] as num?)?.toDouble() ?? 0.0,
        lastWeekRevenue: (json['lastWeekRevenue'] as num?)?.toDouble() ?? 0.0,
        lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
        topProducts: (json['topProducts'] as List<dynamic>? ?? [])
            .map((e) => ProductStatModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        dailyRevenue: (json['dailyRevenue'] as List<dynamic>? ?? [])
            .map((e) => DailyRevenueStatModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class StoreStatsModel extends StoreStatsEntity {
  const StoreStatsModel({
    super.store,
    required super.totalRevenue,
    required super.totalOrders,
    required super.pendingOrders,
    required super.completedOrders,
    required super.recentOrders,
  });

  factory StoreStatsModel.fromJson(Map<String, dynamic> json) => StoreStatsModel(
        store: json['store'] != null
            ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
            : null,
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        totalOrders: json['totalOrders'] as int,
        pendingOrders: json['pendingOrders'] as int,
        completedOrders: json['completedOrders'] as int,
        recentOrders: (json['recentOrders'] as List<dynamic>)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CustomerRetentionModel extends CustomerRetentionEntity {
  const CustomerRetentionModel({
    required super.totalCustomers,
    required super.returningCustomers,
    required super.retentionRate,
    required super.avgRepeatIntervalDays,
    required super.newCustomersThisWeek,
    required super.newCustomersLastWeek,
  });

  factory CustomerRetentionModel.fromJson(Map<String, dynamic> json) =>
      CustomerRetentionModel(
        totalCustomers: (json['totalCustomers'] as num).toInt(),
        returningCustomers: (json['returningCustomers'] as num).toInt(),
        retentionRate: (json['retentionRate'] as num).toDouble(),
        avgRepeatIntervalDays:
            (json['avgRepeatIntervalDays'] as num?)?.toDouble(),
        newCustomersThisWeek: (json['newCustomersThisWeek'] as num).toInt(),
        newCustomersLastWeek: (json['newCustomersLastWeek'] as num).toInt(),
      );
}

class StaffPerformanceStatModel extends StaffPerformanceStatEntity {
  const StaffPerformanceStatModel({
    required super.staffId,
    required super.staffName,
    required super.ordersCompleted,
    required super.ordersCancelled,
    required super.flagsRaised,
    required super.totalOrdersHandled,
    required super.avgFulfillmentTime,
    required super.cancellationRate,
  });

  factory StaffPerformanceStatModel.fromJson(Map<String, dynamic> json) =>
      StaffPerformanceStatModel(
        staffId: json['staffId'] as String,
        staffName: json['staffName'] as String,
        ordersCompleted: (json['ordersCompleted'] as num).toInt(),
        ordersCancelled: (json['ordersCancelled'] as num).toInt(),
        flagsRaised: (json['flagsRaised'] as num).toInt(),
        totalOrdersHandled: (json['totalOrdersHandled'] as num).toInt(),
        avgFulfillmentTime: (json['avgFulfillmentTime'] as num?)?.toDouble(),
        cancellationRate: (json['cancellationRate'] as num).toDouble(),
      );
}

class BasketAbandonmentModel extends BasketAbandonmentEntity {
  const BasketAbandonmentModel({
    required super.totalChecks,
    required super.convertedChecks,
    required super.abandonedChecks,
    required super.abandonmentRate,
    required super.conversionRate,
    required super.thisWeekAbandonmentRate,
    required super.lastWeekAbandonmentRate,
  });

  factory BasketAbandonmentModel.fromJson(Map<String, dynamic> json) =>
      BasketAbandonmentModel(
        totalChecks: (json['totalChecks'] as num).toInt(),
        convertedChecks: (json['convertedChecks'] as num).toInt(),
        abandonedChecks: (json['abandonedChecks'] as num).toInt(),
        abandonmentRate: (json['abandonmentRate'] as num).toDouble(),
        conversionRate: (json['conversionRate'] as num).toDouble(),
        thisWeekAbandonmentRate:
            (json['thisWeekAbandonmentRate'] as num).toDouble(),
        lastWeekAbandonmentRate:
            (json['lastWeekAbandonmentRate'] as num).toDouble(),
      );
}

class TopCustomerStatModel extends TopCustomerStatEntity {
  const TopCustomerStatModel({
    required super.userId,
    required super.name,
    required super.phone,
    required super.totalSpend,
    required super.totalOrders,
  });

  factory TopCustomerStatModel.fromJson(Map<String, dynamic> json) =>
      TopCustomerStatModel(
        userId: json['userId'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        totalSpend: (json['totalSpend'] as num).toDouble(),
        totalOrders: (json['totalOrders'] as num).toInt(),
      );
}

class CustomerLTVModel extends CustomerLTVEntity {
  const CustomerLTVModel({
    required super.totalCustomers,
    required super.avgRevenuePerCustomer,
    required super.avgOrdersPerCustomer,
    required super.avgDaysActive,
    required super.projectedMonthlyLTV,
    required super.topCustomers,
  });

  factory CustomerLTVModel.fromJson(Map<String, dynamic> json) =>
      CustomerLTVModel(
        totalCustomers: (json['totalCustomers'] as num).toInt(),
        avgRevenuePerCustomer:
            (json['avgRevenuePerCustomer'] as num).toDouble(),
        avgOrdersPerCustomer: (json['avgOrdersPerCustomer'] as num).toDouble(),
        avgDaysActive: (json['avgDaysActive'] as num?)?.toDouble(),
        projectedMonthlyLTV: (json['projectedMonthlyLTV'] as num?)?.toDouble(),
        topCustomers: (json['topCustomers'] as List<dynamic>? ?? [])
            .map((e) =>
                TopCustomerStatModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MonthlyRevenueStatModel extends MonthlyRevenueStatEntity {
  const MonthlyRevenueStatModel({
    required super.month,
    required super.year,
    required super.revenue,
    required super.orders,
  });

  factory MonthlyRevenueStatModel.fromJson(Map<String, dynamic> json) =>
      MonthlyRevenueStatModel(
        month: (json['month'] as num).toInt(),
        year: (json['year'] as num).toInt(),
        revenue: (json['revenue'] as num).toDouble(),
        orders: (json['orders'] as num).toInt(),
      );
}
