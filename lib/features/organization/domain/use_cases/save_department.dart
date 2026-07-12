import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class SaveDepartment {
  final OrganizationRepository repository;

  SaveDepartment(this.repository);

  Future<Department> call({
    String? id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) {
    if (id == null) {
      return repository.createDepartment(
        name: name,
        code: code,
        parentDepartmentId: parentDepartmentId,
        departmentHeadId: departmentHeadId,
        status: status,
      );
    } else {
      return repository.updateDepartment(
        id: id,
        name: name,
        code: code,
        parentDepartmentId: parentDepartmentId,
        departmentHeadId: departmentHeadId,
        status: status,
      );
    }
  }
}
