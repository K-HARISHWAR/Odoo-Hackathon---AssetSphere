enum AuthRole { employee, departmentHead, assetManager, admin }

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
