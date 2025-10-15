// onboarding_page_2.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:grounded/theme/app_text_styles.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({Key? key}) : super(key: key);

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fadeSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Headline with gradient
              AnimatedBuilder(
                animation: _fadeSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeSlideAnimation.value)),
                    child: Opacity(
                      opacity: _fadeSlideAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [const Color(0xFF2D5016), const Color(0xFF4A7C2A)],
                  ).createShader(bounds),
                  child: Text(
                    'Understand Your Patterns',
                    style: AppTextStyles.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AnimatedBuilder(
                animation: _fadeSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeSlideAnimation.value)),
                    child: Opacity(
                      opacity: _fadeSlideAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Gain insights into your usage habits',
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Animated Pie Chart - Made responsive
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: math.min(
                      280,
                      MediaQuery.of(context).size.width - 80,
                    ),
                    height: math.min(
                      280,
                      MediaQuery.of(context).size.width - 80,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: UsagePieChartPainter(_animation.value),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '24h',
                              style: AppTextStyles.headlineSmall(context)
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            Text(
                              'Daily Pattern',
                              style: AppTextStyles.caption(
                                context,
                              ).copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Legend - Made scrollable for small screens
              AnimatedBuilder(
                animation: _fadeSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 15 * (1 - _fadeSlideAnimation.value)),
                    child: Opacity(
                      opacity: _fadeSlideAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Morning', const Color(0xFF2D5016)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Afternoon', const Color(0xFF4A7C2A)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Evening', const Color(0xFF6FA83A)),
                      const SizedBox(width: 16),
                      _buildLegendItem('Night', const Color(0xFFA8D890)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Feature List with improved styling
              AnimatedBuilder(
                animation: _fadeSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 15 * (1 - _fadeSlideAnimation.value)),
                    child: Opacity(
                      opacity: _fadeSlideAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    _buildFeatureItem(
                      'Track usage without judgment',
                      Icons.visibility_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Discover when and why you use',
                      Icons.psychology_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Set goals that work for you',
                      Icons.flag_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF2D5016), const Color(0xFF4A7C2A)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5016).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsagePieChartPainter extends CustomPainter {
  final double animationValue;

  UsagePieChartPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Chart data: [value, color, label]
    final List<Map<String, dynamic>> segments = [
      {
        'value': 0.35,
        'color': const Color(0xFF2D5016),
        'label': 'Morning\n35%',
        'angle': 0.0,
      },
      {
        'value': 0.25,
        'color': const Color(0xFF4A7C2A),
        'label': 'Afternoon\n25%',
        'angle': 0.0,
      },
      {
        'value': 0.30,
        'color': const Color(0xFF6FA83A),
        'label': 'Evening\n30%',
        'angle': 0.0,
      },
      {
        'value': 0.10,
        'color': const Color(0xFFA8D890),
        'label': 'Night\n10%',
        'angle': 0.0,
      },
    ];

    double startAngle = -math.pi / 2;

    // Draw pie segments
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = 2 * math.pi * segment['value'] * animationValue;

      final paint = Paint()
        ..color = segment['color']
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw white separator lines
      if (animationValue > 0.95) {
        final linePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

        final lineEnd = Offset(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        );

        canvas.drawLine(center, lineEnd, linePaint);
      }

      startAngle += sweepAngle;
    }

    // Draw center circle (donut effect)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(UsagePieChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
