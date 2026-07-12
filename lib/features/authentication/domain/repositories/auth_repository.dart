import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';

abstract class AuthRepository {
  Future<AuthenticatedUser> login({
    required String email,
    required String password,
  });

  Future<AuthenticatedUser> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> logout();
  Future<AuthenticatedUser?> restoreSession();
}
