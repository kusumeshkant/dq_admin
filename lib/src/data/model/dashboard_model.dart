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
