import '../entity/user_entity.dart';
import '../repo/admin_repository.dart';

class UpdateUserRoleUseCase {
  final AdminRepository repo;
  UpdateUserRoleUseCase(this.repo);

  Future<UserEntity> execute({required String userId, required String role, String? storeId}) =>
      repo.updateUserRole(userId: userId, role: role, storeId: storeId);
}
