import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';

class AuthenticatedUserModel extends AuthenticatedUser {
  const AuthenticatedUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    required super.departmentName,
    required super.isActive,
  });

  factory AuthenticatedUserModel.fromEntity(AuthenticatedUser user) {
    return AuthenticatedUserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      departmentName: user.departmentName,
      isActive: user.isActive,
    );
  }

  AuthenticatedUser toEntity() {
    return AuthenticatedUser(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      departmentName: departmentName,
      isActive: isActive,
    );
  }
}
