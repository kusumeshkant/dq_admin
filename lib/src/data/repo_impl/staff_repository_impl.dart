import '../../core/pagination/page_result.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/staff_repository.dart';
import '../datasources/remote/staff_remote_ds.dart';
import '../model/user_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDs ds;
  StaffRepositoryImpl(this.ds);

  @override
  Future<List<UserEntity>> getAllStaff() async {
    final list = await ds.getAllStaff();
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  @override
  Future<PageResult<UserEntity>> getStaffPage(PageParams params) async {
    final data = await ds.fetchStaffPage(params);
    final meta = data['meta'] as Map<String, dynamic>;
    return PageResult<UserEntity>(
      items: (data['items'] as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
      hasNext: meta['hasNext'] as bool,
      nextCursor: meta['nextCursor'] as String?,
      totalCount: meta['totalCount'] as int?,
    );
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    final json = await ds.getUserByEmail(email);
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  @override
  Future<UserEntity> updateUserRole({required String userId, required String role, String? storeId}) async {
    final json = await ds.updateUserRole(userId: userId, role: role, storeId: storeId);
    return UserModel.fromJson(json);
  }
}
