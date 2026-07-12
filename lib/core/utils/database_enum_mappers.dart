import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/organization/domain/entities/employee_role.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';
import 'package:assetsphere/features/assets/domain/entities/asset_status.dart';
import 'package:assetsphere/features/assets/domain/entities/asset_condition.dart';

class DatabaseEnumMappers {
  static AssetCondition assetConditionFromDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return AssetCondition.newCondition;
      case 'good':
        return AssetCondition.good;
      case 'fair':
        return AssetCondition.fair;
      case 'damaged':
        return AssetCondition.damaged;
      case 'unusable':
        return AssetCondition.unusable;
      default:
        throw FormatException('Unknown AssetCondition database value: $value');
    }
  }

  static String assetConditionToDatabase(AssetCondition value) {
    switch (value) {
      case AssetCondition.newCondition:
        return 'new';
      case AssetCondition.good:
        return 'good';
      case AssetCondition.fair:
        return 'fair';
      case AssetCondition.damaged:
        return 'damaged';
      case AssetCondition.unusable:
        return 'unusable';
    }
  }

  static AssetStatus assetStatusFromDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return AssetStatus.available;
      case 'allocated':
        return AssetStatus.allocated;
      case 'reserved':
        return AssetStatus.reserved;
      case 'under_maintenance':
        return AssetStatus.maintenance;
      case 'lost':
        return AssetStatus.lost;
      case 'retired':
        return AssetStatus.retired;
      case 'disposed':
        return AssetStatus.disposed;
      default:
        throw FormatException('Unknown AssetStatus database value: $value');
    }
  }

  static String assetStatusToDatabase(AssetStatus value) {
    switch (value) {
      case AssetStatus.available:
        return 'available';
      case AssetStatus.allocated:
        return 'allocated';
      case AssetStatus.reserved:
        return 'reserved';
      case AssetStatus.maintenance:
        return 'under_maintenance';
      case AssetStatus.lost:
        return 'lost';
      case AssetStatus.retired:
        return 'retired';
      case AssetStatus.disposed:
        return 'disposed';
    }
  }

  static EmployeeRole employeeRoleFromDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'employee':
        return EmployeeRole.employee;
      case 'department_head':
        return EmployeeRole.departmentHead;
      case 'asset_manager':
        return EmployeeRole.assetManager;
      case 'admin':
        return EmployeeRole.admin;
      default:
        throw FormatException('Unknown EmployeeRole database value: $value');
    }
  }

  static String employeeRoleToDatabase(EmployeeRole value) {
    switch (value) {
      case EmployeeRole.employee:
        return 'employee';
      case EmployeeRole.departmentHead:
        return 'department_head';
      case EmployeeRole.assetManager:
        return 'asset_manager';
      case EmployeeRole.admin:
        return 'admin';
    }
  }

  static AuthRole authRoleFromDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'employee':
        return AuthRole.employee;
      case 'department_head':
        return AuthRole.departmentHead;
      case 'asset_manager':
        return AuthRole.assetManager;
      case 'admin':
        return AuthRole.admin;
      default:
        throw FormatException('Unknown AuthRole database value: $value');
    }
  }

  static String authRoleToDatabase(AuthRole value) {
    switch (value) {
      case AuthRole.employee:
        return 'employee';
      case AuthRole.departmentHead:
        return 'department_head';
      case AuthRole.assetManager:
        return 'asset_manager';
      case AuthRole.admin:
        return 'admin';
    }
  }

  static RecordStatus recordStatusFromDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return RecordStatus.active;
      case 'inactive':
        return RecordStatus.inactive;
      default:
        throw FormatException('Unknown RecordStatus database value: $value');
    }
  }

  static String recordStatusToDatabase(RecordStatus value) {
    switch (value) {
      case RecordStatus.active:
        return 'active';
      case RecordStatus.inactive:
        return 'inactive';
    }
  }
}
