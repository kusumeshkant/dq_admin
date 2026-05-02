import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' hide Response;
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../constants/app_config.dart';
import '../auth/session_manager.dart';
import 'app_logger.dart';

/// Logs every GraphQL operation to the debug console.
class LoggingLink extends Link {
  @override
  Stream<Response> request(Request req, [NextLink? forward]) async* {
    final operation = req.operation.operationName ??
        req.operation.document.definitions
            .map((d) => d.toString())
            .firstOrNull ??
        'unknown';

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

    // Fetches a fresh Firebase ID token on every request.
    // Firebase SDK transparently refreshes the token ~5 min before expiry.
    final authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return null;
        final token = await user.getIdToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    // Catches UNAUTHENTICATED errors (token truly expired server-side),
    // force-refreshes the Firebase token, retries the original request once.
    // If the retry also fails, or there is no current user, the session is
    // expired and the user is navigated back to the login screen.
    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        final isUnauthenticated = response.errors
                ?.any((e) => e.extensions?['code'] == 'UNAUTHENTICATED') ??
            false;

        if (!isUnauthenticated) {
          yield response;
          return;
        }

        AppLogger.auth('UNAUTHENTICATED — force-refreshing token');

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          await _expireSession();
          return;
        }

        try {
          await user.getIdToken(true); // force server-side refresh
        } catch (_) {
          await _expireSession();
          return;
        }

        // Retry once — AuthLink will pick up the fresh token automatically
        await for (final result in forward(request)) {
          if (result.errors
                  ?.any((e) => e.extensions?['code'] == 'UNAUTHENTICATED') ??
              false) {
            await _expireSession();
            return;
          }
          yield result;
        }
      },
    );

    final link = LoggingLink().concat(errorLink.concat(authLink.concat(httpLink)));

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  /// Called when token refresh fails — clears client then delegates to
  /// SessionManager which navigates to login and shows a snackbar.
  ///
  /// Guard: if there is no active session (SessionManager.currentUser == null)
  /// we are in a context where no user is logged in — e.g. a brand-new account's
  /// first registerAdmin call during signup. Navigating to LoginPage here would
  /// silently interrupt the signup flow. In that case, just clear the client and
  /// return so the calling code (signup retry loop / ErrorLink) handles it.
  static Future<void> _expireSession() async {
    _client = null;
    try {
      final session = Get.find<SessionManager>();
      if (session.currentUser.value == null) {
        // No active session — nothing to expire. Do NOT navigate to LoginPage
        // as this would hijack flows like signup that run before setUser().
        AppLogger.auth('_expireSession called with no active session — skipping navigation');
        return;
      }
    } catch (_) {
      // SessionManager not registered yet (very early boot) — safe to skip.
      return;
    }
    AppLogger.auth('session expired — clearing client and navigating to login');
    try {
      await Get.find<SessionManager>().expireSession();
    } catch (_) {}
  }
}
