import 'package:Grounded/providers/stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/providers/userDB.dart';

import 'package:shimmer/shimmer.dart';

class WeeklyAvgDetailScreen extends ConsumerStatefulWidget {
  final double weeklyAverage;

  const WeeklyAvgDetailScreen({Key? key, required this.weeklyAverage})
    : super(key: key);

  @override
  ConsumerState<WeeklyAvgDetailScreen> createState() =>
      _WeeklyAvgDetailScreenState();
}

class _WeeklyAvgDetailScreenState extends ConsumerState<WeeklyAvgDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _barController;
  late AnimationController _numberController;
  late Animation<double> _numberAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _numberAnimation = Tween<double>(begin: 0.0, end: widget.weeklyAverage)
        .animate(
          CurvedAnimation(
            parent: _numberController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _numberController.forward();
        _barController.forward();
      }
    });

    // Load data using provider
    Future.microtask(() {
      ref
          .read(weeklyStatsProvider.notifier)
          .loadWeeklyData(widget.weeklyAverage);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _barController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return AppColors.background;
      case AppThemeMode.dark:
        return const Color(0xFF121212);
      case AppThemeMode.amoled:
        return Colors.black;
    }
  }

  Color _getCardColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return AppColors.card;
      case AppThemeMode.dark:
        return const Color(0xFF1E1E1E);
      case AppThemeMode.amoled:
        return const Color(0xFF0A0A0A);
    }
  }

  Color _getBorderColor(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return AppColors.border;
      case AppThemeMode.dark:
        return const Color(0xFF2A2A2A);
      case AppThemeMode.amoled:
        return const Color(0xFF1A1A1A);
    }
  }

  Color _getTextPrimary(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return AppColors.textPrimary;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getTextSecondary(AppThemeMode theme) {
    switch (theme) {
      case AppThemeMode.light:
        return AppColors.textSecondary;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    final weeklyState = ref.watch(weeklyStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth > 600
        ? 32.0
        : (screenWidth > 400 ? 20.0 : 16.0);
    final verticalPadding = screenHeight > 800 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: _getBackgroundColor(theme),
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(theme),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _getTextPrimary(theme)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Weekly Average',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: _getTextPrimary(theme)),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeeklyHeader(screenWidth, theme, weeklyState),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                _buildWeeklyStats(screenWidth, theme, weeklyState),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                Text(
                  'Weekly Trends',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    color: _getTextPrimary(theme),
                  ),
                ),
                const SizedBox(height: 16),
                weeklyState.isLoading
                    ? _buildChartShimmer(screenWidth, theme)
                    : _buildWeeklyChart(screenWidth, theme, weeklyState),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                Text(
                  'Weekly History',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    color: _getTextPrimary(theme),
                  ),
                ),
                const SizedBox(height: 16),
                weeklyState.isLoading
                    ? _buildHistoryShimmer(screenWidth, theme)
                    : _buildWeeklyHistoryList(screenWidth, theme, weeklyState),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyHeader(
    double screenWidth,
    AppThemeMode theme,
    WeeklyStats state,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 24.0 : (isSmallScreen ? 16.0 : 20.0);
    final iconSize = screenWidth > 400 ? 80.0 : (isSmallScreen ? 60.0 : 70.0);
    final fontSize = screenWidth > 400 ? 56.0 : (isSmallScreen ? 44.0 : 48.0);
    final displayAverage = state.isLoading
        ? widget.weeklyAverage
        : state.weeklyAverage;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.15),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.2),
              child: Image.asset(EmojiAssets.barChart),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _numberAnimation,
            builder: (context, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayAverage.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: _getTextPrimary(theme),
                    height: 1,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Days Per Week',
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B82F6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            state.improvement > 0
                ? 'Your weekly average is improving'
                : state.improvement < 0
                ? 'Keep pushing forward'
                : 'Starting your journey',
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: _getTextSecondary(theme)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(
    double screenWidth,
    AppThemeMode theme,
    WeeklyStats state,
  ) {
    final spacing = screenWidth > 400 ? 12.0 : 8.0;

    // Format improvement as +/- days instead of percentage
    final improvementValue = state.improvement.abs();
    final improvementText = state.improvement > 0
        ? '+${improvementValue.toStringAsFixed(0)}'
        : state.improvement < 0
        ? '-${improvementValue.toStringAsFixed(0)}'
        : '0';

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            emoji: EmojiAssets.chartUp,
            value: improvementText,
            label: 'Days Change', // Changed from 'Improvement'
            color: state.improvement > 0
                ? AppColors.successGreen
                : state.improvement < 0
                ? AppColors.accentOrange
                : AppColors.textSecondary,
            screenWidth: screenWidth,
            theme: theme,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatBox(
            emoji: EmojiAssets.target,
            value: state.bestWeek > 0
                ? state.bestWeek.toStringAsFixed(1)
                : '0.0',
            label: 'Best Week',
            color: const Color(0xFFA855F7),
            screenWidth: screenWidth,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String emoji,
    required String value,
    required String label,
    required Color color,
    required double screenWidth,
    required AppThemeMode theme,
  }) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = screenWidth > 400 ? 36.0 : (isSmallScreen ? 28.0 : 32.0);
    final fontSize = screenWidth > 400 ? 24.0 : (isSmallScreen ? 20.0 : 22.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getCardColor(theme),
        border: Border.all(color: _getBorderColor(theme)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme == AppThemeMode.light ? 0.04 : 0.2,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.17),
              child: Image.asset(emoji),
            ),
          ),
          SizedBox(height: screenWidth > 400 ? 12 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: _getTextPrimary(theme),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: _getTextSecondary(theme)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartShimmer(double screenWidth, AppThemeMode theme) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 20.0 : (isSmallScreen ? 14.0 : 16.0);
    final chartHeight = screenWidth > 400
        ? 200.0
        : (isSmallScreen ? 160.0 : 180.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getCardColor(theme),
        border: Border.all(color: _getBorderColor(theme)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: theme == AppThemeMode.light
            ? Colors.grey[300]!
            : Colors.grey[800]!,
        highlightColor: theme == AppThemeMode.light
            ? Colors.grey[100]!
            : Colors.grey[700]!,
        child: SizedBox(
          height: chartHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              5,
              (index) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: screenWidth > 400 ? 40.0 : 34.0,
                    height: chartHeight * (0.4 + (index * 0.1)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(width: 30, height: 10, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryShimmer(double screenWidth, AppThemeMode theme) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);

    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: _getCardColor(theme),
            border: Border.all(color: _getBorderColor(theme)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Shimmer.fromColors(
            baseColor: theme == AppThemeMode.light
                ? Colors.grey[300]!
                : Colors.grey[800]!,
            highlightColor: theme == AppThemeMode.light
                ? Colors.grey[100]!
                : Colors.grey[700]!,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 12, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 40, height: 20, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 60, height: 16, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(
    double screenWidth,
    AppThemeMode theme,
    WeeklyStats state,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 20.0 : (isSmallScreen ? 14.0 : 16.0);
    final chartHeight = screenWidth > 400
        ? 200.0
        : (isSmallScreen ? 160.0 : 180.0);
    final barHeight = chartHeight * 0.7;

    // If no data or loading, show placeholder bars
    if (state.weeklyHistory == null || state.weeklyHistory!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: _getCardColor(theme),
          border: Border.all(color: _getBorderColor(theme)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme == AppThemeMode.light ? 0.04 : 0.2,
              ),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) {
                  final labels = ['This', 'Last', '2', '3', '4'];
                  final heights = [
                    0.3,
                    0.25,
                    0.35,
                    0.2,
                    0.28,
                  ]; // Varied small heights
                  return _buildBar(
                    height: barHeight * heights[index],
                    label: labels[index],
                    isHighlight: index == 0,
                    delay: index * 100,
                    screenWidth: screenWidth,
                    theme: theme,
                    isPlaceholder: true,
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging to see trends',
              style: AppTextStyles.caption(context).copyWith(
                color: _getTextSecondary(theme),
                fontSize: screenWidth > 400 ? 12 : 11,
              ),
            ),
          ],
        ),
      );
    }

    final history = state.weeklyHistory!;
    final maxValue = history
        .map((w) => w['average'] as double)
        .reduce((a, b) => a > b ? a : b);

    // If all values are 0, show small bars
    final hasData = maxValue > 0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getCardColor(theme),
        border: Border.all(color: _getBorderColor(theme)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme == AppThemeMode.light ? 0.04 : 0.2,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.asMap().entries.map((entry) {
                final index = entry.key;
                final week = entry.value;
                final weekAverage = week['average'] as double;

                // Calculate height
                final double height;
                if (!hasData) {
                  // Show varied small heights for visual appeal
                  final placeholderHeights = [0.3, 0.25, 0.35, 0.2, 0.28];
                  height =
                      barHeight *
                      (index < placeholderHeights.length
                          ? placeholderHeights[index]
                          : 0.25);
                } else {
                  final percentage = weekAverage / maxValue;
                  height = (barHeight * percentage).clamp(
                    barHeight * 0.15,
                    barHeight,
                  );
                }

                return _buildBar(
                  height: height,
                  label: week['week'].toString().split(' ')[0],
                  isHighlight: week['week'] == 'This Week',
                  delay: index * 100,
                  screenWidth: screenWidth,
                  theme: theme,
                  isPlaceholder: !hasData,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasData ? '' : 'Start logging to see trends',
            style: AppTextStyles.caption(context).copyWith(
              color: _getTextSecondary(theme),
              fontSize: screenWidth > 400 ? 12 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required double height,
    required String label,
    required bool isHighlight,
    required int delay,
    required double screenWidth,
    required AppThemeMode theme,
    bool isPlaceholder = false,
  }) {
    final barWidth = screenWidth > 400
        ? 40.0
        : (screenWidth < 360 ? 30.0 : 36.0);
    final fontSize = screenWidth > 400
        ? 11.0
        : (screenWidth < 360 ? 9.0 : 10.0);

    return AnimatedBuilder(
      animation: _barController,
      builder: (context, child) {
        final delayedProgress = (_barController.value - (delay / 1200)).clamp(
          0.0,
          1.0,
        );
        final animatedHeight =
            height * Curves.easeOutCubic.transform(delayedProgress);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 400 ? 6.0 : 4.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: barWidth,
                  height: animatedHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isPlaceholder
                          ? [
                              _getTextSecondary(theme).withOpacity(0.2),
                              _getTextSecondary(theme).withOpacity(0.1),
                            ]
                          : isHighlight
                          ? [
                              const Color(0xFF3B82F6),
                              const Color(0xFF3B82F6).withOpacity(0.8),
                            ]
                          : [
                              _getTextSecondary(theme).withOpacity(0.35),
                              _getTextSecondary(theme).withOpacity(0.25),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
                    color: isHighlight
                        ? const Color(0xFF3B82F6)
                        : _getTextSecondary(theme),
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyHistoryList(
    double screenWidth,
    AppThemeMode theme,
    WeeklyStats state,
  ) {
    if (state.weeklyHistory.isEmpty) {
      return _buildEmptyState(screenWidth, theme, 'No history available');
    }

    return Column(
      children: state.weeklyHistory
          .map((week) => _buildWeekItem(week, screenWidth, theme))
          .toList(),
    );
  }

  Widget _buildWeekItem(
    Map<String, dynamic> week,
    double screenWidth,
    AppThemeMode theme,
  ) {
    final average = week['average'] as double;

    // Higher average = more mindful days = better
    final trend = average >= 4.0
        ? 'excellent'
        : average >= 3.0
        ? 'improving'
        : average >= 2.0
        ? 'fair'
        : 'needs focus';

    final trendColor = average >= 4.0
        ? AppColors.successGreen
        : average >= 3.0
        ? const Color(0xFF10B981)
        : average >= 2.0
        ? AppColors.accentOrange
        : const Color(0xFFEF4444);

    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = screenWidth > 400 ? 44.0 : (isSmallScreen ? 36.0 : 40.0);
    final emojiSize = screenWidth > 400 ? 20.0 : (isSmallScreen ? 16.0 : 18.0);
    final valueFontSize = screenWidth > 400
        ? 20.0
        : (isSmallScreen ? 16.0 : 18.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _getCardColor(theme),
        border: Border.all(color: _getBorderColor(theme)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme == AppThemeMode.light ? 0.04 : 0.2,
            ),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                EmojiAssets.barChart,
                width: emojiSize,
                height: emojiSize,
              ),
            ),
          ),
          SizedBox(width: screenWidth > 400 ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  week['week'],
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextPrimary(theme),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${week['total']} mindful days',
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(color: _getTextSecondary(theme)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${week['average']}',
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.w700,
                    color: _getTextPrimary(theme),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.caption(context).copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 9 : 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    double screenWidth,
    AppThemeMode theme,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _getCardColor(theme),
        border: Border.all(color: _getBorderColor(theme)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: _getTextSecondary(theme),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: _getTextSecondary(theme)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
