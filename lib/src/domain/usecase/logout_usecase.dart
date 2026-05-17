import 'package:get/get.dart';
import '../repo/auth_repository.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/networks/graphql_client_provider.dart';
import '../../service_core/subscription/subscription_manager.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  final SessionManager sessionManager;

  LogoutUseCase({required this.authRepository, required this.sessionManager});

  Future<void> execute() async {
    await sessionManager.clearCache(); // clear offline profile before signout
    sessionManager.clearUser();
    Get.find<SubscriptionManager>().clear(); // clear cached subscription data
    GraphQLClientProvider.reset(); // drop client before signout to prevent UNAUTHENTICATED
                                   // callbacks from triggering expireSession() post-logout
    await authRepository.signOut();
  }
}
