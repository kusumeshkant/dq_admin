import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class ProductRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  static const _storeProductsQuery = r'''
    query StoreProducts($storeId: ID!) {
      storeProducts(storeId: $storeId) {
        id barcode sku name description brand gender color
        category { main sub }
        size { garment actual }
        price mrp stock reorderLevel isAvailable storeId
      }
    }
  ''';

  static const _createProductMutation = r'''
    mutation CreateProduct(
      $storeId: ID!, $barcode: String!, $sku: String, $name: String!,
      $description: String, $brand: String, $gender: String, $color: String,
      $categoryMain: String, $categorySub: String, $sizeGarment: String, $sizeActual: String,
      $price: Float!, $mrp: Float, $stock: Int!, $reorderLevel: Int
    ) {
      createProduct(
        storeId: $storeId, barcode: $barcode, sku: $sku, name: $name,
        description: $description, brand: $brand, gender: $gender, color: $color,
        categoryMain: $categoryMain, categorySub: $categorySub,
        sizeGarment: $sizeGarment, sizeActual: $sizeActual,
        price: $price, mrp: $mrp, stock: $stock, reorderLevel: $reorderLevel
      ) {
        id barcode sku name description brand gender color
        category { main sub }
        size { garment actual }
        price mrp stock reorderLevel isAvailable storeId
      }
    }
  ''';

  static const _updateProductMutation = r'''
    mutation UpdateProduct(
      $id: ID!, $sku: String, $name: String, $description: String,
      $brand: String, $gender: String, $color: String,
      $categoryMain: String, $categorySub: String, $sizeGarment: String, $sizeActual: String,
      $price: Float, $mrp: Float, $stock: Int, $reorderLevel: Int, $isAvailable: Boolean
    ) {
      updateProduct(
        id: $id, sku: $sku, name: $name, description: $description,
        brand: $brand, gender: $gender, color: $color,
        categoryMain: $categoryMain, categorySub: $categorySub,
        sizeGarment: $sizeGarment, sizeActual: $sizeActual,
        price: $price, mrp: $mrp, stock: $stock, reorderLevel: $reorderLevel, isAvailable: $isAvailable
      ) {
        id barcode sku name description brand gender color
        category { main sub }
        size { garment actual }
        price mrp stock reorderLevel isAvailable storeId
      }
    }
  ''';

  static const _deleteProductMutation = r'''
    mutation DeleteProduct($id: ID!) {
      deleteProduct(id: $id)
    }
  ''';

  static const _bulkUpsertMutation = r'''
    mutation BulkUpsertProducts($storeId: ID!, $products: [BulkProductInput!]!, $fileName: String, $totalRows: Int, $totalColumns: Int) {
      bulkUpsertProducts(storeId: $storeId, products: $products, fileName: $fileName, totalRows: $totalRows, totalColumns: $totalColumns) {
        created
        updated
        skipped
        errors { barcode message }
      }
    }
  ''';

  static const _uploadLogsQuery = r'''
    query UploadLogs($storeId: ID!) {
      uploadLogs(storeId: $storeId) {
        id storeId storeName uploadedByName fileName uploadedAt
        totalRows totalColumns created updated skipped errorCount
        errors { barcode message }
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

  Future<List<Map<String, dynamic>>> getStoreProducts(String storeId) async {
    final result = await _client.query(
      QueryOptions(document: gql(_storeProductsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['storeProducts'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createProduct({
    required String storeId, required String barcode, String? sku, required String name,
    String? description, String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    required double price, double? mrp, required int stock, int? reorderLevel,
  }) async {
    final vars = {
      'storeId': storeId, 'barcode': barcode, 'name': name, 'price': price, 'stock': stock,
      if (sku != null) 'sku': sku,
      if (description != null) 'description': description,
      if (brand != null) 'brand': brand,
      if (gender != null) 'gender': gender,
      if (color != null) 'color': color,
      if (categoryMain != null) 'categoryMain': categoryMain,
      if (categorySub != null) 'categorySub': categorySub,
      if (sizeGarment != null) 'sizeGarment': sizeGarment,
      if (sizeActual != null) 'sizeActual': sizeActual,
      if (mrp != null) 'mrp': mrp,
      if (reorderLevel != null) 'reorderLevel': reorderLevel,
    };
    final result = await _client.mutate(MutationOptions(document: gql(_createProductMutation), variables: vars));
    _check(result);
    return result.data!['createProduct'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct({
    required String id, String? sku, String? name, String? description,
    String? brand, String? gender, String? color,
    String? categoryMain, String? categorySub, String? sizeGarment, String? sizeActual,
    double? price, double? mrp, int? stock, int? reorderLevel, bool? isAvailable,
  }) async {
    final vars = {
      'id': id,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (brand != null) 'brand': brand,
      if (gender != null) 'gender': gender,
      if (color != null) 'color': color,
      if (categoryMain != null) 'categoryMain': categoryMain,
      if (categorySub != null) 'categorySub': categorySub,
      if (sizeGarment != null) 'sizeGarment': sizeGarment,
      if (sizeActual != null) 'sizeActual': sizeActual,
      if (price != null) 'price': price,
      if (mrp != null) 'mrp': mrp,
      if (stock != null) 'stock': stock,
      if (reorderLevel != null) 'reorderLevel': reorderLevel,
      if (isAvailable != null) 'isAvailable': isAvailable,
    };
    final result = await _client.mutate(MutationOptions(document: gql(_updateProductMutation), variables: vars));
    _check(result);
    return result.data!['updateProduct'] as Map<String, dynamic>;
  }

  Future<bool> deleteProduct(String id) async {
    final result = await _client.mutate(MutationOptions(document: gql(_deleteProductMutation), variables: {'id': id}));
    _check(result);
    return result.data!['deleteProduct'] as bool;
  }

  Future<Map<String, dynamic>> bulkUpsertProducts({required String storeId, required List<Map<String, dynamic>> products, String? fileName, int? totalRows, int? totalColumns}) async {
    final result = await _client.mutate(MutationOptions(
      document: gql(_bulkUpsertMutation),
      variables: {
        'storeId': storeId,
        'products': products,
        if (fileName != null) 'fileName': fileName,
        if (totalRows != null) 'totalRows': totalRows,
        if (totalColumns != null) 'totalColumns': totalColumns,
      },
    ));
    _check(result);
    return result.data!['bulkUpsertProducts'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUploadLogs(String storeId) async {
    final result = await _client.query(
      QueryOptions(document: gql(_uploadLogsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['uploadLogs'] as List).cast<Map<String, dynamic>>();
  }
}
