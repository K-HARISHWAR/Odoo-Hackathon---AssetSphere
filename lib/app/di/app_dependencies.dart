import 'package:assetsphere/features/authentication/data/repositories/supabase_auth_repository_impl.dart';
import 'package:assetsphere/features/authentication/data/data_sources/mock_auth_data_source.dart';
import 'package:assetsphere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/login_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/signup_employee.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/request_password_reset.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';

import 'package:assetsphere/features/organization/data/repositories/supabase_organization_repository_impl.dart';
import 'package:assetsphere/features/organization/data/data_sources/mock_organization_data_source.dart';
import 'package:assetsphere/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_departments.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_asset_categories.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_asset_category.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_employees.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_role.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

import 'package:assetsphere/features/dashboard/data/repositories/supabase_dashboard_repository_impl.dart';
import 'package:assetsphere/features/dashboard/data/datasources/dashboard_mock_datasource.dart';
import 'package:assetsphere/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:assetsphere/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:assetsphere/features/dashboard/presentation/controllers/dashboard_controller.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assetsphere/features/assets/data/datasources/assets_mock_datasource.dart';
import 'package:assetsphere/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:assetsphere/features/assets/data/repositories/supabase_asset_repository_impl.dart';
import 'package:assetsphere/features/assets/domain/repositories/asset_repository.dart';
import 'package:assetsphere/features/assets/domain/usecases/get_assets_usecase.dart';
import 'package:assetsphere/features/assets/presentation/controllers/asset_directory_controller.dart';

class AppDependencies {
  final AuthController authController;
  final OrganizationController organizationController;
  final DashboardController dashboardController;
  final AssetDirectoryController assetDirectoryController;
  final AssetRepository assetRepository;

  AppDependencies({
    required this.authController,
    required this.organizationController,
    required this.dashboardController,
    required this.assetDirectoryController,
    required this.assetRepository,
  });

  factory AppDependencies.create() {
    return AppDependencies.test();
  }

  factory AppDependencies.test() {
    // Auth Dependencies
    final authDataSource = MockAuthDataSource();
    final authRepository = AuthRepositoryImpl(authDataSource);
    final authController = AuthController(
      loginUser: LoginUser(authRepository),
      signupEmployee: SignupEmployee(authRepository),
      requestPasswordReset: RequestPasswordReset(authRepository),
      repository: authRepository,
    );

    // Organization Dependencies
    final organizationDataSource = MockOrganizationDataSource();
    final organizationRepository = OrganizationRepositoryImpl(
      organizationDataSource,
    );
    final organizationController = OrganizationController(
      getDepartments: GetDepartments(organizationRepository),
      saveDepartment: SaveDepartment(organizationRepository),
      getAssetCategories: GetAssetCategories(organizationRepository),
      saveAssetCategory: SaveAssetCategory(organizationRepository),
      getEmployees: GetEmployees(organizationRepository),
      updateEmployeeRole: UpdateEmployeeRole(organizationRepository),
      updateEmployeeDepartment: UpdateEmployeeDepartment(
        organizationRepository,
      ),
      updateEmployeeStatus: UpdateEmployeeStatus(organizationRepository),
    );

    // Dashboard Dependencies
    final dashboardDataSource = DashboardMockDataSource();
    final dashboardRepository = DashboardRepositoryImpl(
      dataSource: dashboardDataSource,
    );
    final dashboardController = DashboardController(
      getDashboardData: GetDashboardDataUseCase(dashboardRepository),
    );

    // Asset Dependencies
    final assetDataSource = AssetsMockDataSource();
    final assetRepository = AssetRepositoryImpl(dataSource: assetDataSource);
    final assetDirectoryController = AssetDirectoryController(
      getAssets: GetAssetsUseCase(assetRepository),
    );

    return AppDependencies(
      authController: authController,
      organizationController: organizationController,
      dashboardController: dashboardController,
      assetDirectoryController: assetDirectoryController,
      assetRepository: assetRepository,
    );
  }

  factory AppDependencies.production(SupabaseClient client) {
    // Auth Dependencies
    final authRepository = SupabaseAuthRepositoryImpl(supabaseClient: client);
    final authController = AuthController(
      loginUser: LoginUser(authRepository),
      signupEmployee: SignupEmployee(authRepository),
      requestPasswordReset: RequestPasswordReset(authRepository),
      repository: authRepository,
    );

    // Organization Dependencies
    final organizationRepository = SupabaseOrganizationRepositoryImpl(
      supabaseClient: client,
    );
    final organizationController = OrganizationController(
      getDepartments: GetDepartments(organizationRepository),
      saveDepartment: SaveDepartment(organizationRepository),
      getAssetCategories: GetAssetCategories(organizationRepository),
      saveAssetCategory: SaveAssetCategory(organizationRepository),
      getEmployees: GetEmployees(organizationRepository),
      updateEmployeeRole: UpdateEmployeeRole(organizationRepository),
      updateEmployeeDepartment: UpdateEmployeeDepartment(
        organizationRepository,
      ),
      updateEmployeeStatus: UpdateEmployeeStatus(organizationRepository),
    );

    // Dashboard Dependencies
    final dashboardRepository = SupabaseDashboardRepositoryImpl(
      supabaseClient: client,
    );
    final dashboardController = DashboardController(
      getDashboardData: GetDashboardDataUseCase(dashboardRepository),
    );

    // Asset Dependencies
    final assetRepository = SupabaseAssetRepositoryImpl(supabaseClient: client);
    final assetDirectoryController = AssetDirectoryController(
      getAssets: GetAssetsUseCase(assetRepository),
    );

    return AppDependencies(
      authController: authController,
      organizationController: organizationController,
      dashboardController: dashboardController,
      assetDirectoryController: assetDirectoryController,
      assetRepository: assetRepository,
    );
  }
}
