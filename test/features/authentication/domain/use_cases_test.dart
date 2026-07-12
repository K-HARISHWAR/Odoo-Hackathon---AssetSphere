import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/login_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/signup_employee.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/request_password_reset.dart';

class MockAuthRepo implements AuthRepository {
  bool loginCalled = false;
  bool signupCalled = false;
  bool resetCalled = false;

  @override
  Future<AuthenticatedUser> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    return const AuthenticatedUser(
      id: '1',
      fullName: 'Test User',
      email: 'test@example.com',
      role: AuthRole.employee,
      departmentName: 'IT',
      isActive: true,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {
    resetCalled = true;
  }

  @override
  Future<AuthenticatedUser> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    signupCalled = true;
    return const AuthenticatedUser(
      id: '2',
      fullName: 'New User',
      email: 'new@example.com',
      role: AuthRole.employee, // Ensure signup creates employee
      departmentName: 'HR',
      isActive: true,
    );
  }
}

void main() {
  group('Authentication Use Cases', () {
    late MockAuthRepo repository;

    setUp(() {
      repository = MockAuthRepo();
    });

    test('LoginUser calls repository', () async {
      final useCase = LoginUser(repository);
      final result = await useCase(
        email: 'test@example.com',
        password: 'password',
      );

      expect(repository.loginCalled, isTrue);
      expect(result.email, 'test@example.com');
    });

    test('SignupEmployee calls repository and returns employee role', () async {
      final useCase = SignupEmployee(repository);
      final result = await useCase(
        fullName: 'New User',
        email: 'new@example.com',
        password: 'password',
        departmentName: 'HR',
      );

      expect(repository.signupCalled, isTrue);
      expect(result.role, AuthRole.employee);
    });

    test('RequestPasswordReset calls repository', () async {
      final useCase = RequestPasswordReset(repository);
      await useCase(email: 'test@example.com');

      expect(repository.resetCalled, isTrue);
    });
  });
}
