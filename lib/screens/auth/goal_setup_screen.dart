// goal_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:grounded/Models/onboarding_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';
import 'substance_selection_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const GoalSetupScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedGoals = {};
  String? _selectedTimeline;
  int _motivationLevel = 5;
  String? _primaryReason;

  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Reduce usage',
      'description': 'Gradually decrease how often you use',
      'icon': Icons.trending_down,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Track patterns',
      'description': 'Understand when and why you use',
      'icon': Icons.insights,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Take breaks',
      'description': 'Schedule regular substance-free periods',
      'icon': Icons.pause_circle_outline,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Build awareness',
      'description': 'Simply monitor without specific goals',
      'icon': Icons.visibility_outlined,
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Stay accountable',
      'description': 'Keep track and stay committed',
      'icon': Icons.fact_check_outlined,
      'color': const Color(0xFFE91E63),
    },
  ];

  final List<String> _timelineOptions = [
    'This week',
    'This month',
    '3 months',
    '6 months',
    'Just tracking for now',
  ];

  final List<String> _reasonOptions = [
    'Health concerns',
    'Financial pressure',
    'Relationships',
    'Work/career',
    'Legal issues',
    'Personal growth',
    'Doctor\'s recommendation',
    'Just curious',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Indicator
            _buildPageIndicator(),
            const SizedBox(height: 20),

            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildGoalsPage(),
                  _buildTimelinePage(),
                  _buildMotivationPage(),
                  _buildReasonPage(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentPage > 0 ? 2 : 1,
                    child: CustomButton(
                      text: _currentPage == 3 ? 'Continue' : 'Next',
                      onPressed: _canProceed() ? _handleNext : null,
                      enabled: _canProceed(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentPage == index ? 32 : 8,
            decoration: BoxDecoration(
              color: _currentPage == index ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGoals.isNotEmpty;
      case 1:
        return _selectedTimeline != null;
      case 2:
        return true; // Motivation level always has a value
      case 3:
        return _primaryReason != null;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleContinue();
    }
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What are your goals? 🎯",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Select one or more • You can change anytime',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ..._goals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            final isSelected = _selectedGoals.contains(goal['title']);

            return _buildAnimatedGoalOption(
              delay: 150 * index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _GoalOption(
                  title: goal['title']!,
                  description: goal['description']!,
                  icon: goal['icon']!,
                  color: goal['color']!,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal['title']);
                      } else {
                        _selectedGoals.add(goal['title']);
                      }
                    });
                  },
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTimelinePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When do you want to achieve this? ⏰',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Having a timeline helps you stay focused',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _timelineOptions.map((timeline) {
              final isSelected = _selectedTimeline == timeline;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeline = timeline;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    timeline,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMotivationPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How ready are you? 💪',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rate your readiness to make a change',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getMotivationColor(
                      _motivationLevel,
                    ).withOpacity(0.1),
                    border: Border.all(
                      color: _getMotivationColor(_motivationLevel),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_motivationLevel',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: _getMotivationColor(_motivationLevel),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getMotivationText(_motivationLevel),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _getMotivationColor(_motivationLevel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Slider(
            value: _motivationLevel.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _motivationLevel = value.round();
              });
            },
            activeColor: _getMotivationColor(_motivationLevel),
            inactiveColor: Colors.grey[300],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Just exploring',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Ready to commit',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReasonPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What brought you here? 🌱',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Understanding your motivation helps personalize your journey',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _reasonOptions.map((reason) {
              final isSelected = _primaryReason == reason;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _primaryReason = reason;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _getMotivationText(int level) {
    if (level <= 3) return "Just exploring";
    if (level <= 6) return "Thinking about it";
    return "Ready to commit";
  }

  Color _getMotivationColor(int level) {
    if (level <= 3) return Colors.orange;
    if (level <= 6) return Colors.blue;
    return Colors.green;
  }

  void _handleContinue() async {
    if (!mounted || _selectedGoals.isEmpty) return;

    // Create OnboardingData object with goal setup data
    final onboardingData = OnboardingData(
      selectedGoals: _selectedGoals,
      selectedTimeline: _selectedTimeline,
      motivationLevel: _motivationLevel,
      primaryReason: _primaryReason,
    );

    // PRINT DATA HERE
    print('=== NAVIGATING TO SUBSTANCE SELECTION ===');
    print('Selected Goals: ${_selectedGoals.toList()}');
    print('Selected Timeline: $_selectedTimeline');
    print('Motivation Level: $_motivationLevel');
    print('Primary Reason: $_primaryReason');
    print('OnboardingData: $onboardingData');
    print('========================================');

    // Still save to SharedPreferences for backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_goals', _selectedGoals.toList());
    await prefs.setString('user_timeline', _selectedTimeline ?? '');
    await prefs.setInt('user_motivation_level', _motivationLevel);
    await prefs.setString('user_primary_reason', _primaryReason ?? '');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubstanceSelectionScreen(
            onboardingData: onboardingData, // Pass data
            onContinue: widget.onComplete,
            onSkip: widget.onComplete,
          ),
        ),
      );
    }
  }

  // REPLACE _handleSkip method:
  void _handleSkip() async {
    if (!mounted) return;

    // Create empty OnboardingData
    final onboardingData = OnboardingData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_goals', []);
    await prefs.setString('user_timeline', '');
    await prefs.setInt('user_motivation_level', 0);
    await prefs.setString('user_primary_reason', '');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubstanceSelectionScreen(
            onboardingData: onboardingData,
            onContinue: widget.onComplete,
            onSkip: widget.onComplete,
          ),
        ),
      );
    }
  }

  Widget _buildAnimatedGoalOption({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _GoalOption extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_GoalOption> createState() => _GoalOptionState();
}

class _GoalOptionState extends State<_GoalOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.color.withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected ? widget.color : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color
                    : widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: widget.isSelected ? Colors.white : widget.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: widget.isSelected ? widget.color : Colors.transparent,
              ),
              child: widget.isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
