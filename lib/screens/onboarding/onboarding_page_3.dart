// onboarding_page_3.dart
import 'package:flutter/material.dart';
import 'package:grounded/theme/app_text_styles.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({Key? key}) : super(key: key);

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _lockController;
  late AnimationController _shieldController;
  late AnimationController _pulseController;

  late Animation<double> _headerAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _lockScaleAnimation;
  late Animation<double> _lockRotateAnimation;
  late Animation<double> _shieldAnimation;
  late Animation<double> _pulseAnimation;

  bool _showPrivacyPoints = false;

  @override
  void initState() {
    super.initState();

    // Main orchestration controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Lock icon animation
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shield background animation
    _shieldController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Header animations
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Lock animations with bounce
    _lockScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.elasticOut),
    );

    _lockRotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _lockController, curve: Curves.easeOutCubic),
    );

    // Shield animation
    _shieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeOutCubic),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animation sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimationSequence();
    });
  }

  void _startAnimationSequence() async {
    _shieldController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _lockController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _mainController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _showPrivacyPoints = true;
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _lockController.dispose();
    _shieldController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Animated Lock Icon with Shield
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated shield background
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _shieldAnimation,
                    _pulseAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _shieldAnimation.value * _pulseAnimation.value,
                      child: CustomPaint(
                        size: const Size(180, 180),
                        painter: ShieldPainter(_shieldAnimation.value),
                      ),
                    );
                  },
                ),
                // Animated lock icon
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _lockScaleAnimation,
                    _lockRotateAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _lockScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _lockRotateAnimation.value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2D5016), Color(0xFF4A7C2A)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2D5016).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Headline with gradient
          SlideTransition(
            position: _headerSlideAnimation,
            child: FadeTransition(
              opacity: _headerAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D5016),
                    Color(0xFF4A7C2A),
                    Color(0xFF6FA83A),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'Your Data Stays Private',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SlideTransition(
            position: _headerSlideAnimation,
            child: FadeTransition(
              opacity: _headerAnimation,
              child: Text(
                'Complete privacy and security, built-in',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Privacy Points with staggered animations
          AnimatedOpacity(
            opacity: _showPrivacyPoints ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: Column(
              children: [
                _buildPrivacyPoint(
                  'End-to-end encrypted',
                  Icons.enhanced_encryption_outlined,
                  'Your data is encrypted at all times',
                  0,
                ),
                const SizedBox(height: 12),
                _buildPrivacyPoint(
                  'Stored on your device only',
                  Icons.phone_android_outlined,
                  'No cloud storage, complete control',
                  120,
                ),
                const SizedBox(height: 12),
                _buildPrivacyPoint(
                  'No account needed',
                  Icons.no_accounts_outlined,
                  'Optional login for sync only',
                  240,
                ),
                const SizedBox(height: 12),
                _buildPrivacyPoint(
                  'We never see your data',
                  Icons.visibility_off_outlined,
                  '100% private to you',
                  360,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(
    String title,
    IconData icon,
    String subtitle,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _showPrivacyPoints ? 1.0 : 0.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2D5016).withOpacity(0.12),
                          const Color(0xFF4A7C2A).withOpacity(0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF2D5016), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodySmall(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600, height: 1.3),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          subtitle,
                          style: AppTextStyles.caption(
                            context,
                          ).copyWith(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShieldPainter extends CustomPainter {
  final double animationValue;

  ShieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric circles with fade effect
    for (int i = 1; i <= 3; i++) {
      final currentRadius = radius * (i / 3) * animationValue;
      final opacity = (1 - (i / 4)) * animationValue * 0.3;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF2D5016).withOpacity(opacity);

      canvas.drawCircle(center, currentRadius, paint);
    }

    // Draw animated shield shape with gradient effect
    final shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF4A7C2A).withOpacity(0.4 * animationValue)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shieldWidth = size.width * 0.35;
    final shieldHeight = size.height * 0.45;

    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - shieldHeight / 2);
    shieldPath.lineTo(
      center.dx + shieldWidth / 2,
      center.dy - shieldHeight / 4,
    );
    shieldPath.lineTo(
      center.dx + shieldWidth / 2,
      center.dy + shieldHeight / 4,
    );
    shieldPath.lineTo(center.dx, center.dy + shieldHeight / 2);
    shieldPath.lineTo(
      center.dx - shieldWidth / 2,
      center.dy + shieldHeight / 4,
    );
    shieldPath.lineTo(
      center.dx - shieldWidth / 2,
      center.dy - shieldHeight / 4,
    );
    shieldPath.close();

    // Draw shield with glow effect
    if (animationValue > 0.7) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFF4A7C2A).withOpacity(0.2 * animationValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawPath(shieldPath, glowPaint);
    }

    canvas.drawPath(shieldPath, shieldPaint);

    // Draw checkmark inside shield
    if (animationValue > 0.8) {
      final checkPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(
          0xFF2D5016,
        ).withOpacity((animationValue - 0.8) * 5)
        ..strokeCap = StrokeCap.round;

      final checkPath = Path();
      checkPath.moveTo(center.dx - 15, center.dy);
      checkPath.lineTo(center.dx - 5, center.dy + 10);
      checkPath.lineTo(center.dx + 15, center.dy - 10);

      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(ShieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
