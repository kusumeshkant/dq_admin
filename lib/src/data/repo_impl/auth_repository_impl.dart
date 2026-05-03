import '../../domain/entity/user_entity.dart';
import '../../domain/repo/auth_repository.dart';
import '../../service_core/networks/graphql_client_provider.dart';
import '../datasources/remote/auth_remote_ds.dart';
import '../model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDs ds;
  AuthRepositoryImpl(this.ds);

  @override
  Future<void> loginWithEmail(String email, String password) =>
      ds.loginWithEmail(email, password);

  @override
  Future<UserEntity> getProfile() async {
    final json = await ds.getProfile();
    return UserModel.fromJson(json);
  }

  @override
  Future<UserEntity> validateAppAccess() async {
    final json = await ds.validateAppAccess();
    return UserModel.fromJson(json);
  }

  @override
  Future<void> signOut() async {
    GraphQLClientProvider.reset();
    await ds.signOut();
  }
}
