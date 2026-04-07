import '../repo/auth_repository.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/networks/graphql_client_provider.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  final SessionManager sessionManager;

  LogoutUseCase({required this.authRepository, required this.sessionManager});

  Future<void> execute() async {
    await sessionManager.clearCache(); // clear offline profile before signout
    sessionManager.clearUser();
    GraphQLClientProvider.reset(); // drop client before signout to prevent UNAUTHENTICATED
                                   // callbacks from triggering expireSession() post-logout
    await authRepository.signOut();
  }
}
