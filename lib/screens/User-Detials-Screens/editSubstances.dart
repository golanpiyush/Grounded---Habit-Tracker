// ============= EDIT SUBSTANCES SCREEN =============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/providers/theme_provider.dart';

class EditSubstancesScreen extends ConsumerStatefulWidget {
  final List<String>? selectedSubstances;

  const EditSubstancesScreen({Key? key, this.selectedSubstances})
    : super(key: key);

  @override
  ConsumerState<EditSubstancesScreen> createState() =>
      _EditSubstancesScreenState();
}

class _EditSubstancesScreenState extends ConsumerState<EditSubstancesScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _substances = [
    {
      'name': 'Alcohol',
      'icon': '🍻',
      'color': const Color(0xFFEF5350),
      'gradient': [
        const Color(0xFFEF5350),
        const Color.fromARGB(255, 31, 30, 30),
      ],
    },
    {
      'name': 'Cannabis',
      'icon': '🌿',
      'color': const Color(0xFF66BB6A),
      'gradient': [
        const Color(0xFF66BB6A),
        const Color.fromARGB(255, 30, 31, 30),
      ],
    },
    {
      'name': 'Tobacco',
      'icon': '🚬',
      'color': const Color(0xFF8D6E63),
      'gradient': [
        const Color(0xFF8D6E63),
        const Color.fromARGB(255, 31, 30, 30),
      ],
    },
    {
      'name': 'Caffeine',
      'icon': '☕',
      'color': const Color(0xFF6D4C41),
      'gradient': [
        const Color(0xFF6D4C41),
        const Color.fromARGB(255, 27, 27, 27),
      ],
    },
    {
      'name': 'Vaping',
      'icon': '💨',
      'color': const Color(0xFF5C6BC0),
      'gradient': [
        const Color(0xFF5C6BC0),
        const Color.fromARGB(255, 23, 23, 24),
      ],
    },
    {
      'name': 'Prescription',
      'icon': '💊',
      'color': const Color(0xFFAB47BC),
      'gradient': [
        const Color(0xFFAB47BC),
        const Color.fromARGB(255, 34, 34, 34),
      ],
    },
    {
      'name': 'Cocaine',
      'icon': '❄️',
      'color': const Color(0xFF78909C),
      'gradient': [
        const Color.fromARGB(255, 68, 184, 241),
        const Color.fromARGB(255, 32, 32, 32),
      ],
    },
    {
      'name': 'Heroin',
      'icon': '⚗️',
      'color': const Color(0xFF5D4037),
      'gradient': [
        const Color(0xFF5D4037),
        const Color.fromARGB(255, 37, 37, 37),
      ],
    },
    {
      'name': 'Fentanyl',
      'icon': '⚠️',
      'color': const Color(0xFFD32F2F),
      'gradient': [
        const Color(0xFFD32F2F),
        const Color.fromARGB(255, 34, 34, 33),
      ],
    },
    {
      'name': 'Meth',
      'icon': '🧊',
      'color': const Color(0xFF00796B),
      'gradient': [
        const Color(0xFF00796B),
        const Color.fromARGB(255, 35, 36, 36),
      ],
    },
    {
      'name': 'MDMA',
      'icon': '✨',
      'color': const Color(0xFF7B1FA2),
      'gradient': [
        const Color(0xFF7B1FA2),
        const Color.fromARGB(255, 24, 23, 24),
      ],
    },
    {
      'name': 'LSD',
      'icon': '🌈',
      'color': const Color(0xFFE91E63),
      'gradient': [
        const Color(0xFFE91E63),
        const Color.fromARGB(255, 31, 30, 30),
      ],
    },
    {
      'name': 'Psilocybin',
      'icon': '🍄',
      'color': const Color(0xFF66BB6A),
      'gradient': [
        const Color.fromARGB(255, 53, 165, 128),
        const Color(0xFF66BB6A),
      ],
    },
    {
      'name': 'Ketamine',
      'icon': '🌀',
      'color': const Color(0xFF2196F3),
      'gradient': [
        const Color.fromARGB(255, 37, 40, 43),
        const Color.fromARGB(255, 43, 64, 250),
      ],
    },
    {
      'name': 'Benzos',
      'icon': '🚀',
      'color': const Color(0xFFFF9800),
      'gradient': [
        const Color.fromARGB(255, 34, 34, 34),
        const Color(0xFFFFB74D),
      ],
    },
    {
      'name': 'Opioids',
      'icon': '⚕️',
      'color': const Color(0xFF795548),
      'gradient': [
        const Color.fromARGB(255, 26, 25, 25),
        const Color.fromARGB(255, 28, 100, 182),
      ],
    },
    {
      'name': 'Amphetamines',
      'icon': '⚡',
      'color': const Color(0xFFFFC107),
      'gradient': [const Color.fromARGB(255, 0, 0, 0), const Color(0xFFFFD54F)],
    },
    {
      'name': 'Sugar',
      'icon': '🍬',
      'color': const Color(0xFFEC407A),
      'gradient': [
        const Color.fromARGB(255, 32, 32, 32),
        const Color(0xFFF06292),
      ],
    },
    {
      'name': 'Other',
      'icon': '🔬',
      'color': const Color(0xFF42A5F5),
      'gradient': [
        const Color.fromARGB(255, 23, 24, 24),
        const Color(0xFF64B5F6),
      ],
    },
  ];

  late List<String> _selected;
  String? _primarySubstance;
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};
  final Map<String, Animation<double>> _checkAnimations = {};

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedSubstances ?? []);
    _primarySubstance = _selected.isNotEmpty ? _selected.first : null;

    // Initialize animation controllers for each substance
    for (var substance in _substances) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animationControllers[substance['name']] = controller;

      _scaleAnimations[substance['name']] = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _checkAnimations[substance['name']] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

      // Set initial state for selected items
      if (_selected.contains(substance['name'])) {
        controller.value = 1.0;
      }
    }

    // Sort to show selected items first, with primary at the very top
    _substances.sort((a, b) {
      bool aSelected = _selected.contains(a['name']);
      bool bSelected = _selected.contains(b['name']);
      bool aPrimary = a['name'] == _primarySubstance;
      bool bPrimary = b['name'] == _primarySubstance;

      if (aPrimary) return -1;
      if (bPrimary) return 1;
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return 0;
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSubstance(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
        _animationControllers[name]?.reverse();
        if (_primarySubstance == name) {
          _primarySubstance = _selected.isNotEmpty ? _selected.first : null;
        }
      } else {
        _selected.add(name);
        _animationControllers[name]?.forward();
        if (_primarySubstance == null) {
          _primarySubstance = name;
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _setPrimary(String name) {
    if (_selected.contains(name)) {
      setState(() {
        _primarySubstance = name;
        _selected.remove(name);
        _selected.insert(0, name);
      });
      HapticFeedback.mediumImpact();
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final backgroundColor = _getBackgroundColor(theme);
    final cardColor = _getCardColor(theme);
    final borderColor = _getBorderColor(theme);
    final textColor = _getTextColor(theme);

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
          'Edit Substances',
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
                          ? 'Select one or more substances that you use'
                          : '${_selected.length} substance${_selected.length > 1 ? 's' : ''} selected • Tap primary star to change main substance',
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
              itemCount: _substances.length,
              itemBuilder: (context, index) {
                final substance = _substances[index];
                final isSelected = _selected.contains(substance['name']);
                final isPrimary = substance['name'] == _primarySubstance;
                final scaleAnimation = _scaleAnimations[substance['name']]!;
                final checkAnimation = _checkAnimations[substance['name']]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedBuilder(
                    animation: scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.0 : scaleAnimation.value,
                        child: GestureDetector(
                          onTap: () => _toggleSubstance(substance['name']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? substance['color'].withOpacity(0.1)
                                  : cardColor,
                              border: Border.all(
                                color: isSelected
                                    ? substance['color']
                                    : borderColor,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: substance['color'].withOpacity(
                                          0.3,
                                        ),
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
                                    gradient: LinearGradient(
                                      colors: substance['gradient'],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      substance['icon'],
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: AppTextStyles.bodyLarge(context)
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? substance['color']
                                              : textColor,
                                        ),
                                    child: Text(substance['name']),
                                  ),
                                ),
                                if (isSelected) ...[
                                  GestureDetector(
                                    onTap: () => _setPrimary(substance['name']),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        isPrimary
                                            ? Icons.star
                                            : Icons.star_border,
                                        key: ValueKey(isPrimary),
                                        color: isPrimary
                                            ? Colors.amber
                                            : (theme == AppThemeMode.light
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400]),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ScaleTransition(
                                    scale: checkAnimation,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: substance['color'],
                                      size: 28,
                                    ),
                                  ),
                                ],
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
