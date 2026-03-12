import '../entity/user_entity.dart';
import '../repo/staff_repository.dart';

class GetAllStaffUseCase {
  final StaffRepository repo;
  GetAllStaffUseCase(this.repo);

  Future<List<UserEntity>> execute() => repo.getAllStaff();
}
