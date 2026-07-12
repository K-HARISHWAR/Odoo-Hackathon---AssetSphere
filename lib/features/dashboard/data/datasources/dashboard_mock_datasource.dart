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
      const DashboardKPIModel(title: 'Available Assets', value: '0'),
      const DashboardKPIModel(title: 'Allocated Assets', value: '0'),
      const DashboardKPIModel(title: 'Under Maintenance', value: '0'),
      const DashboardKPIModel(title: 'Pending Transfers', value: '0'),
      const DashboardKPIModel(title: 'Upcoming Returns', value: '0'),
      const DashboardKPIModel(title: 'Active Bookings', value: '0'),
    ];
  }

  @override
  Future<List<RecentActivity>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  @override
  Future<Map<String, int>> getAssetStatusSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'Available': 0,
      'Allocated': 0,
      'Maintenance': 0,
      'Lost': 0,
      'Retired': 0,
    };
  }
}
