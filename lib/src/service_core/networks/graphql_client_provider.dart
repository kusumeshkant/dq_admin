import 'package:firebase_auth/firebase_auth.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../constants/app_config.dart';
import 'app_logger.dart';

/// Intercepts every GraphQL operation and logs:
///   - Request  → cyan  (operation name + variables)
///   - Response → green (response data)
///   - GQL error → red  (error messages)
///   - Link/network error → red (exception detail)
class LoggingLink extends Link {
  @override
  Stream<Response> request(Request req, [NextLink? forward]) async* {
    final operation = req.operation.operationName ?? req.operation.document
        .definitions
        .map((d) => d.toString())
        .firstOrNull ?? 'unknown';

    final vars = req.variables.isNotEmpty ? req.variables : null;
    AppLogger.request(operation, variables: vars);

    try {
      await for (final response in forward!(req)) {
        if (response.errors != null && response.errors!.isNotEmpty) {
          AppLogger.graphqlError(operation, response.errors!);
        } else {
          AppLogger.response(operation, response.data);
        }
        yield response;
      }
    } catch (e, st) {
      AppLogger.networkError(operation, e);
      AppLogger.error(operation, e, st);
      rethrow;
    }
  }
}

class GraphQLClientProvider {
  static GraphQLClient? _client;

  static GraphQLClient get client {
    _client ??= _build();
    return _client!;
  }

  static Future<void> reinitWithToken() async {
    AppLogger.auth('token refreshed — rebuilding client');
    _client = _build();
  }

  static void reset() {
    AppLogger.auth('client reset');
    _client = null;
  }

  static GraphQLClient _build() {
    final httpLink = HttpLink(AppConfig.graphqlEndpoint);

    final authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return null;
        final token = await user.getIdToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = LoggingLink().concat(authLink.concat(httpLink));

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
