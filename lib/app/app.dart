import 'package:flutter/material.dart';
import 'package:assetsphere/app/theme/app_theme.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/features/dashboard/presentation/pages/home_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/asset_directory_page.dart';
import 'package:assetsphere/features/assets/presentation/pages/register_asset_page.dart';
import 'package:assetsphere/features/authentication/data/data_sources/mock_auth_data_source.dart';
import 'package:assetsphere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/login_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/signup_employee.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/request_password_reset.dart';
import 'package:assetsphere/features/authentication/presentation/pages/login_page.dart';
import 'package:assetsphere/features/authentication/presentation/pages/signup_page.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/features/organization/presentation/pages/organization_setup_page.dart';
import 'package:assetsphere/features/organization/data/data_sources/mock_organization_data_source.dart';
import 'package:assetsphere/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_asset_categories.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_departments.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_employees.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_asset_category.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_role.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_status.dart';

class AssetSphereApp extends StatefulWidget {
  const AssetSphereApp({super.key});

  @override
  State<AssetSphereApp> createState() => _AssetSphereAppState();
}

class _AssetSphereAppState extends State<AssetSphereApp> {
  late final AuthController _authController;
  late final OrganizationController _orgController;

  @override
  void initState() {
    super.initState();
    // Initialize Auth
    final authDataSource = MockAuthDataSource();
    final authRepository = AuthRepositoryImpl(dataSource: authDataSource);
    _authController = AuthController(
      loginUser: LoginUser(authRepository),
      signupEmployee: SignupEmployee(authRepository),
      requestPasswordReset: RequestPasswordReset(authRepository),
    );

    // Initialize Org
    final orgDataSource = MockOrganizationDataSource();
    final orgRepository = OrganizationRepositoryImpl(dataSource: orgDataSource);
    _orgController = OrganizationController(
      getAssetCategories: GetAssetCategories(orgRepository),
      getDepartments: GetDepartments(orgRepository),
      getEmployees: GetEmployees(orgRepository),
      saveAssetCategory: SaveAssetCategory(orgRepository),
      saveDepartment: SaveDepartment(orgRepository),
      updateEmployeeDepartment: UpdateEmployeeDepartment(orgRepository),
      updateEmployeeRole: UpdateEmployeeRole(orgRepository),
      updateEmployeeStatus: UpdateEmployeeStatus(orgRepository),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _authController,
        builder: (context, _) {
          if (_authController.currentUser == null) {
            return LoginPage(
              controller: _authController,
              onCreateAccount: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupPage(controller: _authController),
                  ),
                );
              },
              onLoginSuccess: (_) {
                // ListenableBuilder will trigger rebuild to HomePage
              },
            );
          }

          return HomePage(
            onRegisterAsset: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterAssetPage(
                    onSuccess: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            onViewDirectory: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssetDirectoryPage(),
                ),
              );
            },
            onBookResource: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizationSetupPage(
                    controller: _orgController,
                  ),
                ),
              );
            },
            onMaintenanceRequest: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Maintenance module will be implemented by Developer 1',
                  ),
                ),
              );
            },
            onSearch: (query) {
              if (query.trim().isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AssetDirectoryPage(initialSearchQuery: query),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
