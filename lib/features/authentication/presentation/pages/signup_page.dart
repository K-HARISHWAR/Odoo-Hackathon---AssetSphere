import 'package:flutter/material.dart';
import 'package:assetsphere/core/constants/app_strings.dart';
import 'package:assetsphere/features/authentication/domain/entities/authenticated_user.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_form_container.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_header.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/password_field.dart';

class SignupPage extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onBackToLogin;
  final ValueChanged<AuthenticatedUser>? onSignupSuccess;

  const SignupPage({
    super.key,
    required this.controller,
    this.onBackToLogin,
    this.onSignupSuccess,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedDepartment;

  final List<String> _departments = [
    'Information Technology',
    'Human Resources',
    'Finance',
    'Operations',
    'Administration',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await widget.controller.signupEmployee(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      departmentName: _selectedDepartment!,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.controller.successMessage ?? 'Account created!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
      if (widget.onSignupSuccess != null &&
          widget.controller.currentUser != null) {
        widget.onSignupSuccess!(widget.controller.currentUser!);
      }
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
                      title: 'Create Account',
                      subtitle: AppStrings.appDescription,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'All new accounts are created as Employee accounts. Roles are assigned by an administrator.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      label: 'Full Name',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Full name must contain at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        items: _departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          );
                        }).toList(),
                        onChanged: widget.controller.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedDepartment = value;
                                });
                              },
                        validator: (value) =>
                            value == null ? 'Department is required' : null,
                      ),
                    ),
                    PasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: widget.controller.obscureSignupPassword,
                      onToggleVisibility:
                          widget.controller.toggleSignupPasswordVisibility,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must contain at least 8 characters';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Password must contain at least one lowercase letter';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain at least one number';
                        }
                        return null;
                      },
                    ),
                    PasswordField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      obscureText: widget.controller.obscureConfirmPassword,
                      onToggleVisibility:
                          widget.controller.toggleConfirmPasswordVisibility,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password is required';
                        }
                        if (value != _passwordController.text) {
                          return 'Confirm password must match password';
                        }
                        return null;
                      },
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
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: widget.controller.isLoading
                              ? null
                              : widget.onBackToLogin,
                          child: const Text('Log In'),
                        ),
                      ],
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
