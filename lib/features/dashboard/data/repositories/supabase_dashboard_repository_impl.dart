import 'package:assetsphere/core/utils/supabase_error_mapper.dart';
import 'package:assetsphere/features/dashboard/domain/entities/dashboard_kpi.dart';
import 'package:assetsphere/features/dashboard/domain/entities/recent_activity.dart';
import 'package:assetsphere/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _supabase;

  SupabaseDashboardRepositoryImpl({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  String _requireUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Authentication missing');
    }
    return user.id;
  }

  @override
  Future<List<DashboardKPI>> getKPIs() async {
    _requireUser();
    try {
      // For KPIs, we can aggregate from dashboard_asset_status_counts
      final countsResponse = await _supabase
          .from('dashboard_asset_status_counts')
          .select('status, count');

      int totalAssets = 0;
      int availableAssets = 0;
      int maintenanceAssets = 0;

      for (final row in (countsResponse as List)) {
        final status = row['status'] as String;
        final count = (row['count'] as num).toInt();
        totalAssets += count;

        if (status == 'available') {
          availableAssets += count;
        } else if (status == 'under_maintenance') {
          maintenanceAssets += count;
        }
      }

      // Overdue allocations from dashboard_overdue_allocations
      final overdueResponse = await _supabase
          .from('dashboard_overdue_allocations')
          .select('allocation_id');
      final overdueCount = (overdueResponse as List).length;

      return [
        DashboardKPI(
          title: 'Total Assets',
          value: totalAssets.toString(),
          subtitle: 'Active in system',
        ),
        DashboardKPI(
          title: 'Available',
          value: availableAssets.toString(),
          subtitle: 'Ready for use',
        ),
        DashboardKPI(
          title: 'In Maintenance',
          value: maintenanceAssets.toString(),
          subtitle: 'Currently being serviced',
        ),
        DashboardKPI(
          title: 'Overdue Returns',
          value: overdueCount.toString(),
          subtitle: 'Need attention',
        ),
      ];
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<List<RecentActivity>> getRecentActivities() async {
    _requireUser();
    try {
      // Activity logs table: public.activity_logs
      final response = await _supabase
          .from('activity_logs')
          .select('id, action, description, created_at, profiles(full_name)')
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List).map((row) {
        final action = row['action'] as String;
        ActivityType type = ActivityType.registration;
        if (action.contains('allocation') || action.contains('allocate')) {
          type = ActivityType.allocation;
        } else if (action.contains('transfer')) {
          type = ActivityType.transfer;
        } else if (action.contains('maintenance')) {
          type = ActivityType.maintenance;
        } else if (action.contains('audit')) {
          type = ActivityType.audit;
        }

        final profile = row['profiles'] != null
            ? row['profiles']['full_name']
            : 'System';

        return RecentActivity(
          id: row['id'] as String,
          title: '$profile - ${_formatAction(action)}',
          description: row['description'] as String,
          timestamp: DateTime.parse(row['created_at']),
          type: type,
        );
      }).toList();
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  @override
  Future<Map<String, int>> getAssetStatusSummary() async {
    _requireUser();
    try {
      final countsResponse = await _supabase
          .from('dashboard_asset_status_counts')
          .select('status, count');

      final Map<String, int> summary = {};
      for (final row in (countsResponse as List)) {
        final status = row['status'] as String;
        final count = (row['count'] as num).toInt();

        // Map db string to readable string
        final readableStatus = status
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
        summary[readableStatus] = count;
      }
      return summary;
    } catch (e) {
      throw Exception(SupabaseErrorMapper.mapError(e));
    }
  }

  String _formatAction(String action) {
    return action
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
