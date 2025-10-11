// auth_button.dart

import 'package:flutter/material.dart';
import 'custom_button.dart';

enum AuthButtonType { email, apple, google }

class AuthButton extends StatelessWidget {
  final AuthButtonType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthButton({
    Key? key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (icon, text, variant) = _getButtonConfig();

    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      isLoading: isLoading,
      icon: icon,
    );
  }

  (Widget, String, ButtonVariant) _getButtonConfig() {
    switch (type) {
      case AuthButtonType.email:
        return (
          const Icon(Icons.email_outlined, size: 20),
          'Continue with Email',
          ButtonVariant.primary,
        );
      case AuthButtonType.apple:
        return (
          const Icon(Icons.apple, size: 20),
          'Sign in with Apple',
          ButtonVariant.secondary,
        );
      case AuthButtonType.google:
        return (
          Image.asset('assets/logos/google-icon.png', width: 20, height: 20),
          'Sign in with Google',
          ButtonVariant.secondary,
        );
    }
  }
}
