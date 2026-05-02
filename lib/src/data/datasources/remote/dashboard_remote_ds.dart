import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class DashboardRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _dashboardStatsQuery = r'''
    query DashboardStats {
      dashboardStats {
        totalRevenue
        totalOrders
        pendingOrders
        completedOrders
        activeStores
        topStores {
          store { id storeCode name address }
          revenue
          orderCount
        }
        recentOrders {
          id storeName storeId status total tax grandTotal createdAt
          items { barcode name price quantity }
          flaggedIssue { reason note staffName timestamp }
          staffActions { staffId staffName action timestamp note }
        }
      }
    }
  ''';

  static const _storeAnalyticsQuery = r'''
    query StoreAnalytics($storeId: ID) {
      storeAnalytics(storeId: $storeId) {
        totalRevenue
        totalOrders
        completedOrders
        cancelledOrders
        avgOrderValue
        topProducts { name barcode totalSold revenue }
        dailyRevenue { date revenue orders }
      }
    }
  ''';

  static const _customerRetentionQuery = r'''
    query CustomerRetention($storeId: ID) {
      customerRetention(storeId: $storeId) {
        totalCustomers returningCustomers retentionRate
        avgRepeatIntervalDays newCustomersThisWeek newCustomersLastWeek
      }
    }
  ''';

  static const _staffPerformanceQuery = r'''
    query StaffPerformance($storeId: ID) {
      staffPerformance(storeId: $storeId) {
        staffId staffName ordersCompleted ordersCancelled flagsRaised
        totalOrdersHandled avgFulfillmentTime cancellationRate
      }
    }
  ''';

  static const _basketAbandonmentQuery = r'''
    query BasketAbandonment($storeId: ID) {
      basketAbandonment(storeId: $storeId) {
        totalChecks convertedChecks abandonedChecks abandonmentRate
        conversionRate thisWeekAbandonmentRate lastWeekAbandonmentRate
      }
    }
  ''';

  static const _customerLTVQuery = r'''
    query CustomerLTV($storeId: ID) {
      customerLTV(storeId: $storeId) {
        totalCustomers avgRevenuePerCustomer avgOrdersPerCustomer
        avgDaysActive projectedMonthlyLTV
        topCustomers { userId name phone totalSpend totalOrders }
      }
    }
  ''';

  static const _monthlyRevenueQuery = r'''
    query MonthlyRevenue($storeId: ID, $year: Int) {
      monthlyRevenue(storeId: $storeId, year: $year) {
        month year revenue orders
      }
    }
  ''';

  static const _storeStatsQuery = r'''
    query StoreStats($storeId: ID!) {
      storeStats(storeId: $storeId) {
        totalRevenue
        totalOrders
        pendingOrders
        completedOrders
        store { id storeCode name address }
        recentOrders {
          id storeName storeId status total tax grandTotal createdAt
          items { barcode name price quantity }
          flaggedIssue { reason note staffName timestamp }
          staffActions { staffId staffName action timestamp note }
        }
      }
    }
  ''';

  String _errorMessage(OperationException e) {
    if (e.graphqlErrors.isNotEmpty) return e.graphqlErrors.map((e) => e.message).join(', ');
    if (e.linkException != null) return 'Network error — check your connection';
    return e.toString();
  }

  void _check(QueryResult result) {
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final result = await _client.query(
      QueryOptions(document: gql(_dashboardStatsQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return result.data!['dashboardStats'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStoreStats(String storeId) async {
    final result = await _client.query(
      QueryOptions(document: gql(_storeStatsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return result.data!['storeStats'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStoreAnalytics(String? storeId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_storeAnalyticsQuery),
        variables: storeId != null ? {'storeId': storeId} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['storeAnalytics'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCustomerRetention(String? storeId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_customerRetentionQuery),
        variables: storeId != null ? {'storeId': storeId} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['customerRetention'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getStaffPerformance(String? storeId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_staffPerformanceQuery),
        variables: storeId != null ? {'storeId': storeId} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['staffPerformance'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getBasketAbandonment(String? storeId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_basketAbandonmentQuery),
        variables: storeId != null ? {'storeId': storeId} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['basketAbandonment'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCustomerLTV(String? storeId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_customerLTVQuery),
        variables: storeId != null ? {'storeId': storeId} : {},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['customerLTV'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMonthlyRevenue(String? storeId, int year) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_monthlyRevenueQuery),
        variables: {
          if (storeId != null) 'storeId': storeId,
          'year': year,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    _check(result);
    return result.data!['monthlyRevenue'] as List<dynamic>;
  }
}
