// auth_choice_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/custom_button.dart';

class AuthChoiceScreen extends StatelessWidget {
  final VoidCallback onEmailAuth;
  final VoidCallback onAppleAuth;
  final VoidCallback onGoogleAuth;
  final VoidCallback onGuestContinue;

  const AuthChoiceScreen({
    Key? key,
    required this.onEmailAuth,
    required this.onAppleAuth,
    required this.onGoogleAuth,
    required this.onGuestContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // App Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D5016), Color(0xFF3D5A3C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 40),
              ),

              const SizedBox(height: 32),

              // Headline
              Text(
                "Let's get you started",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 48),

              // Auth Buttons
              AuthButton(type: AuthButtonType.email, onPressed: onEmailAuth),

              const SizedBox(height: 16),

              AuthButton(type: AuthButtonType.apple, onPressed: onAppleAuth),

              const SizedBox(height: 16),

              AuthButton(type: AuthButtonType.google, onPressed: onGoogleAuth),

              const SizedBox(height: 32),

              // Divider with "or"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Continue without account
              CustomButton(
                text: 'Continue without account',
                onPressed: onGuestContinue,
                variant: ButtonVariant.text,
              ),

              const SizedBox(height: 8),

              Text(
                '(You can sync later)',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),

              const Spacer(),

              // Legal text
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'By continuing, you agree to our Terms of Service & Privacy Policy',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
