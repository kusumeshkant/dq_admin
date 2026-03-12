import '../entity/dashboard_entity.dart';
import '../repo/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repo;
  GetDashboardStatsUseCase(this.repo);

  Future<DashboardStatsEntity> execute() => repo.getDashboardStats();
}
