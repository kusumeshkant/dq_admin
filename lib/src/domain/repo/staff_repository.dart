import '../../core/pagination/page_result.dart';
import '../entity/user_entity.dart';

abstract class StaffRepository {
  Future<List<UserEntity>> getAllStaff();
  Future<PageResult<UserEntity>> getStaffPage(PageParams params);
  Future<UserEntity?> getUserByEmail(String email);
  Future<UserEntity> updateUserRole({required String userId, required String role, String? storeId});
}
