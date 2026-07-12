import 'package:flutter_test/flutter_test.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/login_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/signup_employee.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/request_password_reset.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';

class FakeAuthRepo implements AuthRepository {
  bool shouldThrow = false;

  @override
  Future<AuthenticatedUser> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Invalid credentials');
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
    if (shouldThrow) throw Exception('Email not found');
  }

  @override
  Future<AuthenticatedUser> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    if (shouldThrow) throw Exception('Email exists');
    return const AuthenticatedUser(
      id: '2',
      fullName: 'New User',
      email: 'new@example.com',
      role: AuthRole.employee,
      departmentName: 'HR',
      isActive: true,
    );
  }
}

void main() {
  group('AuthController', () {
    late AuthController controller;
    late FakeAuthRepo repository;

    setUp(() {
      repository = FakeAuthRepo();
      controller = AuthController(
        loginUser: LoginUser(repository),
        signupEmployee: SignupEmployee(repository),
        requestPasswordReset: RequestPasswordReset(repository),
        repository: repository,
      );
    });

    test('Initial state is correct', () {
      expect(controller.isLoading, isFalse);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.obscureLoginPassword, isTrue);
    });

    test('Login updates state on success', () async {
      final success = await controller.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(success, isTrue);
      expect(controller.currentUser, isNotNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('Login updates state on failure', () async {
      repository.shouldThrow = true;
      final success = await controller.login(
        email: 'test@example.com',
        password: 'password',
      );

      expect(success, isFalse);
      expect(controller.currentUser, isNull);
      expect(controller.errorMessage, 'Invalid credentials');
      expect(controller.isLoading, isFalse);
    });

    test('Toggle password visibility', () {
      expect(controller.obscureLoginPassword, isTrue);
      controller.toggleLoginPasswordVisibility();
      expect(controller.obscureLoginPassword, isFalse);
    });
  });
}
