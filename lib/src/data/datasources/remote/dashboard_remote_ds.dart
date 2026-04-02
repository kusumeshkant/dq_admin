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
}
