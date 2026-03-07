import 'package:dq_admin/src/service_core/networks/graphql_client_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthRemoteDs {
  GraphQLClient get _client => GraphQLClientProvider.client;

  AuthRemoteDs();

  static const _meQuery = r'''
    query Me {
      me {
        id
        name
        email
        phone
        role
        storeId
      }
    }
  ''';

  Future<void> loginWithEmail(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final result = await _client.query(
      QueryOptions(document: gql(_meQuery)),
    );
    if (result.hasException) throw Exception(result.exception.toString());
    return result.data!['me'] as Map<String, dynamic>;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
