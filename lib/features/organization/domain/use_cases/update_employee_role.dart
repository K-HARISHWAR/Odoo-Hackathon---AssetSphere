import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class UpdateEmployeeRole {
  final OrganizationRepository repository;

  UpdateEmployeeRole(this.repository);

  Future<Employee> call({required String id, required EmployeeRole newRole}) {
    return repository.updateEmployeeRole(id: id, newRole: newRole);
  }
}
