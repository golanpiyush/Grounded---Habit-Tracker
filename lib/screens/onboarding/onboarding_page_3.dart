// onboarding_page_3.dart
import 'package:flutter/material.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({Key? key}) : super(key: key);

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3>
    with TickerProviderStateMixin {
  late AnimationController _lockController;
  late AnimationController _shieldController;
  late Animation<double> _lockAnimation;
  late Animation<double> _shieldAnimation;

  @override
  void initState() {
    super.initState();

    _lockController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shieldController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _lockAnimation = CurvedAnimation(
      parent: _lockController,
      curve: Curves.elasticOut,
    );

    _shieldAnimation = CurvedAnimation(
      parent: _shieldController,
      curve: Curves.easeInOut,
    );

    _lockController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _shieldController.forward();
    });
  }

  @override
  void dispose() {
    _lockController.dispose();
    _shieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Lock Icon with Shield
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated shield background
                    AnimatedBuilder(
                      animation: _shieldAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _shieldAnimation.value,
                          child: CustomPaint(
                            size: Size(
                              MediaQuery.of(context).size.width * 0.4,
                              MediaQuery.of(context).size.width * 0.4,
                            ),
                            painter: ShieldPainter(_shieldAnimation.value),
                          ),
                        );
                      },
                    ),
                    // Animated lock icon
                    AnimatedBuilder(
                      animation: _lockAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _lockAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.06,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF2D5016),
                                  const Color(0xFF4A7C2A),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2D5016,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              size: MediaQuery.of(context).size.width * 0.15,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Headline with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [const Color(0xFF2D5016), const Color(0xFF4A7C2A)],
                ).createShader(bounds),
                child: Text(
                  'Your Data Stays Private',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Complete privacy and security, built-in',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Privacy Points with enhanced styling
              _buildPrivacyPoint(
                'End-to-end encrypted',
                Icons.enhanced_encryption_outlined,
                'Your data is encrypted at all times',
              ),
              const SizedBox(height: 16),
              _buildPrivacyPoint(
                'Stored on your device only',
                Icons.phone_android_outlined,
                'No cloud storage, complete control',
              ),
              const SizedBox(height: 16),
              _buildPrivacyPoint(
                'No account needed',
                Icons.no_accounts_outlined,
                'Optional login for sync only',
              ),
              const SizedBox(height: 16),
              _buildPrivacyPoint(
                'We never see your data',
                Icons.visibility_off_outlined,
                '100% private to you',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(String title, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D5016).withOpacity(0.1),
                  const Color(0xFF4A7C2A).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2D5016), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  final double animationValue;

  ShieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF2D5016).withOpacity(0.2 * animationValue);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric circles for shield effect
    for (int i = 1; i <= 3; i++) {
      final currentRadius = radius * (i / 3) * animationValue;
      canvas.drawCircle(center, currentRadius, paint);
    }

    // Draw shield shape
    final shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF4A7C2A).withOpacity(0.3 * animationValue);

    final shieldPath = Path();
    final shieldWidth = size.width * 0.4;
    final shieldHeight = size.height * 0.5;

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

    canvas.drawPath(shieldPath, shieldPaint);
  }

  @override
  bool shouldRepaint(ShieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
