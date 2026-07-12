import 'dart:math';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/data/models/authenticated_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Note: These plain-text mock passwords are for local development only
// and must not be used in production.
class MockAuthDataSource {
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'fullName': 'Admin User',
      'email': 'admin@assetsphere.com',
      'password': 'Admin@123',
      'role': AuthRole.admin,
      'departmentName': 'Administration',
      'isActive': true,
    },
    {
      'id': '2',
      'fullName': 'Manager User',
      'email': 'manager@assetsphere.com',
      'password': 'Manager@123',
      'role': AuthRole.assetManager,
      'departmentName': 'Operations',
      'isActive': true,
    },
    {
      'id': '3',
      'fullName': 'Employee User',
      'email': 'employee@assetsphere.com',
      'password': 'Employee@123',
      'role': AuthRole.employee,
      'departmentName': 'Information Technology',
      'isActive': true,
    },
    {
      'id': '4',
      'fullName': 'Inactive User',
      'email': 'inactive@assetsphere.com',
      'password': 'Inactive@123',
      'role': AuthRole.employee,
      'departmentName': 'Human Resources',
      'isActive': false,
    },
  ];

  Future<void> _simulateDelay() async {
    final random = Random();
    final delay = 400 + random.nextInt(401); // 400 to 800 ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> logout() async {
    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<AuthenticatedUser?> restoreSession() async {
    return null;
  }

  Future<AuthenticatedUserModel> login({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    final normalizedEmail = email.trim().toLowerCase();

    final userMap = _mockUsers.cast<Map<String, dynamic>?>().firstWhere(
      (user) => user?['email']?.toString().toLowerCase() == normalizedEmail,
      orElse: () => null,
    );

    if (userMap == null) {
      throw Exception('Invalid email or password.');
    }

    if (userMap['password'] != password) {
      throw Exception('Invalid email or password.');
    }

    if (userMap['isActive'] != true) {
      throw Exception(
        'Account is inactive. Please contact your administrator.',
      );
    }

    try {
      // Attempt to sign in to Supabase so that repositories depending on auth work.
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      try {
        // If login fails, try signing them up automatically.
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': userMap['fullName']},
        );
      } catch (_) {
        // Ignore errors, maybe they are already signed up but invalid password in mock.
      }
    }

    return AuthenticatedUserModel(
      id: userMap['id'],
      fullName: userMap['fullName'],
      email: userMap['email'],
      role: userMap['role'],
      departmentName: userMap['departmentName'],
      isActive: userMap['isActive'],
    );
  }

  Future<AuthenticatedUserModel> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    await _simulateDelay();

    final normalizedEmail = email.trim().toLowerCase();

    final exists = _mockUsers.any(
      (user) => user['email'].toString().toLowerCase() == normalizedEmail,
    );

    if (exists) {
      throw Exception('An account with this email already exists.');
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fullName': fullName.trim(),
      'email': normalizedEmail,
      'password': password,
      'role': AuthRole.employee, // Security requirement: Always employee
      'departmentName': departmentName.trim(),
      'isActive': true,
    };

    _mockUsers.add(newUser);

    return AuthenticatedUserModel(
      id: newUser['id'] as String,
      fullName: newUser['fullName'] as String,
      email: newUser['email'] as String,
      role: newUser['role'] as AuthRole,
      departmentName: newUser['departmentName'] as String,
      isActive: newUser['isActive'] as bool,
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _simulateDelay();

    final normalizedEmail = email.trim().toLowerCase();

    final exists = _mockUsers.any(
      (user) => user['email'].toString().toLowerCase() == normalizedEmail,
    );

    if (!exists) {
      throw Exception('No account found with this email address.');
    }

    // Simulate successful password reset email dispatch
  }
}
