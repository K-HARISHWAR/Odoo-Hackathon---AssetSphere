import 'package:assetsphere/features/organization/domain/entities/employee.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.employeeCode,
    required super.fullName,
    required super.email,
    required super.departmentId,
    required super.departmentName,
    required super.role,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmployeeModel.fromEntity(Employee entity) {
    return EmployeeModel(
      id: entity.id,
      employeeCode: entity.employeeCode,
      fullName: entity.fullName,
      email: entity.email,
      departmentId: entity.departmentId,
      departmentName: entity.departmentName,
      role: entity.role,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Employee toEntity() {
    return Employee(
      id: id,
      employeeCode: employeeCode,
      fullName: fullName,
      email: email,
      departmentId: departmentId,
      departmentName: departmentName,
      role: role,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
