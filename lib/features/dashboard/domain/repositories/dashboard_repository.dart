import '../entities/dashboard_kpi.dart';
import '../entities/recent_activity.dart';

abstract class DashboardRepository {
  Future<List<DashboardKPI>> getKPIs();
  Future<List<RecentActivity>> getRecentActivities();
  Future<Map<String, int>> getAssetStatusSummary();
}
