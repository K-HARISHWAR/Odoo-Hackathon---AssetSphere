import '../entities/dashboard_kpi.dart';
import '../entities/recent_activity.dart';
import '../repositories/dashboard_repository.dart';

class DashboardData {
  final List<DashboardKPI> kpis;
  final List<RecentActivity> activities;
  final Map<String, int> statusSummary;

  DashboardData({
    required this.kpis,
    required this.activities,
    required this.statusSummary,
  });
}

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<DashboardData> execute() async {
    final results = await Future.wait([
      repository.getKPIs(),
      repository.getRecentActivities(),
      repository.getAssetStatusSummary(),
    ]);

    return DashboardData(
      kpis: results[0] as List<DashboardKPI>,
      activities: results[1] as List<RecentActivity>,
      statusSummary: results[2] as Map<String, int>,
    );
  }
}
