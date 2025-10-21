// substance_selection_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grounded/models/onboarding_data.dart';
import 'package:grounded/screens/auth/usage_patterns_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';

class SubstanceSelectionScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final OnboardingData onboardingData;

  const SubstanceSelectionScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
    required this.onboardingData,
  }) : super(key: key);

  @override
  State<SubstanceSelectionScreen> createState() =>
      _SubstanceSelectionScreenState();
}

class _SubstanceSelectionScreenState extends State<SubstanceSelectionScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedSubstances = {};
  final Map<String, String> _substanceDurations = {};
  String? _previousAttempts;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Tab controller
  int _currentTabIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _substances = [
    {
      'name': 'Alcohol',
      'icon': '🍺',
      'color': const Color(0xFFEF5350),
      'gradient': [const Color(0xFFEF5350), const Color(0xFFE57373)],
    },
    {
      'name': 'Cannabis',
      'icon': '🌿',
      'color': const Color(0xFF66BB6A),
      'gradient': [const Color(0xFF66BB6A), const Color(0xFF81C784)],
    },
    {
      'name': 'Tobacco',
      'icon': '🚬',
      'color': const Color(0xFF8D6E63),
      'gradient': [const Color(0xFF8D6E63), const Color(0xFFA1887F)],
    },
    {
      'name': 'Caffeine',
      'icon': '☕',
      'color': const Color(0xFF6D4C41),
      'gradient': [const Color(0xFF6D4C41), const Color(0xFF8D6E63)],
    },
    {
      'name': 'Vaping',
      'icon': '💨',
      'color': const Color(0xFF5C6BC0),
      'gradient': [const Color(0xFF5C6BC0), const Color(0xFF7986CB)],
    },
    {
      'name': 'Prescription',
      'icon': '💊',
      'color': const Color(0xFFAB47BC),
      'gradient': [const Color(0xFFAB47BC), const Color(0xFFBA68C8)],
    },
    {
      'name': 'Cocaine',
      'icon': '❄️',
      'color': const Color(0xFF78909C),
      'gradient': [const Color(0xFF78909C), const Color(0xFF90A4AE)],
    },
    {
      'name': 'Heroin',
      'icon': '⚗️',
      'color': const Color(0xFF5D4037),
      'gradient': [const Color(0xFF5D4037), const Color(0xFF6D4C41)],
    },
    {
      'name': 'Fentanyl',
      'icon': '⚠️',
      'color': const Color(0xFFD32F2F),
      'gradient': [const Color(0xFFD32F2F), const Color(0xFFF44336)],
    },
    {
      'name': 'Meth',
      'icon': '🧊',
      'color': const Color(0xFF00796B),
      'gradient': [const Color(0xFF00796B), const Color(0xFF009688)],
    },
    {
      'name': 'MDMA',
      'icon': '✨',
      'color': const Color(0xFF7B1FA2),
      'gradient': [const Color(0xFF7B1FA2), const Color(0xFF9C27B0)],
    },
    {
      'name': 'LSD',
      'icon': '🌈',
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFF06292)],
    },
    {
      'name': 'Psilocybin',
      'icon': '🍄',
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
    },
    {
      'name': 'Ketamine',
      'icon': '🌀',
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
    },
    {
      'name': 'Benzos',
      'icon': '💊',
      'color': const Color(0xFFFF9800),
      'gradient': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    },
    {
      'name': 'Opioids',
      'icon': '⚕️',
      'color': const Color(0xFF795548),
      'gradient': [const Color(0xFF795548), const Color(0xFF8D6E63)],
    },
    {
      'name': 'Amphetamines',
      'icon': '⚡',
      'color': const Color(0xFFFFC107),
      'gradient': [const Color(0xFFFFC107), const Color(0xFFFFD54F)],
    },
    {
      'name': 'Sugar',
      'icon': '🍭',
      'color': const Color(0xFFEC407A),
      'gradient': [const Color(0xFFEC407A), const Color(0xFFF06292)],
    },
    {
      'name': 'Other',
      'icon': '🔬',
      'color': const Color(0xFF42A5F5),
      'gradient': [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
    },
  ];

  final List<String> _durationOptions = [
    'Less than 6 months',
    '6 months - 1 year',
    '1-3 years',
    '3-5 years',
    '5+ years',
    'Prefer not to say',
  ];

  final List<String> _attemptOptions = [
    'Never tried',
    'Once',
    '2-3 times',
    'Many times',
    'Currently in recovery',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSubstance(String substance) {
    setState(() {
      if (_selectedSubstances.contains(substance)) {
        _selectedSubstances.remove(substance);
      } else {
        _selectedSubstances.add(substance);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedSubstances.isEmpty || !mounted) return;

    // Update onboardingData with substance selection data
    final updatedData = widget.onboardingData.copyWith(
      selectedSubstances: _selectedSubstances,
      substanceDurations: _substanceDurations,
      previousAttempts: _previousAttempts,
    );

    // PRINT DATA BEFORE NAVIGATION
    print('=== NAVIGATING TO USAGE PATTERNS SCREEN ===');
    print('Selected Substances: ${_selectedSubstances.toList()}');

    print('==========================================');

    // Save ONLY substance-related data to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_substances', _selectedSubstances.toList());
    await prefs.setString('user_previous_attempts', _previousAttempts ?? '');
    await prefs.setString(
      'user_substance_durations',
      jsonEncode(_substanceDurations),
    );

    if (!mounted) return;

    // Navigate to UsagePatternsScreen with updated data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsagePatternsScreen(
          onboardingData: updatedData, // ← This contains ALL data (old + new)
          selectedSubstances: _selectedSubstances.toList(),
          onContinue: () {
            widget.onContinue();
          },
        ),
      ),
    );
  }

  // REPLACE _handleSkip method:
  Future<void> _handleSkip() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_substances', []);
    await prefs.setString('user_previous_attempts', '');
    await prefs.setString('user_substance_durations', '{}');

    if (mounted) {
      // Call the onSkip callback
      widget.onSkip();
    }
  }

  Widget _buildSubstanceDurationSection(String substance) {
    final currentDuration = _substanceDurations[substance];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How long have you been using $substance?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durationOptions.map((duration) {
              final isSelected = currentDuration == duration;
              return ChoiceChip(
                label: Text(duration),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _substanceDurations[substance] = duration;
                    } else if (currentDuration == duration) {
                      _substanceDurations.remove(substance);
                    }
                  });
                },
                selectedColor: Colors.green.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF2D5016) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF2D5016) : Colors.grey[500],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? const Color(0xFF2D5016) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with gradient
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.grey[800],
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: const EdgeInsets.all(12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Step 2 of 2',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Animated Headline
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2D5016).withOpacity(0.1),
                                      const Color(0xFF4CAF50).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '🎯',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Personalize your journey',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'What would you like\nto track?',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey[900],
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Choose one or more to get personalized insights and support.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Substance Grid with enhanced cards
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: _substances.length,
                        itemBuilder: (context, index) {
                          final substance = _substances[index];
                          final isSelected = _selectedSubstances.contains(
                            substance['name'],
                          );

                          return _buildAnimatedSubstance(
                            delay: 80 * index,
                            child: _SubstanceCard(
                              name: substance['name']!,
                              icon: substance['icon']!,
                              color: substance['color']!,
                              gradient: substance['gradient']!,
                              isSelected: isSelected,
                              onTap: () => _toggleSubstance(substance['name']!),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Professional Tab Section
                      if (_selectedSubstances.isNotEmpty)
                        _buildAnimatedSubstance(
                          delay: 600,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Tab Bar
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTab(
                                        index: 0,
                                        icon: Icons.access_time_rounded,
                                        label: 'Duration',
                                        isActive: _currentTabIndex == 0,
                                      ),
                                      _buildTab(
                                        index: 1,
                                        icon: Icons.history_rounded,
                                        label: 'Attempts',
                                        isActive: _currentTabIndex == 1,
                                      ),
                                    ],
                                  ),
                                ),

                                // Tab Content
                                SizedBox(
                                  height: _currentTabIndex == 0
                                      ? (_selectedSubstances.length * 160.0)
                                      : 240.0,
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentTabIndex = index;
                                      });
                                    },
                                    children: [
                                      // Duration of Use Tab
                                      SingleChildScrollView(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Duration of Use',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey[900],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'How long have you been using each substance?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ..._selectedSubstances.map((
                                              substance,
                                            ) {
                                              return _buildSubstanceDurationSection(
                                                substance,
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),

                                      // Previous Quit Attempts Tab
                                      SingleChildScrollView(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Previous Quit Attempts',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey[900],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Have you tried to reduce or quit before?',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: _attemptOptions.map((
                                                attempt,
                                              ) {
                                                final isSelected =
                                                    _previousAttempts ==
                                                    attempt;
                                                return ChoiceChip(
                                                  label: Text(attempt),
                                                  selected: isSelected,
                                                  onSelected: (selected) {
                                                    setState(() {
                                                      _previousAttempts =
                                                          selected
                                                          ? attempt
                                                          : null;
                                                    });
                                                  },
                                                  selectedColor: Colors.blue
                                                      .withOpacity(0.2),
                                                  labelStyle: TextStyle(
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.grey[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Section with enhanced design
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
                child: Column(
                  children: [
                    // Selection Counter with animation
                    if (_selectedSubstances.isNotEmpty)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _selectedSubstances.isEmpty ? 0 : 1,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF2D5016).withOpacity(0.12),
                                const Color(0xFF4CAF50).withOpacity(0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2D5016).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2D5016),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedSubstances.length} ${_selectedSubstances.length == 1 ? 'substance' : 'substances'} selected',
                                style: const TextStyle(
                                  color: Color(0xFF2D5016),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Continue Button
                    CustomButton(
                      text: _selectedSubstances.isEmpty
                          ? 'Select at least one'
                          : 'Continue',
                      onPressed: _selectedSubstances.isNotEmpty
                          ? _handleContinue
                          : null,
                      enabled: _selectedSubstances.isNotEmpty,
                    ),

                    // Helper text
                    if (_selectedSubstances.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'You can always modify this later',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubstance({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Transform.scale(
            scale: 0.85 + (0.15 * value),
            child: Opacity(opacity: value, child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class _SubstanceCard extends StatefulWidget {
  final String name;
  final String icon;
  final Color color;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubstanceCard({
    Key? key,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_SubstanceCard> createState() => _SubstanceCardState();
}

class _SubstanceCardState extends State<_SubstanceCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SubstanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.94 : 1.0)
            ..rotateZ(_isPressed ? -0.01 : 0.0),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? Colors.transparent : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Background pattern for selected state
              if (widget.isSelected)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      painter: _DotPatternPainter(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with background
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.25)
                            : widget.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.grey[900],
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Checkmark with animation
              if (widget.isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: widget.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for decorative dot pattern
class _DotPatternPainter extends CustomPainter {
  final Color color;

  _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double spacing = 15;
    const double dotSize = 2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
