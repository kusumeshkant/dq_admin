import '../entity/user_entity.dart';
import '../repo/staff_repository.dart';

class UpdateUserRoleUseCase {
  final StaffRepository repo;
  UpdateUserRoleUseCase(this.repo);

  Future<UserEntity> execute({required String userId, required String role, String? storeId}) =>
      repo.updateUserRole(userId: userId, role: role, storeId: storeId);
}
