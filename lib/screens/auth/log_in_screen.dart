// log_in_screen.dart

import 'package:flutter/material.dart';
import 'package:grounded/providers/userDB.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class LogInScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSignUpTap;
  final VoidCallback onForgotPassword;

  const LogInScreen({
    Key? key,
    required this.onLoginSuccess,
    required this.onSignUpTap,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserDatabaseService _userService = UserDatabaseService();

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Add listeners to rebuild UI when text changes
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        Validators.isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 6;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use UserDatabaseService for login
      final authResponse = await _userService.logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authResponse.user != null) {
        if (mounted) {
          setState(() => _isLoading = false);

          // Success - navigate to next screen
          widget.onLoginSuccess();

          // Optional: Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Headline
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 48),

                // Email Field
                CustomTextField(
                  label: 'Email address',
                  hintText: 'Enter your email',
                  type: TextFieldType.email,
                  controller: _emailController,
                  validator: Validators.emailValidator,
                  showValidationIcon: true,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 24),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      type: TextFieldType.password,
                      controller: _passwordController,
                      validator: Validators.passwordValidator,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitForm(),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: widget.onForgotPassword,
                        child: Text(
                          'Forgot?',
                          style: TextStyle(
                            color: const Color(0xFF2D5016),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Login Button
                // Login Button
                ValueListenableBuilder(
                  valueListenable: _emailController,
                  builder: (context, emailValue, _) {
                    return ValueListenableBuilder(
                      valueListenable: _passwordController,
                      builder: (context, passwordValue, _) {
                        final isFormValid =
                            _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            Validators.isValidEmail(_emailController.text) &&
                            _passwordController.text.length >= 6;

                        return CustomButton(
                          text: 'Log In',
                          onPressed: isFormValid && !_isLoading
                              ? _submitForm
                              : null,
                          isLoading: _isLoading,
                          enabled: isFormValid && !_isLoading,
                        );
                      },
                    );
                  },
                ),

                const Spacer(),

                // Sign Up Link
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GestureDetector(
                      onTap: widget.onSignUpTap,
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Color(0xFF2D5016),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('Invalid login credentials') ||
        errorString.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('Email not confirmed')) {
      return 'Please verify your email address before logging in.';
    } else if (errorString.contains('User not found')) {
      return 'No account found with this email address.';
    } else if (errorString.contains('network') ||
        errorString.contains('Connection')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'Login failed. Please try again.';
    }
  }
}
