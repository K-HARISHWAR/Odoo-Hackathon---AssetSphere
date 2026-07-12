import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class UpdateEmployeeDepartment {
  final OrganizationRepository repository;

  UpdateEmployeeDepartment(this.repository);

  Future<Employee> call({required String id, required String newDepartmentId}) {
    return repository.updateEmployeeDepartment(
      id: id,
      newDepartmentId: newDepartmentId,
    );
  }
}
