import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:assetsphere/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:assetsphere/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:assetsphere/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';

void main() {
  late DashboardController controller;
  late DashboardRepositoryImpl repository;

  setUp(() {
    final dataSource = DashboardMockDataSource();
    repository = DashboardRepositoryImpl(dataSource: dataSource);
    final getDashboardDataUseCase = GetDashboardDataUseCase(repository);
    controller = DashboardController(getDashboardData: getDashboardDataUseCase);
  });

  test('should load dashboard data correctly', () async {
    await controller.loadDashboardData();

    expect(controller.kpis, isNotEmpty);
    expect(controller.activities, isNotEmpty);
    expect(controller.statusSummary, isNotEmpty);
    expect(controller.isLoading, false);
    expect(controller.error, isNull);
  });
}
