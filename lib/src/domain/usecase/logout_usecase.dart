import '../repo/auth_repository.dart';
import '../../service_core/auth/session_manager.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  final SessionManager sessionManager;

  LogoutUseCase({required this.authRepository, required this.sessionManager});

  Future<void> execute() async {
    sessionManager.clearUser();
    await authRepository.signOut();
  }
}
