import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class UpdateEmployeeStatus {
  final OrganizationRepository repository;

  UpdateEmployeeStatus(this.repository);

  Future<Employee> call({required String id, required RecordStatus status}) {
    return repository.updateEmployeeStatus(id: id, status: status);
  }
}
