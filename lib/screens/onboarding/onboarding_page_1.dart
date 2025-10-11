// onboarding_page_1.dart

import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Icon/Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D5016), Color(0xFF3D5A3C)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 60),
          ),

          const SizedBox(height: 48),

          // Headline
          Text(
            'Welcome to Grounded',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subheadline
          Text(
            'Track with clarity, live with intention',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Illustration Placeholder
          // Replace the Container with the chart with this:

          // Illustration with Enhanced Charts
          Container(
            width: 280,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[50]!, Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildAnimatedBar(0.5, const Color(0xFF2D5016), 0),
                      _buildAnimatedBar(0.75, const Color(0xFF3D5A3C), 100),
                      _buildAnimatedBar(0.9, const Color(0xFF4A6B4A), 200),
                      _buildAnimatedBar(0.65, const Color(0xFF5A7B5A), 300),
                      _buildAnimatedBar(0.8, const Color(0xFF3D5A3C), 400),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D5016),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBar(double heightFactor, Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: heightFactor),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          width: 28,
          height: 120 * value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}
