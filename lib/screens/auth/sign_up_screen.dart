// sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/screens/home_screen.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignUpSuccess;
  final VoidCallback onLoginTap;

  const SignUpScreen({
    Key? key,
    required this.onSignUpSuccess,
    required this.onLoginTap,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Map<int, bool> _hasAnimated = {};
  bool _isLoading = false;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  final UserDatabaseService _userService = UserDatabaseService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(
        _passwordController.text,
      );
    });
  }

  String? _confirmPasswordValidator(String? value) {
    return Validators.confirmPasswordValidator(value, _passwordController.text);
  }

  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getPasswordStrengthText() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double _getPasswordStrengthProgress() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        Validators.isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 6 &&
        Validators.passwordsMatch(
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use UserDatabaseService for signup
      final authResponse = await _userService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: null, // You can add a name field if needed
      );

      if (authResponse.user != null && mounted) {
        setState(() => _isLoading = false);

        // Success - navigate to next screen
        widget.onSignUpSuccess();

        // Optional: Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: const Color.fromARGB(255, 38, 90, 40),
          ),
        );
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Safe Area consideration
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(12),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24.0,
                    8.0,
                    24.0,
                    MediaQuery.of(context).viewInsets.bottom + 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated Headline
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Your Account',
                                  style: AppTextStyles.headlineLarge(context)
                                      .copyWith(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[900],
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Join us and start your journey',
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Animated Email Field
                        _buildAnimatedField(
                          delay: 200,
                          child: CustomTextField(
                            label: 'Email address',
                            hintText: 'Enter your email',
                            type: TextFieldType.email,
                            controller: _emailController,
                            validator: Validators.emailValidator,
                            showValidationIcon: true,
                            textInputAction: TextInputAction.next,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Animated Password Field with Strength Indicator
                        _buildAnimatedField(
                          delay: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                label: 'Password',
                                hintText: 'Enter your password',
                                type: TextFieldType.password,
                                controller: _passwordController,
                                validator: Validators.passwordValidator,
                                showValidationIcon: true,
                              ),

                              const SizedBox(height: 12),

                              // Animated Password Strength Indicator
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: _passwordController.text.isNotEmpty
                                    ? 1.0
                                    : 0.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: SizedBox(
                                                height: 6,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                    ),
                                                    FractionallySizedBox(
                                                      widthFactor:
                                                          _getPasswordStrengthProgress(),
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 300,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              _getPasswordStrengthColor(),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  _getPasswordStrengthColor(),
                                            ),
                                            child: Text(
                                              _getPasswordStrengthText(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'At least 8 characters',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Animated Confirm Password Field
                        _buildAnimatedField(
                          delay: 400,
                          child: CustomTextField(
                            label: 'Confirm Password',
                            hintText: 'Confirm your password',
                            type: TextFieldType.password,
                            controller: _confirmPasswordController,
                            validator: _confirmPasswordValidator,
                            showValidationIcon: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submitForm(),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Animated Create Account Button
                        _buildAnimatedField(
                          delay: 500,
                          child: CustomButton(
                            text: 'Create Account',
                            onPressed: _isFormValid && !_isLoading
                                ? () => _submitForm()
                                : null,
                            isLoading: _isLoading,
                            enabled: _isFormValid && !_isLoading,
                          ),
                          // child: CustomButton(
                          //   text: 'Create Account (Tester)',
                          //   onPressed: () {
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => DashboardScreen(),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ),

                        const SizedBox(height: 32),

                        // Animated Login Link
                        _buildAnimatedField(
                          delay: 600,
                          child: Center(
                            child: GestureDetector(
                              onTap: widget.onLoginTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Log In',
                                        style: const TextStyle(
                                          color: Color(0xFF2D5016),
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required Widget child, required int delay}) {
    // Mark this animation as completed once it runs
    if (!_hasAnimated.containsKey(delay)) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() {
            _hasAnimated[delay] = true;
          });
        }
      });
    }

    final shouldAnimate = _hasAnimated[delay] == true;

    return AnimatedOpacity(
      opacity: shouldAnimate ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, shouldAnimate ? 0 : 30, 0),
        child: child,
      ),
    );
  }

  // Helper method to format error messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (errorString.contains('network') ||
        errorString.contains('Connection')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'Signup failed. Please try again.';
    }
  }
}
