import 'package:flutter/foundation.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/recent_activity.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

class DashboardController extends ChangeNotifier {
  final GetDashboardDataUseCase getDashboardData;

  DashboardController({required this.getDashboardData});

  List<DashboardKPI> _kpis = [];
  List<DashboardKPI> get kpis => _kpis;

  List<RecentActivity> _activities = [];
  List<RecentActivity> get activities => _activities;

  Map<String, int> _statusSummary = {};
  Map<String, int> get statusSummary => _statusSummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await getDashboardData.execute();
      _kpis = data.kpis;
      _activities = data.activities;
      _statusSummary = data.statusSummary;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
