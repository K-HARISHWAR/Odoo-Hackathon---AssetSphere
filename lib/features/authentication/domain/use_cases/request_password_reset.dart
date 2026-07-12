import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class RequestPasswordReset {
  final AuthRepository repository;

  RequestPasswordReset(this.repository);

  Future<void> call({required String email}) {
    return repository.requestPasswordReset(email: email);
  }
}
