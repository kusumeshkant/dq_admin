import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/pagination/page_result.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class StoreRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _storesQuery = r'''
    query Stores {
      stores {
        id storeCode name address latitude longitude
      }
    }
  ''';

  // TODO: revert to storesPaginated once UAT backend is deployed
  static const _storesPageQuery = r'''
    query StoresFallback {
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

  String _errorMessage(OperationException e) {
    if (e.graphqlErrors.isNotEmpty) return e.graphqlErrors.map((e) => e.message).join(', ');
    if (e.linkException != null) return 'Network error — check your connection';
    return e.toString();
  }

  void _check(QueryResult result) {
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }

  Future<Map<String, dynamic>> fetchStoresPage(PageParams params, {String? storeId}) async {
    final vars = <String, dynamic>{
      'first': params.limit,
      if (params.cursor != null) 'after': params.cursor,
      if (params.search != null) 'search': params.search,
      if (storeId != null) 'storeId': storeId,
    };
    final result = await _client.query(
      QueryOptions(document: gql(_storesPageQuery), variables: vars, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    // TODO: revert to result.data!['storesPaginated'] once UAT backend is deployed
    final items = (result.data!['stores'] as List).cast<Map<String, dynamic>>();
    return {
      'items': items,
      'meta': {'hasNext': false, 'nextCursor': null, 'totalCount': items.length},
    };
  }

  Future<List<Map<String, dynamic>>> getAllStores() async {
    final result = await _client.query(
      QueryOptions(document: gql(_storesQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['stores'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createStore({required String name, required String address, required double lat, required double lon, String? storeCode}) async {
    final vars = {'name': name, 'address': address, 'lat': lat, 'lon': lon, if (storeCode != null && storeCode.isNotEmpty) 'storeCode': storeCode};
    final result = await _client.mutate(MutationOptions(document: gql(_createStoreMutation), variables: vars));
    _check(result);
    return result.data!['createStore'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStore({required String id, String? name, String? address, double? lat, double? lon, String? storeCode}) async {
    final vars = {'id': id, if (name != null) 'name': name, if (address != null) 'address': address, if (lat != null) 'lat': lat, if (lon != null) 'lon': lon, if (storeCode != null) 'storeCode': storeCode};
    final result = await _client.mutate(MutationOptions(document: gql(_updateStoreMutation), variables: vars));
    _check(result);
    return result.data!['updateStore'] as Map<String, dynamic>;
  }

  Future<bool> deleteStore(String id) async {
    final result = await _client.mutate(MutationOptions(document: gql(_deleteStoreMutation), variables: {'id': id}));
    _check(result);
    return result.data!['deleteStore'] as bool;
  }
}
