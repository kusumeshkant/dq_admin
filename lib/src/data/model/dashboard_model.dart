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
