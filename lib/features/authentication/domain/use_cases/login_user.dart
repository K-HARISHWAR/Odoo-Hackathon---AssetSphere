import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<AuthenticatedUser> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
