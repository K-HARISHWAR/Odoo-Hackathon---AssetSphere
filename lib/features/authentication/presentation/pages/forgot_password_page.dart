import 'package:flutter/material.dart';
import 'package:assetsphere/features/authentication/presentation/providers/auth_controller.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_form_container.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_header.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onBackToLogin;
  final ValueChanged<String>? onResetRequested;

  const ForgotPasswordPage({
    super.key,
    required this.controller,
    this.onBackToLogin,
    this.onResetRequested,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await widget.controller.requestPasswordReset(
      email: _emailController.text,
    );

    if (success && widget.onResetRequested != null) {
      widget.onResetRequested!(_emailController.text);
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
                      title: 'Reset Password',
                      subtitle: 'Enter your email to receive a reset link',
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
                    if (widget.controller.successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          widget.controller.successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
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
                          : const Text('Send Reset Link'),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: widget.controller.isLoading
                          ? null
                          : widget.onBackToLogin,
                      child: const Text('Back to Login'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Development Use Only: This is a mock reset flow and does not send a real email.',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
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
