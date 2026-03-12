import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class ProductRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _storeProductsQuery = r'''
    query StoreProducts($storeId: ID!) {
      storeProducts(storeId: $storeId) {
        id barcode sku name description price stock storeId
      }
    }
  ''';

  static const _createProductMutation = r'''
    mutation CreateProduct($storeId: ID!, $barcode: String!, $sku: String, $name: String!, $description: String, $price: Float!, $stock: Int!) {
      createProduct(storeId: $storeId, barcode: $barcode, sku: $sku, name: $name, description: $description, price: $price, stock: $stock) {
        id barcode sku name description price stock storeId
      }
    }
  ''';

  static const _updateProductMutation = r'''
    mutation UpdateProduct($id: ID!, $sku: String, $name: String, $description: String, $price: Float, $stock: Int) {
      updateProduct(id: $id, sku: $sku, name: $name, description: $description, price: $price, stock: $stock) {
        id barcode sku name description price stock storeId
      }
    }
  ''';

  static const _deleteProductMutation = r'''
    mutation DeleteProduct($id: ID!) {
      deleteProduct(id: $id)
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

  Future<List<Map<String, dynamic>>> getStoreProducts(String storeId) async {
    final result = await _client.query(
      QueryOptions(document: gql(_storeProductsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['storeProducts'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createProduct({required String storeId, required String barcode, String? sku, required String name, String? description, required double price, required int stock}) async {
    final vars = {'storeId': storeId, 'barcode': barcode, if (sku != null) 'sku': sku, 'name': name, if (description != null) 'description': description, 'price': price, 'stock': stock};
    final result = await _client.mutate(MutationOptions(document: gql(_createProductMutation), variables: vars));
    _check(result);
    return result.data!['createProduct'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct({required String id, String? sku, String? name, String? description, double? price, int? stock}) async {
    final vars = {'id': id, if (sku != null) 'sku': sku, if (name != null) 'name': name, if (description != null) 'description': description, if (price != null) 'price': price, if (stock != null) 'stock': stock};
    final result = await _client.mutate(MutationOptions(document: gql(_updateProductMutation), variables: vars));
    _check(result);
    return result.data!['updateProduct'] as Map<String, dynamic>;
  }

  Future<bool> deleteProduct(String id) async {
    final result = await _client.mutate(MutationOptions(document: gql(_deleteProductMutation), variables: {'id': id}));
    _check(result);
    return result.data!['deleteProduct'] as bool;
  }
}
