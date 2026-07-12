import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class Employee {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String departmentId;
  final String departmentName;
  final EmployeeRole role;
  final RecordStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.departmentId,
    required this.departmentName,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
