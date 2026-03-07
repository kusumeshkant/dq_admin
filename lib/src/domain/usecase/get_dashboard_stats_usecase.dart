import '../entity/dashboard_entity.dart';
import '../repo/admin_repository.dart';

class GetDashboardStatsUseCase {
  final AdminRepository repo;
  GetDashboardStatsUseCase(this.repo);

  Future<DashboardStatsEntity> execute() => repo.getDashboardStats();
}
