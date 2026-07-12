import 'package:flutter/foundation.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/login_user.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/signup_employee.dart';
import 'package:assetsphere/features/authentication/domain/use_cases/request_password_reset.dart';
import 'package:assetsphere/features/authentication/domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final LoginUser _loginUser;
  final SignupEmployee _signupEmployee;
  final RequestPasswordReset _requestPasswordReset;
  final AuthRepository _repository;

  AuthController({
    required LoginUser loginUser,
    required SignupEmployee signupEmployee,
    required RequestPasswordReset requestPasswordReset,
    required AuthRepository repository,
  }) : _loginUser = loginUser,
       _signupEmployee = signupEmployee,
       _requestPasswordReset = requestPasswordReset,
       _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthenticatedUser? _currentUser;
  AuthenticatedUser? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  bool _obscureLoginPassword = true;
  bool get obscureLoginPassword => _obscureLoginPassword;

  bool _obscureSignupPassword = true;
  bool get obscureSignupPassword => _obscureSignupPassword;

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    notifyListeners();
  }

  void toggleSignupPasswordVisibility() {
    _obscureSignupPassword = !_obscureSignupPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) return false;

    _setLoading(true);
    clearMessages();

    try {
      final user = await _loginUser(email: email, password: password);
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signupEmployee({
    required String fullName,
    required String email,
    required String password,
    required String departmentName,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    clearMessages();

    try {
      final user = await _signupEmployee(
        fullName: fullName,
        email: email,
        password: password,
        departmentName: departmentName,
      );
      _currentUser = user;
      _successMessage = 'Account created successfully.';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> requestPasswordReset({required String email}) async {
    if (_isLoading) return false;

    _setLoading(true);
    clearMessages();

    try {
      await _requestPasswordReset(email: email);
      _successMessage =
          'Password reset instructions have been sent to your email.';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
      _currentUser = null;
      clearMessages();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _parseErrorMessage(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}
