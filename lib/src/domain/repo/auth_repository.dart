import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<void> loginWithEmail(String email, String password);
  Future<UserEntity> getProfile();
  Future<UserEntity> validateAppAccess();
  Future<void> signOut();
}
