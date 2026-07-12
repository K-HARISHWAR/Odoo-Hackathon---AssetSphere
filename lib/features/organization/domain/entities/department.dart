import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class Department {
  final String id;
  final String name;
  final String code;
  final String? parentDepartmentId;
  final String? parentDepartmentName;
  final String? departmentHeadId;
  final String? departmentHeadName;
  final RecordStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Department({
    required this.id,
    required this.name,
    required this.code,
    this.parentDepartmentId,
    this.parentDepartmentName,
    this.departmentHeadId,
    this.departmentHeadName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
