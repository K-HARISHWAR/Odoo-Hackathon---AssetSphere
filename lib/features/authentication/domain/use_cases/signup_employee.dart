import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class SignupEmployee {
  final AuthRepository repository;

  SignupEmployee(this.repository);

  Future<AuthenticatedUser> call({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) {
    // Note: The use case inherently prevents passing a role parameter,
    // guaranteeing all signups created this way are employees.
    return repository.signupEmployee(
      fullName: fullName,
      email: email,
      password: password,
      departmentName: departmentName,
    );
  }
}
