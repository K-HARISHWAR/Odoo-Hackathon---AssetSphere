import 'package:assetsphere/features/organization/domain/entities/department.dart';
import 'package:assetsphere/features/organization/domain/entities/asset_category.dart';
import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

abstract class OrganizationRepository {
  Future<List<Department>> getDepartments();

  Future<Department> createDepartment({
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  });

  Future<Department> updateDepartment({
    required String id,
    required String name,
    required String code,
    String? parentDepartmentId,
    String? departmentHeadId,
    required RecordStatus status,
  });

  Future<Department> updateDepartmentStatus({
    required String id,
    required RecordStatus status,
  });

  Future<List<AssetCategory>> getAssetCategories();

  Future<AssetCategory> createAssetCategory({
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  });

  Future<AssetCategory> updateAssetCategory({
    required String id,
    required String name,
    required String description,
    int? warrantyPeriodMonths,
    String? customFieldDescription,
    required RecordStatus status,
  });

  Future<AssetCategory> updateAssetCategoryStatus({
    required String id,
    required RecordStatus status,
  });

  Future<List<Employee>> getEmployees();

  Future<Employee> updateEmployeeRole({
    required String id,
    required EmployeeRole newRole,
  });

  Future<Employee> updateEmployeeDepartment({
    required String id,
    required String newDepartmentId,
  });

  Future<Employee> updateEmployeeStatus({
    required String id,
    required RecordStatus status,
  });
}
