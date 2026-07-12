import '../models/dashboard_kpi_model.dart';
import '../../domain/entities/recent_activity.dart';

abstract class DashboardDataSource {
  Future<List<DashboardKPIModel>> getKPIs();
  Future<List<RecentActivity>> getRecentActivities();
  Future<Map<String, int>> getAssetStatusSummary();
}

class DashboardMockDataSource implements DashboardDataSource {
  @override
  Future<List<DashboardKPIModel>> getKPIs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const DashboardKPIModel(title: 'Available Assets', value: '45'),
      const DashboardKPIModel(title: 'Allocated Assets', value: '128'),
      const DashboardKPIModel(title: 'Under Maintenance', value: '12'),
      const DashboardKPIModel(title: 'Pending Transfers', value: '5'),
      const DashboardKPIModel(title: 'Upcoming Returns', value: '8'),
      const DashboardKPIModel(title: 'Active Bookings', value: '3'),
    ];
  }

  @override
  Future<List<RecentActivity>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      RecentActivity(
        id: '1',
        title: 'New Assignment',
        description: 'MacBook Pro assigned to John Doe',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: ActivityType.allocation,
      ),
      RecentActivity(
        id: '2',
        title: 'Maintenance Request',
        description: 'Dell XPS sent for maintenance',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: ActivityType.maintenance,
      ),
    ];
  }

  @override
  Future<Map<String, int>> getAssetStatusSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'Available': 45,
      'Allocated': 128,
      'Maintenance': 12,
      'Lost': 2,
      'Retired': 15,
    };
  }
}
