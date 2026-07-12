import 'package:assetsphere/features/authentication/data/data_sources/mock_auth_data_source.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<AuthenticatedUser> login({
    required String email,
    required String password,
  }) async {
    final userModel = await dataSource.login(email: email, password: password);
    return userModel.toEntity();
  }

  @override
  Future<AuthenticatedUser> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    final userModel = await dataSource.signupEmployee(
      fullName: fullName,
      email: email,
      password: password,
      departmentName: departmentName,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return dataSource.requestPasswordReset(email: email);
  }

  @override
  Future<void> logout() async {
    // In a real implementation this might clear secure storage and tokens
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
