import '../entity/user_entity.dart';
import '../repo/admin_repository.dart';

class GetUserByEmailUseCase {
  final AdminRepository repo;
  GetUserByEmailUseCase(this.repo);

  Future<UserEntity?> execute(String email) => repo.getUserByEmail(email);
}
