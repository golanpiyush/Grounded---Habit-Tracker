// ============= EDIT GOALS SCREEN =============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grounded/theme/app_colors.dart';
import 'package:grounded/theme/app_text_styles.dart';
import 'package:grounded/providers/theme_provider.dart';

class EditGoalsScreen extends ConsumerStatefulWidget {
  final List<String>? selectedGoals;

  const EditGoalsScreen({Key? key, this.selectedGoals}) : super(key: key);

  @override
  ConsumerState<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends ConsumerState<EditGoalsScreen>
    with TickerProviderStateMixin {
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

  late List<String> _selected;
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};
  final Map<String, Animation<double>> _checkAnimations = {};

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedGoals ?? []);

    // Initialize animation controllers for each goal
    for (var goal in _goals) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animationControllers[goal['title']] = controller;

      _scaleAnimations[goal['title']] = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _checkAnimations[goal['title']] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      // Set initial state for selected items
      if (_selected.contains(goal['title'])) {
        controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleGoal(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
        _animationControllers[title]?.reverse();
      } else {
        _selected.add(title);
        _animationControllers[title]?.forward();
      }
    });
    HapticFeedback.lightImpact();
  }

  Color _getBackgroundColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return Colors.white;
      case AppThemeMode.dark:
        return const Color(0xFF1E1E1E);
      case AppThemeMode.amoled:
        return Colors.black;
    }
  }

  Color _getCardColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return const Color(0xFFF5F5F5);
      case AppThemeMode.dark:
        return const Color(0xFF2C2C2C);
      case AppThemeMode.amoled:
        return const Color(0xFF0A0A0A);
    }
  }

  Color _getBorderColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return const Color(0xFFE0E0E0);
      case AppThemeMode.dark:
        return const Color(0xFF3A3A3A);
      case AppThemeMode.amoled:
        return const Color(0xFF1A1A1A);
    }
  }

  Color _getTextColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return Colors.black87;
      case AppThemeMode.dark:
        return Colors.white;
      case AppThemeMode.amoled:
        return Colors.white;
    }
  }

  Color _getSecondaryTextColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return Colors.grey[600]!;
      case AppThemeMode.dark:
        return Colors.grey[400]!;
      case AppThemeMode.amoled:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final backgroundColor = _getBackgroundColor(theme);
    final cardColor = _getCardColor(theme);
    final borderColor = _getBorderColor(theme);
    final textColor = _getTextColor(theme);
    final secondaryTextColor = _getSecondaryTextColor(theme);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Goals',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.pop(context, _selected),
            child: Text(
              'Save',
              style: TextStyle(
                color: _selected.isEmpty
                    ? (theme == AppThemeMode.light
                          ? Colors.grey
                          : Colors.grey[600])
                    : AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.primaryGreen.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _selected.isEmpty
                          ? 'Select one or more goals that resonate with you'
                          : '${_selected.length} goal${_selected.length > 1 ? 's' : ''} selected',
                      key: ValueKey(_selected.length),
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selected.contains(goal['title']);
                final scaleAnimation = _scaleAnimations[goal['title']]!;
                final checkAnimation = _checkAnimations[goal['title']]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedBuilder(
                    animation: scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.0 : scaleAnimation.value,
                        child: GestureDetector(
                          onTap: () => _toggleGoal(goal['title']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? goal['color'].withOpacity(0.1)
                                  : cardColor,
                              border: Border.all(
                                color: isSelected ? goal['color'] : borderColor,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: goal['color'].withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: goal['color'].withOpacity(
                                      isSelected ? 0.2 : 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    goal['icon'],
                                    color: goal['color'],
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        style: AppTextStyles.bodyLarge(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? goal['color']
                                                  : textColor,
                                            ),
                                        child: Text(goal['title']),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goal['description'],
                                        style: AppTextStyles.bodySmall(
                                          context,
                                        ).copyWith(color: secondaryTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isSelected ? 28 : 0,
                                  child: isSelected
                                      ? ScaleTransition(
                                          scale: checkAnimation,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: goal['color'],
                                            size: 28,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
