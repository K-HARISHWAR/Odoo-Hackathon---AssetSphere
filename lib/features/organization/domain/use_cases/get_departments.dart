import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class GetDepartments {
  final OrganizationRepository repository;

  GetDepartments(this.repository);

  Future<List<Department>> call() {
    return repository.getDepartments();
  }
}
