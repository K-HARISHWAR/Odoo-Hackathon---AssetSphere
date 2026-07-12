import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_asset_categories.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_departments.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_employees.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_asset_category.dart';
import 'package:assetsphere/features/organization/domain/use_cases/save_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_department.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_role.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_status.dart';
import 'package:assetsphere/features/organization/presentation/providers/organization_controller.dart';

class FakeOrgRepo implements OrganizationRepository {
  @override
  Future<List<Employee>> getEmployees() async {
    return [
      Employee(
        id: '1',
        employeeCode: 'EMP1',
        fullName: 'Test User',
        email: 'test@example.com',
        departmentId: 'd1',
        departmentName: 'IT',
        role: EmployeeRole.employee,
        status: RecordStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Provide other minimum stubs
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getDepartments) return Future<List<Department>>.value([]);
    if (invocation.memberName == #getAssetCategories) return Future<List<AssetCategory>>.value([]);
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('OrganizationController', () {
    late OrganizationController controller;
    late FakeOrgRepo repository;

    setUp(() {
      repository = FakeOrgRepo();
      controller = OrganizationController(
        getDepartments: GetDepartments(repository),
        saveDepartment: SaveDepartment(repository),
        getAssetCategories: GetAssetCategories(repository),
        saveAssetCategory: SaveAssetCategory(repository),
        getEmployees: GetEmployees(repository),
        updateEmployeeRole: UpdateEmployeeRole(repository),
        updateEmployeeDepartment: UpdateEmployeeDepartment(repository),
        updateEmployeeStatus: UpdateEmployeeStatus(repository),
      );
    });

    test('Initial state is correct', () {
      expect(controller.isLoading, isFalse);
      expect(controller.departments, isEmpty);
      expect(controller.employees, isEmpty);
      expect(controller.selectedTabIndex, 0);
    });

    test('Initialize loads all data', () async {
      await controller.initialize();

      expect(controller.employees.length, 1);
      expect(controller.filteredEmployees.length, 1);
      expect(controller.isLoading, isFalse);
    });

    test('Set tab index updates state', () {
      controller.setTabIndex(2);
      expect(controller.selectedTabIndex, 2);
    });
  });
}
