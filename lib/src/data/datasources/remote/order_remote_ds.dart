import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/pagination/page_result.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class OrderRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _allOrdersQuery = r'''
    query AllOrders($storeId: ID, $status: String) {
      allOrders(storeId: $storeId, status: $status) {
        id storeName storeId total tax grandTotal status createdAt
        items { barcode name price quantity }
        staffActions { staffId staffName action timestamp note }
        flaggedIssue { reason note staffName timestamp }
      }
    }
  ''';

  static const _ordersPageQuery = r'''
    query AllOrdersPaginated(
      $first: Int, $after: String, $search: String,
      $storeId: ID, $status: String
    ) {
      allOrdersPaginated(
        first: $first, after: $after, search: $search,
        storeId: $storeId, status: $status
      ) {
        items {
          id storeName storeId total tax grandTotal status createdAt
          items { barcode name price quantity }
          staffActions { staffId staffName action timestamp note }
          flaggedIssue { reason note staffName timestamp }
        }
        meta { hasNext nextCursor totalCount }
        activeCount
        completedCount
        cancelledCount
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

  Future<List<Map<String, dynamic>>> getAllOrders({String? storeId, String? status}) async {
    final vars = {if (storeId != null) 'storeId': storeId, if (status != null) 'status': status};
    final result = await _client.query(
      QueryOptions(document: gql(_allOrdersQuery), variables: vars, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['allOrders'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchOrdersPage(PageParams params, {String? storeId}) async {
    final vars = <String, dynamic>{
      'first': params.limit,
      if (params.cursor != null) 'after': params.cursor,
      if (params.search != null) 'search': params.search,
      if (storeId != null) 'storeId': storeId,
      if (params.filters['status'] != null) 'status': params.filters['status'],
    };
    final result = await _client.query(
      QueryOptions(document: gql(_ordersPageQuery), variables: vars, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return result.data!['allOrdersPaginated'] as Map<String, dynamic>;
  }
}
