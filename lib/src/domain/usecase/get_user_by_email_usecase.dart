import '../entity/user_entity.dart';
import '../repo/staff_repository.dart';

class GetUserByEmailUseCase {
  final StaffRepository repo;
  GetUserByEmailUseCase(this.repo);

  Future<UserEntity?> execute(String email) => repo.getUserByEmail(email);
}
