enum AuthRole { employee, departmentHead, assetManager, admin }

extension AuthRoleX on AuthRole {
  String get displayName {
    switch (this) {
      case AuthRole.employee:
        return 'Employee';
      case AuthRole.departmentHead:
        return 'Department Head';
      case AuthRole.assetManager:
        return 'Asset Manager';
      case AuthRole.admin:
        return 'System Admin';
    }
  }
}
class AuthenticatedUser {
  final String id;
  final String fullName;
  final String email;
  final AuthRole role;
  final String departmentName;
  final bool isActive;

  const AuthenticatedUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.departmentName,
    required this.isActive,
  });
}
