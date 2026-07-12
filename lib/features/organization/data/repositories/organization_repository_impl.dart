import 'package:assetsphere/features/organization/data/data_sources/mock_organization_data_source.dart';
import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/organization/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final MockOrganizationDataSource dataSource;

  OrganizationRepositoryImpl(this.dataSource);

  @override
  Future<List<Department>> getDepartments() async {
    final models = await dataSource.getDepartments();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Department> createDepartment({
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    final model = await dataSource.createDepartment(
      name: name,
      code: code,
      parentDepartmentId: parentDepartmentId,
      departmentHeadId: departmentHeadId,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<Department> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  }) async {
    final model = await dataSource.updateDepartment(
      id: id,
      name: name,
      code: code,
      parentDepartmentId: parentDepartmentId,
      departmentHeadId: departmentHeadId,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<Department> updateDepartmentStatus({
    required String id,
    required RecordStatus status,
  }) async {
    final model = await dataSource.updateDepartmentStatus(
      id: id,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<List<AssetCategory>> getAssetCategories() async {
    final models = await dataSource.getAssetCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AssetCategory> createAssetCategory({
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    final model = await dataSource.createAssetCategory(
      name: name,
      description: description,
      warrantyPeriodMonths: warrantyPeriodMonths,
      customFieldDescription: customFieldDescription,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<AssetCategory> updateAssetCategory({
    required String id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  }) async {
    final model = await dataSource.updateAssetCategory(
      id: id,
      name: name,
      description: description,
      warrantyPeriodMonths: warrantyPeriodMonths,
      customFieldDescription: customFieldDescription,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<AssetCategory> updateAssetCategoryStatus({
    required String id,
    required RecordStatus status,
  }) async {
    final model = await dataSource.updateAssetCategoryStatus(
      id: id,
      status: status,
    );
    return model.toEntity();
  }

  @override
  Future<List<Employee>> getEmployees() async {
    final models = await dataSource.getEmployees();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Employee> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  }) async {
    final model = await dataSource.updateEmployeeRole(id: id, newRole: newRole);
    return model.toEntity();
  }

  @override
  Future<Employee> updateEmployeeDepartment({
    required String id,
    required String newDepartmentId,
  }) async {
    final model = await dataSource.updateEmployeeDepartment(
      id: id,
      newDepartmentId: newDepartmentId,
    );
    return model.toEntity();
  }

  @override
  Future<Employee> updateEmployeeStatus({
    required String id,
    required RecordStatus status,
  }) async {
    final model = await dataSource.updateEmployeeStatus(id: id, status: status);
    return model.toEntity();
  }
}
