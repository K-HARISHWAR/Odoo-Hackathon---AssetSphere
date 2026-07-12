import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class GetEmployees {
  final OrganizationRepository repository;

  GetEmployees(this.repository);

  Future<List<Employee>> call() {
    return repository.getEmployees();
  }
}
