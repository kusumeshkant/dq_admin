import '../entity/user_entity.dart';

abstract class StaffRepository {
  Future<List<UserEntity>> getAllStaff();
  Future<UserEntity?> getUserByEmail(String email);
  Future<UserEntity> updateUserRole({required String userId, required String role, String? storeId});
}
