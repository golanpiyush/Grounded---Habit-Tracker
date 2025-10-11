// log_in_screen.dart

import 'package:flutter/material.dart';
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

  bool _isLoading = false;

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        Validators.isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 6;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    widget.onLoginSuccess();
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
                CustomButton(
                  text: 'Log In',
                  onPressed: _isFormValid && !_isLoading ? _submitForm : null,
                  isLoading: _isLoading,
                  enabled: _isFormValid && !_isLoading,
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
}
