import 'package:flutter/material.dart';
import 'package:assetsphere/features/authentication/presentation/widgets/auth_text_field.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PasswordField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    required this.obscureText,
    required this.onToggleVisibility,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: label,
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      prefixIcon: Icons.lock_outline,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: 1,
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggleVisibility,
        tooltip: obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}
