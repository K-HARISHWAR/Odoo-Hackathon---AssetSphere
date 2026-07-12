import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';
import 'package:assetsphere/features/organization/domain/use_cases/get_departments.dart';
import 'package:assetsphere/features/organization/domain/use_cases/update_employee_role.dart';

class MockOrgRepo implements OrganizationRepository {
  bool getDepartmentsCalled = false;
  bool updateRoleCalled = false;

  @override
  Future<List<Department>> getDepartments() async {
    getDepartmentsCalled = true;
    return [];
  }

  @override
  Future<Employee> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  }) async {
    updateRoleCalled = true;
    return Employee(
      id: id,
      employeeCode: 'EMP',
      fullName: 'Name',
      email: 'email@test.com',
      departmentId: 'd1',
      departmentName: 'IT',
      role: newRole,
      status: RecordStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Stubs for the rest
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Organization Use Cases', () {
    late MockOrgRepo repository;

    setUp(() {
      repository = MockOrgRepo();
    });

    test('GetDepartments calls repository', () async {
      final useCase = GetDepartments(repository);
      await useCase();
      expect(repository.getDepartmentsCalled, isTrue);
    });

    test(
      'UpdateEmployeeRole calls repository and returns updated role',
      () async {
        final useCase = UpdateEmployeeRole(repository);
        final result = await useCase(id: '1', newRole: EmployeeRole.admin);

        expect(repository.updateRoleCalled, isTrue);
        expect(result.role, EmployeeRole.admin);
      },
    );
  });
}
