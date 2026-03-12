import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';

class StaffRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

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

  String _errorMessage(OperationException e) {
    if (e.graphqlErrors.isNotEmpty) return e.graphqlErrors.map((e) => e.message).join(', ');
    if (e.linkException != null) return 'Network error — check your connection';
    return e.toString();
  }

  void _check(QueryResult result) {
    if (result.hasException) throw Exception(_errorMessage(result.exception!));
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final result = await _client.query(
      QueryOptions(document: gql(_allStaffQuery), fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return (result.data!['allStaff'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final result = await _client.query(
      QueryOptions(document: gql(_userByEmailQuery), variables: {'email': email}, fetchPolicy: FetchPolicy.networkOnly),
    );
    _check(result);
    return result.data?['userByEmail'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> updateUserRole({required String userId, required String role, String? storeId}) async {
    final vars = {'userId': userId, 'role': role, if (storeId != null) 'storeId': storeId};
    final result = await _client.mutate(MutationOptions(document: gql(_updateUserRoleMutation), variables: vars));
    _check(result);
    return result.data!['updateUserRole'] as Map<String, dynamic>;
  }
}
