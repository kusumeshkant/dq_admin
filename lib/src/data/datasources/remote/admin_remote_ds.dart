import 'package:dq_admin/src/service_core/networks/graphql_client_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AdminRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  AdminRemoteDs();

  // ── Logger helpers ────────────────────────────────────────────────────────

  void _logRequest(String method, [Map<String, dynamic>? variables]) {
    debugPrint('╔══ [AdminDS] $method ══');
    if (variables != null && variables.isNotEmpty) {
      debugPrint('║  vars: $variables');
    }
  }

  void _logSuccess(String method, dynamic data) {
    debugPrint('╚══ [AdminDS] $method ✓  data: $data');
  }

  void _logError(String method, OperationException exception) {
    debugPrint('╚══ [AdminDS] $method ✗');
    for (final e in exception.graphqlErrors) {
      debugPrint('   GraphQL error: ${e.message}');
    }
    if (exception.linkException != null) {
      debugPrint('   Network error: ${exception.linkException}');
    }
  }

  /// Extracts a human-readable message from a GraphQL exception.
  String _errorMessage(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      return exception.graphqlErrors.map((e) => e.message).join(', ');
    }
    if (exception.linkException != null) {
      return 'Network error — check your connection';
    }
    return exception.toString();
  }

  void _check(String method, QueryResult result) {
    if (result.hasException) {
      _logError(method, result.exception!);
      throw Exception(_errorMessage(result.exception!));
    }
  }

  // ── Dashboard ────────────────────────────────────────────────────────────

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
          id storeName storeId status grandTotal createdAt
          items { barcode name price quantity }
          flaggedIssue { reason note staffName timestamp }
          staffActions { staffId staffName action timestamp note }
        }
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
          id storeName storeId status grandTotal createdAt
          items { barcode name price quantity }
          flaggedIssue { reason note staffName timestamp }
          staffActions { staffId staffName action timestamp note }
        }
      }
    }
  ''';

  // ── Stores ───────────────────────────────────────────────────────────────

  static const _storesQuery = r'''
    query Stores {
      stores {
        id storeCode name address latitude longitude
      }
    }
  ''';

  static const _createStoreMutation = r'''
    mutation CreateStore($name: String!, $address: String!, $lat: Float!, $lon: Float!, $storeCode: String) {
      createStore(name: $name, address: $address, lat: $lat, lon: $lon, storeCode: $storeCode) {
        id storeCode name address latitude longitude
      }
    }
  ''';

  static const _updateStoreMutation = r'''
    mutation UpdateStore($id: ID!, $name: String, $address: String, $lat: Float, $lon: Float, $storeCode: String) {
      updateStore(id: $id, name: $name, address: $address, lat: $lat, lon: $lon, storeCode: $storeCode) {
        id storeCode name address latitude longitude
      }
    }
  ''';

  static const _deleteStoreMutation = r'''
    mutation DeleteStore($id: ID!) {
      deleteStore(id: $id)
    }
  ''';

  // ── Products ─────────────────────────────────────────────────────────────

  static const _storeProductsQuery = r'''
    query StoreProducts($storeId: ID!) {
      storeProducts(storeId: $storeId) {
        id barcode name description price stock storeId
      }
    }
  ''';

  static const _createProductMutation = r'''
    mutation CreateProduct($storeId: ID!, $barcode: String!, $name: String!, $description: String, $price: Float!, $stock: Int!) {
      createProduct(storeId: $storeId, barcode: $barcode, name: $name, description: $description, price: $price, stock: $stock) {
        id barcode name description price stock storeId
      }
    }
  ''';

  static const _updateProductMutation = r'''
    mutation UpdateProduct($id: ID!, $name: String, $description: String, $price: Float, $stock: Int) {
      updateProduct(id: $id, name: $name, description: $description, price: $price, stock: $stock) {
        id barcode name description price stock storeId
      }
    }
  ''';

  static const _deleteProductMutation = r'''
    mutation DeleteProduct($id: ID!) {
      deleteProduct(id: $id)
    }
  ''';

  // ── Orders ───────────────────────────────────────────────────────────────

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

  // ── Staff ────────────────────────────────────────────────────────────────

  static const _allStaffQuery = r'''
    query AllStaff {
      allStaff {
        id name email phone role storeId
      }
    }
  ''';

  static const _userByEmailQuery = r'''
    query UserByEmail($email: String!) {
      userByEmail(email: $email) {
        id name email phone role storeId
      }
    }
  ''';

  static const _updateUserRoleMutation = r'''
    mutation UpdateUserRole($userId: ID!, $role: String!, $storeId: ID) {
      updateUserRole(userId: $userId, role: $role, storeId: $storeId) {
        id name email phone role storeId
      }
    }
  ''';

  // ── Methods ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    _logRequest('getDashboardStats');
    final result = await _client.query(
      QueryOptions(document: gql(_dashboardStatsQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getDashboardStats', result);
    final data = result.data!['dashboardStats'] as Map<String, dynamic>;
    _logSuccess('getDashboardStats', data.keys);
    return data;
  }

  Future<Map<String, dynamic>> getStoreStats(String storeId) async {
    _logRequest('getStoreStats', {'storeId': storeId});
    final result = await _client.query(
      QueryOptions(document: gql(_storeStatsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getStoreStats', result);
    final data = result.data!['storeStats'] as Map<String, dynamic>;
    _logSuccess('getStoreStats', data.keys);
    return data;
  }

  Future<List<Map<String, dynamic>>> getAllStores() async {
    _logRequest('getAllStores');
    final result = await _client.query(
      QueryOptions(document: gql(_storesQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getAllStores', result);
    final data = (result.data!['stores'] as List).cast<Map<String, dynamic>>();
    _logSuccess('getAllStores', '${data.length} stores');
    return data;
  }

  Future<Map<String, dynamic>> createStore({required String name, required String address, required double lat, required double lon, String? storeCode}) async {
    final vars = {'name': name, 'address': address, 'lat': lat, 'lon': lon, if (storeCode != null && storeCode.isNotEmpty) 'storeCode': storeCode};
    _logRequest('createStore', vars);
    final result = await _client.mutate(MutationOptions(document: gql(_createStoreMutation), variables: vars));
    _check('createStore', result);
    final data = result.data!['createStore'] as Map<String, dynamic>;
    _logSuccess('createStore', data);
    return data;
  }

  Future<Map<String, dynamic>> updateStore({required String id, String? name, String? address, double? lat, double? lon, String? storeCode}) async {
    final vars = {'id': id, if (name != null) 'name': name, if (address != null) 'address': address, if (lat != null) 'lat': lat, if (lon != null) 'lon': lon, if (storeCode != null) 'storeCode': storeCode};
    _logRequest('updateStore', vars);
    final result = await _client.mutate(MutationOptions(document: gql(_updateStoreMutation), variables: vars));
    _check('updateStore', result);
    final data = result.data!['updateStore'] as Map<String, dynamic>;
    _logSuccess('updateStore', data);
    return data;
  }

  Future<bool> deleteStore(String id) async {
    _logRequest('deleteStore', {'id': id});
    final result = await _client.mutate(MutationOptions(document: gql(_deleteStoreMutation), variables: {'id': id}));
    _check('deleteStore', result);
    _logSuccess('deleteStore', true);
    return result.data!['deleteStore'] as bool;
  }

  Future<List<Map<String, dynamic>>> getStoreProducts(String storeId) async {
    _logRequest('getStoreProducts', {'storeId': storeId});
    final result = await _client.query(
      QueryOptions(document: gql(_storeProductsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getStoreProducts', result);
    final data = (result.data!['storeProducts'] as List).cast<Map<String, dynamic>>();
    _logSuccess('getStoreProducts', '${data.length} products');
    return data;
  }

  Future<Map<String, dynamic>> createProduct({required String storeId, required String barcode, required String name, String? description, required double price, required int stock}) async {
    final vars = {'storeId': storeId, 'barcode': barcode, 'name': name, if (description != null) 'description': description, 'price': price, 'stock': stock};
    _logRequest('createProduct', vars);
    final result = await _client.mutate(MutationOptions(document: gql(_createProductMutation), variables: vars));
    _check('createProduct', result);
    final data = result.data!['createProduct'] as Map<String, dynamic>;
    _logSuccess('createProduct', data);
    return data;
  }

  Future<Map<String, dynamic>> updateProduct({required String id, String? name, String? description, double? price, int? stock}) async {
    final vars = {'id': id, if (name != null) 'name': name, if (description != null) 'description': description, if (price != null) 'price': price, if (stock != null) 'stock': stock};
    _logRequest('updateProduct', vars);
    final result = await _client.mutate(MutationOptions(document: gql(_updateProductMutation), variables: vars));
    _check('updateProduct', result);
    final data = result.data!['updateProduct'] as Map<String, dynamic>;
    _logSuccess('updateProduct', data);
    return data;
  }

  Future<bool> deleteProduct(String id) async {
    _logRequest('deleteProduct', {'id': id});
    final result = await _client.mutate(MutationOptions(document: gql(_deleteProductMutation), variables: {'id': id}));
    _check('deleteProduct', result);
    _logSuccess('deleteProduct', true);
    return result.data!['deleteProduct'] as bool;
  }

  Future<List<Map<String, dynamic>>> getAllOrders({String? storeId, String? status}) async {
    final vars = {if (storeId != null) 'storeId': storeId, if (status != null) 'status': status};
    _logRequest('getAllOrders', vars);
    final result = await _client.query(
      QueryOptions(document: gql(_allOrdersQuery), variables: vars, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getAllOrders', result);
    final data = (result.data!['allOrders'] as List).cast<Map<String, dynamic>>();
    _logSuccess('getAllOrders', '${data.length} orders');
    return data;
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    _logRequest('getAllStaff');
    final result = await _client.query(
      QueryOptions(document: gql(_allStaffQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getAllStaff', result);
    final data = (result.data!['allStaff'] as List).cast<Map<String, dynamic>>();
    _logSuccess('getAllStaff', '${data.length} staff');
    return data;
  }

  Future<Map<String, dynamic>> updateUserRole({required String userId, required String role, String? storeId}) async {
    final vars = {'userId': userId, 'role': role, if (storeId != null) 'storeId': storeId};
    _logRequest('updateUserRole', vars);
    final result = await _client.mutate(MutationOptions(document: gql(_updateUserRoleMutation), variables: vars));
    _check('updateUserRole', result);
    final data = result.data!['updateUserRole'] as Map<String, dynamic>;
    _logSuccess('updateUserRole', data);
    return data;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    _logRequest('getUserByEmail', {'email': email});
    final result = await _client.query(
      QueryOptions(document: gql(_userByEmailQuery), variables: {'email': email}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check('getUserByEmail', result);
    final data = result.data?['userByEmail'] as Map<String, dynamic>?;
    _logSuccess('getUserByEmail', data);
    return data;
  }
}
