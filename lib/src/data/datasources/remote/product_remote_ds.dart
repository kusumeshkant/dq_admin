import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../../core/pagination/page_result.dart';

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

  static const _storeProductsPaginatedQuery = r'''
    query StoreProductsPaginated(
      $storeId:  ID!
      $first:    Int
      $after:    String
      $search:   String
      $sortBy:   String
      $sortDir:  String
      $brand:        String
      $gender:       String
      $categoryMain: String
      $inStock:      Boolean
      $lowStock:     Boolean
    ) {
      storeProductsPaginated(
        storeId:  $storeId
        first:    $first
        after:    $after
        search:   $search
        sortBy:   $sortBy
        sortDir:  $sortDir
        filters: {
          brand:        $brand
          gender:       $gender
          categoryMain: $categoryMain
          inStock:      $inStock
          lowStock:     $lowStock
        }
      ) {
        items {
          id barcode sku name description brand gender color
          category { main sub }
          size { garment actual }
          price mrp stock reorderLevel isAvailable storeId
        }
        meta { hasNext nextCursor totalCount }
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
    const chunkSize = 200;
    int created = 0, updated = 0, skipped = 0;
    final errors = <Map<String, dynamic>>[];

    for (int i = 0; i < products.length; i += chunkSize) {
      final chunk = products.sublist(i, (i + chunkSize).clamp(0, products.length));
      // Only send fileName/totalRows on first chunk so the upload log isn't duplicated
      final result = await _client.mutate(MutationOptions(
        document: gql(_bulkUpsertMutation),
        variables: {
          'storeId': storeId,
          'products': chunk,
          if (i == 0 && fileName != null) 'fileName': fileName,
          if (i == 0 && totalRows != null) 'totalRows': totalRows,
          if (i == 0 && totalColumns != null) 'totalColumns': totalColumns,
        },
      ));
      _check(result);
      final r = result.data!['bulkUpsertProducts'] as Map<String, dynamic>;
      created += (r['created'] as int? ?? 0);
      updated += (r['updated'] as int? ?? 0);
      skipped += (r['skipped'] as int? ?? 0);
      errors.addAll((r['errors'] as List? ?? []).cast<Map<String, dynamic>>());
    }

    return {'created': created, 'updated': updated, 'skipped': skipped, 'errors': errors};
  }

  Future<PageResult<Map<String, dynamic>>> fetchProductsPage(
      String storeId, PageParams params) async {
    final vars = <String, dynamic>{'storeId': storeId, 'first': params.limit};
    if (params.cursor != null)   vars['after']   = params.cursor;
    if (params.search != null)   vars['search']  = params.search;
    if (params.sortBy != null)   vars['sortBy']  = params.sortBy;
    if (params.sortDir.isNotEmpty) vars['sortDir'] = params.sortDir;
    // Unpack filters into individual variables (schema uses inline input object)
    final f = params.filters;
    if (f['brand'] != null)        vars['brand']        = f['brand'];
    if (f['gender'] != null)       vars['gender']       = f['gender'];
    if (f['categoryMain'] != null) vars['categoryMain'] = f['categoryMain'];
    if (f['inStock'] != null)      vars['inStock']      = f['inStock'];
    if (f['lowStock'] != null)     vars['lowStock']     = f['lowStock'];

    final result = await _client.query(QueryOptions(
      document: gql(_storeProductsPaginatedQuery),
      variables: vars,
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    _check(result);

    final page = result.data!['storeProductsPaginated'] as Map<String, dynamic>;
    final meta = page['meta'] as Map<String, dynamic>;
    return PageResult(
      items:      (page['items'] as List).cast<Map<String, dynamic>>(),
      hasNext:    meta['hasNext'] as bool,
      nextCursor: meta['nextCursor'] as String?,
      totalCount: meta['totalCount'] as int?,
    );
  }

  Future<List<Map<String, dynamic>>> getUploadLogs(String storeId) async {
    final result = await _client.query(
      QueryOptions(document: gql(_uploadLogsQuery), variables: {'storeId': storeId}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['uploadLogs'] as List).cast<Map<String, dynamic>>();
  }
}
