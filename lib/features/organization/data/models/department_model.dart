import 'package:assetsphere/features/organization/domain/entities/department.dart';

class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.name,
    required super.code,
    super.parentDepartmentId,
    super.parentDepartmentName,
    super.departmentHeadId,
    super.departmentHeadName,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DepartmentModel.fromEntity(Department entity) {
    return DepartmentModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      parentDepartmentId: entity.parentDepartmentId,
      parentDepartmentName: entity.parentDepartmentName,
      departmentHeadId: entity.departmentHeadId,
      departmentHeadName: entity.departmentHeadName,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Department toEntity() {
    return Department(
      id: id,
      name: name,
      code: code,
      parentDepartmentId: parentDepartmentId,
      parentDepartmentName: parentDepartmentName,
      departmentHeadId: departmentHeadId,
      departmentHeadName: departmentHeadName,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
