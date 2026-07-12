import 'package:flutter/material.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_form_container.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_header.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/password_field.dart';

class LoginPage extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onForgotPassword;
  final ValueChanged<AuthenticatedUser>? onLoginSuccess;

  const LoginPage({
    super.key,
    required this.controller,
    this.onCreateAccount,
    this.onForgotPassword,
    this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    final success = await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success &&
        widget.onLoginSuccess != null &&
        widget.controller.currentUser != null) {
      widget.onLoginSuccess!(widget.controller.currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            return AuthFormContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      title: 'Welcome Back',
                      subtitle: AppStrings.appDescription,
                    ),
                    const SizedBox(height: 32),
                    if (widget.controller.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Text(
                          widget.controller.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email format';
                        }
                        return null;
                      },
                    ),
                    PasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: widget.controller.obscureLoginPassword,
                      onToggleVisibility:
                          widget.controller.toggleLoginPasswordVisibility,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: widget.controller.rememberMe,
                              onChanged: widget.controller.isLoading
                                  ? null
                                  : (v) => widget.controller.setRememberMe(
                                      v ?? false,
                                    ),
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: widget.controller.isLoading
                              ? null
                              : widget.onForgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: widget.controller.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: widget.controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: widget.controller.isLoading
                              ? null
                              : widget.onCreateAccount,
                          child: const Text('Create employee account'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    // Development only section
                    Text(
                      'Development Use Only: Mock Accounts',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _DevAccountHint(
                      'Admin',
                      'admin@assetsphere.com',
                      'Admin@123',
                    ),
                    _DevAccountHint(
                      'Manager',
                      'manager@assetsphere.com',
                      'Manager@123',
                    ),
                    _DevAccountHint(
                      'Employee',
                      'employee@assetsphere.com',
                      'Employee@123',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DevAccountHint extends StatelessWidget {
  final String role;
  final String email;
  final String pwd;

  const _DevAccountHint(this.role, this.email, this.pwd);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$role: $email / $pwd',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
