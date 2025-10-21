// goal_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Grounded/models/onboarding_data.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
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
  final Set<String> _selectedReasons = {};
  DateTime? _selectedDate;
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
        return _selectedTimeline != null || _selectedDate != null;
      case 2:
        return true;
      case 3:
        return _selectedReasons.isNotEmpty; // CHANGE THIS LINE
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

          // Timeline Options
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _timelineOptions.map((timeline) {
              final isSelected = _selectedTimeline == timeline;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeline = timeline;
                    _selectedDate =
                        null; // Clear specific date when timeline is selected
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
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Text(
                    timeline,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Divider with text
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),

          const SizedBox(height: 24),

          // Date Picker Section
          // In the date picker section, replace the existing content with:
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate:
                    _selectedDate ??
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryGreen,
                        onPrimary: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _selectedTimeline = _calculateTimelineFromDate(
                    picked,
                  ); // Auto-calculate timeline
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedDate != null
                    ? AppColors.primaryGreen.withOpacity(0.08)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedDate != null
                      ? AppColors.primaryGreen
                      : Colors.grey[300]!,
                  width: _selectedDate != null ? 2.5 : 1.5,
                ),
                boxShadow: _selectedDate != null
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _selectedDate != null
                              ? AppColors.primaryGreen
                              : AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: _selectedDate != null
                              ? Colors.white
                              : AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set a specific date',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Choose your target date',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDate != null
                                    ? AppColors.primaryGreen
                                    : Colors.grey[600],
                                fontWeight: _selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: _selectedDate != null
                            ? AppColors.primaryGreen
                            : Colors.grey[400],
                      ),
                    ],
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${_calculateDaysRemaining(_selectedDate!)} days (${_calculateTimelineFromDate(_selectedDate!)}) to achieve your goal',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
          // Header Section
          Text(
            'How ready are you? 💪',
            style: AppTextStyles.headlineLarge(context).copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rate your readiness to make a change',
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),

          // Animated Circular Progress with Level
          Center(
            child: Column(
              children: [
                // Main Circle Display
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, scaleValue, child) {
                    return Transform.scale(
                      scale: 0.85 + (0.15 * scaleValue),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getMotivationColor(
                                    _motivationLevel,
                                  ).withOpacity(0.0),
                                  _getMotivationColor(
                                    _motivationLevel,
                                  ).withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                          // Main circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getMotivationColor(
                                _motivationLevel,
                              ).withOpacity(0.12),
                              border: Border.all(
                                color: _getMotivationColor(_motivationLevel),
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getMotivationColor(
                                    _motivationLevel,
                                  ).withOpacity(0.35),
                                  blurRadius: 24,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated number
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    tween: Tween(
                                      begin: _motivationLevel.toDouble() - 0.5,
                                      end: _motivationLevel.toDouble(),
                                    ),
                                    builder: (context, value, child) {
                                      return Text(
                                        value.round().toString(),
                                        style: GoogleFonts.cabin(
                                          fontSize: 56,
                                          fontWeight: FontWeight.w800,
                                          color: _getMotivationColor(
                                            _motivationLevel,
                                          ),
                                          letterSpacing: -2,
                                          height: 1,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'out of 10',
                                    style: AppTextStyles.caption(context)
                                        .copyWith(
                                          color: _getMotivationColor(
                                            _motivationLevel,
                                          ).withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Animated Status Badge
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.8,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_motivationLevel),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getMotivationColor(
                            _motivationLevel,
                          ).withOpacity(0.15),
                          _getMotivationColor(
                            _motivationLevel,
                          ).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _getMotivationColor(
                          _motivationLevel,
                        ).withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMotivationIcon(_motivationLevel),
                          color: _getMotivationColor(_motivationLevel),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getMotivationText(_motivationLevel),
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _getMotivationColor(_motivationLevel),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Interactive Slider Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 10,
                    activeTrackColor: _getMotivationColor(_motivationLevel),
                    inactiveTrackColor: AppColors.borderColor,
                    thumbColor: AppColors.cardColor,
                    overlayColor: _getMotivationColor(
                      _motivationLevel,
                    ).withOpacity(0.15),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 16,
                      elevation: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 32,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                    valueIndicatorColor: _getMotivationColor(_motivationLevel),
                  ),
                  child: Slider(
                    value: _motivationLevel.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _motivationLevel = value.round();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Slider Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSliderLabel(
                      Icons.explore_outlined,
                      'Just exploring',
                      _motivationLevel <= 3,
                    ),
                    _buildSliderLabel(
                      Icons.rocket_launch_rounded,
                      'Ready to commit',
                      _motivationLevel >= 8,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dynamic Description Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getMotivationColor(_motivationLevel).withOpacity(0.08),
                  _getMotivationColor(_motivationLevel).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getMotivationColor(_motivationLevel).withOpacity(0.25),
                width: 2,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey<int>(_motivationLevel),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMotivationColor(
                        _motivationLevel,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMotivationIcon(_motivationLevel),
                      color: _getMotivationColor(_motivationLevel),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMotivationTitle(_motivationLevel),
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _getMotivationColor(_motivationLevel),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMotivationDescription(_motivationLevel),
                          style: AppTextStyles.bodySmall(context).copyWith(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
            'Select all that apply',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _reasonOptions.map((reason) {
              final isSelected = _selectedReasons.contains(reason);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedReasons.remove(reason);
                    } else {
                      _selectedReasons.add(reason);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green[600]!
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: isSelected ? Colors.green[700] : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 15,
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

    // Calculate timeline from date if no timeline selected
    final String? finalTimeline;
    if (_selectedTimeline == null && _selectedDate != null) {
      finalTimeline = _calculateTimelineFromDate(_selectedDate!);
    } else {
      finalTimeline = _selectedTimeline;
    }

    // Create OnboardingData object with goal setup data
    final onboardingData = OnboardingData(
      selectedGoals: _selectedGoals,
      selectedTimeline: finalTimeline, // Use calculated timeline
      targetDate: _selectedDate,
      motivationLevel: _motivationLevel,
      primaryReason: _selectedReasons.isNotEmpty
          ? _selectedReasons.first
          : null,
      selectedReasons: _selectedReasons,
    );

    // PRINT DATA WITH CALCULATED TIMELINE
    print('=== NAVIGATING TO SUBSTANCE SELECTION ===');
    print('Selected Goals: ${_selectedGoals.toList()}');
    print('Selected Timeline: $finalTimeline'); // This will show "4 months"
    print('Selected Date: $_selectedDate');
    print('Motivation Level: $_motivationLevel');
    print('Selected Reasons: ${_selectedReasons.toList()}');
    print(
      'Calculated Timeline: ${_selectedDate != null ? _calculateTimelineFromDate(_selectedDate!) : "N/A"}',
    );
    print('========================================');

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_goals', _selectedGoals.toList());
    await prefs.setString('user_timeline', finalTimeline ?? '');
    if (_selectedDate != null) {
      await prefs.setString(
        'user_target_date',
        _selectedDate!.toIso8601String(),
      );
    }
    await prefs.setInt('user_motivation_level', _motivationLevel);
    await prefs.setStringList(
      'user_selected_reasons',
      _selectedReasons.toList(),
    );
    await prefs.setString(
      'user_primary_reason',
      onboardingData.primaryReason ?? '',
    );

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

  // REPLACE _handleSkip method:
  void _handleSkip() async {
    if (!mounted) return;

    // Create OnboardingData with default values
    final onboardingData = OnboardingData(
      selectedGoals: _selectedGoals, // Keep any selected goals
      selectedTimeline: _selectedTimeline, // Keep any selected timeline
      targetDate: _selectedDate, // Keep any selected date
      motivationLevel: _motivationLevel, // Keep current motivation level
      primaryReason: _selectedReasons.isNotEmpty
          ? _selectedReasons.first
          : null,
      selectedReasons: _selectedReasons, // Keep any selected reasons
    );

    // Save to SharedPreferences for backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_goals', _selectedGoals.toList());
    await prefs.setString('user_timeline', _selectedTimeline ?? '');
    if (_selectedDate != null) {
      await prefs.setString(
        'user_target_date',
        _selectedDate!.toIso8601String(),
      );
    }
    await prefs.setInt('user_motivation_level', _motivationLevel);
    await prefs.setStringList(
      'user_selected_reasons',
      _selectedReasons.toList(),
    );
    await prefs.setString(
      'user_primary_reason',
      onboardingData.primaryReason ?? '',
    );

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

  Widget _buildSliderLabel(IconData icon, String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isActive
              ? _getMotivationColor(_motivationLevel)
              : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive
                ? _getMotivationColor(_motivationLevel)
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Add this method to _GoalSetupScreenState class
  int _calculateDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(
      DateTime(now.year, now.month, now.day),
    );
    return difference.inDays;
  }

  IconData _getMotivationIcon(int level) {
    if (level <= 3) return Icons.explore_outlined;
    if (level <= 6) return Icons.lightbulb_outline;
    return Icons.favorite_rounded;
  }

  // Add this helper method for titles
  String _getMotivationTitle(int level) {
    if (level <= 3) return "Exploration Phase";
    if (level <= 6) return "Contemplation Phase";
    return "Action Phase";
  }

  // Add this method to calculate and display timeline from date
  String _calculateTimelineFromDate(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    final days = difference.inDays;
    final months = (days / 30).floor();
    final years = (days / 365).floor();

    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (months > 0) {
      final remainingDays = days % 30;
      if (remainingDays > 0) {
        return '$months ${months == 1 ? 'month' : 'months'} $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
      }
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (days >= 7) {
      final weeks = (days / 7).floor();
      final remainingDays = days % 7;
      if (remainingDays > 0) {
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} $remainingDays ${remainingDays == 1 ? 'day' : 'days'}';
      }
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }

  // Update the existing description method
  String _getMotivationDescription(int level) {
    if (level <= 3) {
      return "You're in the exploration phase. That's a great first step! Take your time to understand your patterns and build awareness.";
    }
    if (level <= 6) {
      return "You're seriously considering change. This awareness is powerful and shows you're thinking about your next steps.";
    }
    return "You're ready to commit and take action! Your determination and readiness will be key drivers in achieving your goals.";
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
