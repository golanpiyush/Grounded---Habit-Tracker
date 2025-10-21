// ============= EDIT TARGET DATE SCREEN =============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grounded/theme/app_colors.dart';
import 'package:grounded/theme/app_text_styles.dart';
import 'package:grounded/providers/theme_provider.dart';

class EditTargetDateScreen extends ConsumerStatefulWidget {
  final DateTime? currentTargetDate;
  final String? currentTimeline;

  const EditTargetDateScreen({
    Key? key,
    this.currentTargetDate,
    this.currentTimeline,
  }) : super(key: key);

  @override
  ConsumerState<EditTargetDateScreen> createState() =>
      _EditTargetDateScreenState();
}

class _EditTargetDateScreenState extends ConsumerState<EditTargetDateScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _timelines = [
    {'label': '30 days', 'days': 30, 'icon': Icons.calendar_today},
    {'label': '60 days', 'days': 60, 'icon': Icons.calendar_month},
    {'label': '90 days', 'days': 90, 'icon': Icons.event},
    {'label': '6 months', 'days': 180, 'icon': Icons.calendar_view_month},
    {'label': '1 year', 'days': 365, 'icon': Icons.calendar_view_day},
  ];

  String? _selectedTimeline;
  DateTime? _targetDate;
  DateTime? _customDate;

  late AnimationController _progressCardController;
  late AnimationController _listController;
  late Animation<double> _progressCardAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTimeline = widget.currentTimeline;
    _targetDate = widget.currentTargetDate;

    _progressCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressCardAnimation = CurvedAnimation(
      parent: _progressCardController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutBack,
    );

    _progressCardController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _progressCardController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _selectTimeline(String label, int days) {
    setState(() {
      _selectedTimeline = label;
      _targetDate = DateTime.now().add(Duration(days: days));
      _customDate = null;
    });
    HapticFeedback.lightImpact();
    _progressCardController.reset();
    _progressCardController.forward();
  }

  Future<void> _pickCustomDate() async {
    final themeMode = ref.read(themeProvider);
    final isDark =
        themeMode == AppThemeMode.dark || themeMode == AppThemeMode.amoled;
    final cardColor = _getCardColor(themeMode);
    final textColor = _getTextPrimaryColor(themeMode);

    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final daysUntil = picked.difference(DateTime.now()).inDays;
      setState(() {
        _customDate = picked;
        _targetDate = picked;
        _selectedTimeline = 'Custom ($daysUntil days)';
      });
      HapticFeedback.mediumImpact();
      _progressCardController.reset();
      _progressCardController.forward();
    }
  }

  int _getDaysRemaining() {
    if (_targetDate == null) return 0;
    return _targetDate!.difference(DateTime.now()).inDays;
  }

  String _getFormattedDate() {
    if (_targetDate == null) return '';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[_targetDate!.month - 1]} ${_targetDate!.day}, ${_targetDate!.year}';
  }

  Color _getBackgroundColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.amoled:
        return const Color(0xFF000000);
      default:
        return AppColors.background;
    }
  }

  Color _getCardColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF2D2D2D);
      case AppThemeMode.amoled:
        return const Color(0xFF0D0D0D);
      default:
        return AppColors.card;
    }
  }

  Color _getTextPrimaryColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFFFFFFFF);
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getTextSecondaryColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFFB0B0B0);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getBorderColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF404040);
      case AppThemeMode.amoled:
        return const Color(0xFF1A1A1A);
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final backgroundColor = _getBackgroundColor(themeMode);
    final cardColor = _getCardColor(themeMode);
    final textPrimary = _getTextPrimaryColor(themeMode);
    final textSecondary = _getTextSecondaryColor(themeMode);
    final borderColor = _getBorderColor(themeMode);

    final daysRemaining = _getDaysRemaining();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Target Date',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _targetDate == null
                ? null
                : () => Navigator.pop(context, {
                    'timeline': _selectedTimeline,
                    'target_date': _targetDate,
                  }),
            child: Text(
              'Save',
              style: TextStyle(
                color: _targetDate == null
                    ? textSecondary
                    : AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Progress Card
            if (_targetDate != null) ...[
              FadeTransition(
                opacity: _progressCardAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(_progressCardAnimation),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Target Date',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFormattedDate(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            TweenAnimationBuilder<double>(
                              key: ValueKey(
                                _targetDate,
                              ), // Add key to retrigger animation
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves
                                  .easeOutBack, // Add curve for smoother animation
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.flag,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Days Remaining',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TweenAnimationBuilder<int>(
                                    duration: const Duration(milliseconds: 800),
                                    tween: IntTween(
                                      begin: 0,
                                      end: daysRemaining,
                                    ),
                                    builder: (context, value, child) {
                                      return Text(
                                        '$value',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Timeline',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedTimeline ?? 'Not set',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Quick Timeline Selection
            Text(
              'Quick Select',
              style: AppTextStyles.headlineSmall(
                context,
              ).copyWith(fontSize: 18, color: textPrimary),
            ),
            const SizedBox(height: 16),
            ...(_timelines.asMap().entries.map((entry) {
              final index = entry.key;
              final timeline = entry.value;
              final isSelected = _selectedTimeline == timeline['label'];

              return AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final delay = index * 0.15;
                  final animValue = (_scaleAnimation.value - delay).clamp(
                    0.0,
                    1.0,
                  );
                  final curvedValue = Curves.easeOutCubic.transform(animValue);

                  return Transform.scale(
                    scale: 0.8 + (curvedValue * 0.2),
                    child: Opacity(opacity: curvedValue, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () =>
                        _selectTimeline(timeline['label'], timeline['days']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : cardColor,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen.withOpacity(0.15)
                                  : borderColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              timeline['icon'],
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeline['label'],
                                  style: AppTextStyles.bodyLarge(context)
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primaryGreen
                                            : textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${timeline['days']} days from today',
                                  style: AppTextStyles.bodySmall(
                                    context,
                                  ).copyWith(color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                          AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.primaryGreen,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList()),

            const SizedBox(height: 24),

            // Custom Date Picker
            Text(
              'Custom Date',
              style: AppTextStyles.headlineSmall(
                context,
              ).copyWith(fontSize: 18, color: textPrimary),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickCustomDate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _customDate != null
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : cardColor,
                  border: Border.all(
                    color: _customDate != null
                        ? AppColors.primaryGreen
                        : borderColor,
                    width: _customDate != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _customDate != null
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _customDate != null
                            ? AppColors.primaryGreen.withOpacity(0.15)
                            : borderColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: _customDate != null
                            ? AppColors.primaryGreen
                            : textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customDate != null
                                ? 'Custom Date Selected'
                                : 'Pick Custom Date',
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: _customDate != null
                                  ? AppColors.primaryGreen
                                  : textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _customDate != null
                                ? _getFormattedDate()
                                : 'Choose any date in the future',
                            style: AppTextStyles.bodySmall(
                              context,
                            ).copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _customDate != null
                            ? Icons.check_circle
                            : Icons.chevron_right,
                        key: ValueKey(_customDate != null),
                        color: _customDate != null
                            ? AppColors.primaryGreen
                            : textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Setting a target date helps you stay motivated and track your progress towards your recovery goals.',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: AppColors.primaryGreen, height: 1.4),
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
}
