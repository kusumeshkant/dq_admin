import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class PermissionRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _pendingRequestsQuery = r'''
    query PendingPermissionRequests($storeId: ID!) {
      pendingPermissionRequests(storeId: $storeId) {
        id staffId staffName staffEmail storeId requestType status reason
        requestedMaxDiscountPercent requestedProductPerms
        grantedMaxDiscountPercent grantedProductPerms
        reviewedBy reviewNote createdAt reviewedAt
      }
    }
  ''';

  static const _allRequestsQuery = r'''
    query AllPermissionRequests($storeId: ID!, $status: String) {
      allPermissionRequests(storeId: $storeId, status: $status) {
        id staffId staffName staffEmail storeId requestType status reason
        requestedMaxDiscountPercent requestedProductPerms
        grantedMaxDiscountPercent grantedProductPerms
        reviewedBy reviewNote createdAt reviewedAt
      }
    }
  ''';

  static const _discountLogsQuery = r'''
    query DiscountLogs($storeId: ID!, $limit: Int, $offset: Int) {
      discountLogs(storeId: $storeId, limit: $limit, offset: $offset) {
        id orderId storeId staffId staffName discountCode
        discountPercent originalAmount discountAmount finalAmount appliedAt
      }
    }
  ''';

  static const _productChangeLogsQuery = r'''
    query ProductChangeLogs($storeId: ID!, $limit: Int, $offset: Int) {
      productChangeLogs(storeId: $storeId, limit: $limit, offset: $offset) {
        id productId storeId barcode changedBy changedByName changedByRole
        changeType changedFields createdAt
      }
    }
  ''';

  static const _approveMutation = r'''
    mutation ApprovePermissionRequest(
      $requestId: ID!
      $reviewNote: String
      $grantedMaxDiscountPercent: Float
      $grantedProductPerms: [String!]
    ) {
      approvePermissionRequest(
        requestId: $requestId
        reviewNote: $reviewNote
        grantedMaxDiscountPercent: $grantedMaxDiscountPercent
        grantedProductPerms: $grantedProductPerms
      ) {
        id status reviewedAt reviewNote
      }
    }
  ''';

  static const _rejectMutation = r'''
    mutation RejectPermissionRequest($requestId: ID!, $reviewNote: String) {
      rejectPermissionRequest(requestId: $requestId, reviewNote: $reviewNote) {
        id status reviewedAt reviewNote
      }
    }
  ''';

  static const _revokeMutation = r'''
    mutation RevokeStaffPermission($staffId: ID!, $storeId: ID!, $permissionType: String!) {
      revokeStaffPermission(staffId: $staffId, storeId: $storeId, permissionType: $permissionType) {
        staffId canDiscount maxDiscountPercent
        canEditProductInfo canAddProduct canDeleteProduct canBulkUploadProducts
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

  Future<List<Map<String, dynamic>>> getPendingRequests(String storeId) async {
    final result = await _client.query(QueryOptions(
      document: gql(_pendingRequestsQuery),
      variables: {'storeId': storeId},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    _check(result);
    return (result.data!['pendingPermissionRequests'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getAllRequests(String storeId, {String? status}) async {
    final result = await _client.query(QueryOptions(
      document: gql(_allRequestsQuery),
      variables: {'storeId': storeId, if (status != null) 'status': status},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    _check(result);
    return (result.data!['allPermissionRequests'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getDiscountLogs(String storeId, {int limit = 50, int offset = 0}) async {
    final result = await _client.query(QueryOptions(
      document: gql(_discountLogsQuery),
      variables: {'storeId': storeId, 'limit': limit, 'offset': offset},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    _check(result);
    return (result.data!['discountLogs'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getProductChangeLogs(String storeId, {int limit = 50, int offset = 0}) async {
    final result = await _client.query(QueryOptions(
      document: gql(_productChangeLogsQuery),
      variables: {'storeId': storeId, 'limit': limit, 'offset': offset},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    _check(result);
    return (result.data!['productChangeLogs'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> approveRequest({
    required String requestId,
    String? reviewNote,
    double? grantedMaxDiscountPercent,
    List<String>? grantedProductPerms,
  }) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_approveMutation),
      variables: {
        'requestId': requestId,
        if (reviewNote != null) 'reviewNote': reviewNote,
        if (grantedMaxDiscountPercent != null) 'grantedMaxDiscountPercent': grantedMaxDiscountPercent,
        if (grantedProductPerms != null) 'grantedProductPerms': grantedProductPerms,
      },
    ));
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }

  Future<void> rejectRequest({required String requestId, String? reviewNote}) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_rejectMutation),
      variables: {'requestId': requestId, if (reviewNote != null) 'reviewNote': reviewNote},
    ));
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }

  Future<void> revokePermission({
    required String staffId,
    required String storeId,
    required String permissionType,
  }) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_revokeMutation),
      variables: {'staffId': staffId, 'storeId': storeId, 'permissionType': permissionType},
    ));
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }
}
