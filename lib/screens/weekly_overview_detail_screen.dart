// Create this as a new file: lib/screens/User-Detials-Screens/weekly_overview_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/models/user_weekly_model.dart';
import 'package:Grounded/models/userdailyentrymodel.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:Grounded/utils/emoji_assets.dart';

class WeeklyOverviewDetailScreen extends ConsumerWidget {
  final List<WeeklyData> weeklyData;

  const WeeklyOverviewDetailScreen({Key? key, required this.weeklyData})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    // Check if we have any weekly data with actual logs
    final hasData = weeklyData.any((d) => d.hasLog);

    if (!hasData) {
      return _buildEmptyState(context, currentTheme);
    }

    // Calculate statistics - FIXED to only count days with actual mindful logs
    final mindfulDays = weeklyData
        .where(
          (d) => d.dayType == DayType.mindful && d.hasLog,
        ) // ADDED: && d.hasLog
        .length;
    final reducedDays = weeklyData
        .where((d) => d.dayType == DayType.reduced)
        .length;
    final usedDays = weeklyData.where((d) => d.dayType == DayType.used).length;

    // Calculate total days with actual logs (not empty/missing days)
    final totalLoggedDays = weeklyData.where((d) => d.hasLog).length; // ADDED
    final mindfulPercentage = totalLoggedDays > 0
        ? ((mindfulDays / totalLoggedDays) * 100).round()
        : 0; // FIXED: Use actual logged days, not total 7

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColorsTheme.getCard(currentTheme),
                        border: Border.all(
                          color: AppColorsTheme.getBorder(currentTheme),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Overview',
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontSize: 20,
                            color: AppColorsTheme.getTextPrimary(currentTheme),
                          ),
                        ),
                        Text(
                          'Last 7 days',
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColorsTheme.getTextSecondary(
                              currentTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.successGreen.withOpacity(0.1),
                            AppColors.successGreen.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.successGreen.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen.withOpacity(
                                    0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '$mindfulPercentage%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Week Success Rate',
                                      style: AppTextStyles.bodyLarge(context)
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                AppColorsTheme.getTextPrimary(
                                                  currentTheme,
                                                ),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$mindfulDays out of 7 mindful days',
                                      style: AppTextStyles.bodySmall(context)
                                          .copyWith(
                                            color:
                                                AppColorsTheme.getTextSecondary(
                                                  currentTheme,
                                                ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Weekly Chart
                    Text(
                      'Daily Breakdown',
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontSize: 18,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.getCard(currentTheme),
                        border: Border.all(
                          color: AppColorsTheme.getBorder(currentTheme),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: weeklyData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value;
                                final isToday = index == weeklyData.length - 1;
                                return _buildWeeklyBar(
                                  data,
                                  isToday,
                                  currentTheme,
                                  context,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLegend(currentTheme, context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics
                    Text(
                      'Statistics',
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontSize: 18,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildStatRow(
                      context,
                      currentTheme,
                      EmojiAssets.checkmark,
                      'Mindful Days',
                      '$mindfulDays days',
                      AppColors.successGreen,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      currentTheme,
                      EmojiAssets.target,
                      'Reduced Days',
                      '$reducedDays days',
                      AppColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      currentTheme,
                      EmojiAssets.calendar,
                      'Used Days',
                      '$usedDays days',
                      const Color(0xFF6B7280),
                    ),

                    const SizedBox(height: 24),

                    // Encouragement Message
                    _buildEncouragementCard(
                      context,
                      currentTheme,
                      mindfulPercentage,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppThemeMode currentTheme) {
    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColorsTheme.getCard(currentTheme),
                        border: Border.all(
                          color: AppColorsTheme.getBorder(currentTheme),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Overview',
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontSize: 20,
                            color: AppColorsTheme.getTextPrimary(currentTheme),
                          ),
                        ),
                        Text(
                          'Last 7 days',
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColorsTheme.getTextSecondary(
                              currentTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Empty State Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(EmojiAssets.chartUp, width: 80, height: 80),
                      const SizedBox(height: 24),
                      Text(
                        'No Data Yet',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontSize: 24,
                          color: AppColorsTheme.getTextPrimary(currentTheme),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start logging your daily entries to see\nyour weekly progress and insights',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Log at least one day to view your weekly overview',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                      color: AppColorsTheme.getTextSecondary(
                                        currentTheme,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBar(
    WeeklyData data,
    bool isToday,
    AppThemeMode currentTheme,
    BuildContext context,
  ) {
    Color barColor;
    switch (data.dayType) {
      case DayType.mindful:
        barColor = AppColors.successGreen;
        break;
      case DayType.reduced:
        barColor = AppColors.accentOrange;
        break;
      case DayType.used:
        barColor = AppColors.secondaryGreen;
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 36,
          height: data.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [barColor, barColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: barColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.day,
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
            color: isToday
                ? AppColors.primaryGreen
                : AppColorsTheme.getTextSecondary(currentTheme),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(AppThemeMode currentTheme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          currentTheme,
          AppColors.successGreen,
          'Mindful',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          currentTheme,
          AppColors.accentOrange,
          'Reduced',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          context,
          currentTheme,
          AppColors.secondaryGreen,
          'Used',
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    AppThemeMode currentTheme,
    Color color,
    String label,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(
            context,
          ).copyWith(color: AppColorsTheme.getTextSecondary(currentTheme)),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    AppThemeMode currentTheme,
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(emoji, width: 20, height: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEncouragementCard(
    BuildContext context,
    AppThemeMode currentTheme,
    int percentage,
  ) {
    String emoji;
    String title;
    String message;

    if (percentage >= 80) {
      emoji = EmojiAssets.trophy;
      title = 'Excellent Week!';
      message = 'You\'re doing amazing! Keep up the great work.';
    } else if (percentage >= 60) {
      emoji = EmojiAssets.chartUp;
      title = 'Great Progress!';
      message = 'You\'re making solid progress. Stay focused!';
    } else if (percentage >= 40) {
      emoji = EmojiAssets.target;
      title = 'Keep Going!';
      message = 'Every step counts. You\'re on the right path.';
    } else {
      emoji = EmojiAssets.lightbulb;
      title = 'New Week Ahead';
      message = 'Remember why you started. You\'ve got this!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(emoji, width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColorsTheme.getTextSecondary(currentTheme),
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
