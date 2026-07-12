import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/recent_activity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_mock_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dataSource;

  DashboardRepositoryImpl({required this.dataSource});

  @override
  Future<List<DashboardKPI>> getKPIs() async {
    return await dataSource.getKPIs();
  }

  @override
  Future<List<RecentActivity>> getRecentActivities() async {
    return await dataSource.getRecentActivities();
  }

  @override
  Future<Map<String, int>> getAssetStatusSummary() async {
    return await dataSource.getAssetStatusSummary();
  }
}
