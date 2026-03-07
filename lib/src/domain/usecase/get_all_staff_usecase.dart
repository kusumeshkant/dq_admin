import '../entity/user_entity.dart';
import '../repo/admin_repository.dart';

class GetAllStaffUseCase {
  final AdminRepository repo;
  GetAllStaffUseCase(this.repo);

  Future<List<UserEntity>> execute() => repo.getAllStaff();
}
