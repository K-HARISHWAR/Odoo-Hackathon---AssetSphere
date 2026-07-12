enum EmployeeRole { employee, departmentHead, assetManager, admin }

extension EmployeeRoleX on EmployeeRole {
  String get displayName {
    switch (this) {
      case EmployeeRole.employee:
        return 'Employee';
      case EmployeeRole.departmentHead:
        return 'Department Head';
      case EmployeeRole.assetManager:
        return 'Asset Manager';
      case EmployeeRole.admin:
        return 'System Admin';
    }
  }
}
