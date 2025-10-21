// onboarding_page_1.dart
import 'package:flutter/material.dart';
import 'package:Grounded/theme/app_text_styles.dart';

class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({Key? key}) : super(key: key);

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _pulseController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _pulseAnimation;

  bool _showSubtitle = false;
  bool _showIllustration = false;

  @override
  void initState() {
    super.initState();

    // Main animation controller for overall orchestration
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Pulse animation for logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Logo animations with bounce effect
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Content animations with smooth transitions
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Subtle pulse effect
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animation sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  void _startAnimationSequence() async {
    await _logoController.forward();
    _mainController.forward();

    // Delay subtitle appearance
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _showSubtitle = true;
      });
    }

    // Delay illustration appearance
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _showIllustration = true;
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // App Icon/Logo with sophisticated animations
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
                        width: 120,
                        height: 120,
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
                          size: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 56),

              // Headline with refined typewriter effect
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: TypwriterAnimatedText(
                    text: 'Welcome to Grounded',
                    style: AppTextStyles.headlineLarge(context),
                    duration: const Duration(milliseconds: 1500),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subheadline with elegant slide up
              AnimatedSlideUpText(
                text: 'Track with clarity, live with intention',
                style: AppTextStyles.bodyLarge(
                  context,
                ).copyWith(color: Colors.grey[600], height: 1.5),
                show: _showSubtitle,
                delay: 0,
              ),

              const SizedBox(height: 56),

              // Enhanced Illustration with staggered bar animations
              AnimatedOpacity(
                opacity: _showIllustration ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  offset: _showIllustration
                      ? Offset.zero
                      : const Offset(0, 0.1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 240,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[50]!,
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildAnimatedBar(
                                0.5,
                                const Color(0xFF2D5016),
                                0,
                              ),
                              _buildAnimatedBar(
                                0.75,
                                const Color(0xFF3D5A3C),
                                120,
                              ),
                              _buildAnimatedBar(
                                0.9,
                                const Color(0xFF4A6B4A),
                                240,
                              ),
                              _buildAnimatedBar(
                                0.65,
                                const Color(0xFF5A7B5A),
                                360,
                              ),
                              _buildAnimatedBar(
                                0.8,
                                const Color(0xFF3D5A3C),
                                480,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D5016),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF2D5016,
                                          ).withOpacity(0.3),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Text(
                                    'Track Your Progress',
                                    style: AppTextStyles.caption(context)
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBar(double heightFactor, Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: heightFactor),
      duration: Duration(milliseconds: 1000 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          width: 32,
          height: 140 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.7), color, color.withOpacity(0.9)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
        );
      },
    );
  }
}

class TypwriterAnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final VoidCallback? onTypingComplete;

  const TypwriterAnimatedText({
    Key? key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.onTypingComplete,
  }) : super(key: key);

  @override
  State<TypwriterAnimatedText> createState() => _TypwriterAnimatedTextState();
}

class _TypwriterAnimatedTextState extends State<TypwriterAnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _textAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTypingComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _textAnimation.value);
        return Text(
          displayText,
          style: widget.style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class AnimatedSlideUpText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool show;
  final int delay;

  const AnimatedSlideUpText({
    Key? key,
    required this.text,
    this.style,
    required this.show,
    this.delay = 0,
  }) : super(key: key);

  @override
  State<AnimatedSlideUpText> createState() => _AnimatedSlideUpTextState();
}

class _AnimatedSlideUpTextState extends State<AnimatedSlideUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.show) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AnimatedSlideUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
