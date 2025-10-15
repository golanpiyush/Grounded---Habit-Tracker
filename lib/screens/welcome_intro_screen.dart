// welcome_intro_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grounded/screens/auth/goal_setup_screen.dart';
import 'dart:async';
import '../../widgets/custom_button.dart';

class WelcomeIntroScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeIntroScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<WelcomeIntroScreen> createState() => _WelcomeIntroScreenState();
}

class _WelcomeIntroScreenState extends State<WelcomeIntroScreen>
    with TickerProviderStateMixin {
  int _currentTextIndex = 0;
  bool _showButton = false;

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hi, welcome to Grounded 👋', 'duration': 2500},
    {'text': 'We\'re here to support you,\nnot judge you', 'duration': 3000},
    {
      'text': 'Your privacy is sacred.\nEverything stays on your device',
      'duration': 3200,
    },
    {
      'text':
          'This is your journey.\nWe\'re just here to help you\nunderstand it better',
      'duration': 3500,
    },
    {
      'text':
          'Before we begin,\nlet\'s take 5 minutes to\npersonalize your experience',
      'duration': 3000,
    },
  ];

  late AnimationController _textAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  Timer? _textTimer;

  @override
  void initState() {
    super.initState();

    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Text animation controller
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Pulse animation controller
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Button animation controller
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    _logoAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
    _startTextAnimation();
  }

  void _startTextAnimation() {
    _textAnimationController.forward(from: 0);

    _textTimer = Timer(
      Duration(milliseconds: _messages[_currentTextIndex]['duration']),
      () {
        if (!mounted) return;

        if (_currentTextIndex < _messages.length - 1) {
          setState(() {
            _currentTextIndex++;
          });
          _textAnimationController.forward(from: 0);
          _startTextAnimation();
        } else {
          setState(() {
            _showButton = true;
          });
          _buttonAnimationController.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _textAnimationController.dispose();
    _logoAnimationController.dispose();
    _pulseAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GoalSetupScreen(onComplete: widget.onComplete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2D5016).withOpacity(0.02),
                      Colors.white,
                      const Color(0xFF3D5A3C).withOpacity(0.02),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                const SizedBox(height: 20),

                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextButton(
                      onPressed: _handleContinue,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Animated Logo
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoScaleAnimation,
                    _logoFadeAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value * _pulseAnimation.value,
                      child: Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2D5016), Color(0xFF3D5A3C)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2D5016).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Animated text messages
                SizedBox(
                  height: 180,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            _messages[_currentTextIndex]['text'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              height: 1.4,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress indicator (fixed position)
                SizedBox(
                  height: 60,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showButton ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _messages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index <= _currentTextIndex
                                  ? const Color(0xFF2D5016)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue button (fixed position)
                SizedBox(
                  height: 140,
                  child: Center(
                    child: _showButton
                        ? FadeTransition(
                            opacity: _buttonFadeAnimation,
                            child: SlideTransition(
                              position: _buttonSlideAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        text: 'Continue',
                                        onPressed: _handleContinue,
                                        enabled: true,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Takes about 5 minutes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
