import 'package:Grounded/providers/stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class MoneySavedDetailScreen extends ConsumerStatefulWidget {
  final double moneySaved;

  const MoneySavedDetailScreen({Key? key, required this.moneySaved})
    : super(key: key);

  @override
  ConsumerState<MoneySavedDetailScreen> createState() =>
      _MoneySavedDetailScreenState();
}

class _MoneySavedDetailScreenState extends ConsumerState<MoneySavedDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _numberController;
  late Animation<double> _numberAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _numberAnimation = Tween<double>(begin: 0, end: widget.moneySaved).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _numberController.forward();
    });

    // Load data using provider
    Future.microtask(() {
      ref.read(moneySavedStatsProvider.notifier).loadMoneySavedData();
    });
  }

  Future<void> _refreshData() async {
    await ref.read(moneySavedStatsProvider.notifier).loadMoneySavedData();
  }

  void _onFilterChanged(String? newValue) {
    if (newValue != null) {
      HapticFeedback.lightImpact();
      ref
          .read(moneySavedStatsProvider.notifier)
          .loadMoneySavedData(filter: newValue);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  String _getSubtitleText(MoneySavedStats state) {
    final filter = state.selectedFilter;
    switch (filter) {
      case 'This Month':
        return 'This month\'s savings';
      case 'Last 30 Days':
        return 'Last 30 days\' savings';
      case 'Last 90 Days':
        return 'Last 90 days\' savings';
      case 'All Time':
        return 'Total lifetime savings';
      default:
        return 'Savings';
    }
  }

  String _getMonthAbbr(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getDayLabel(DateTime date, DateTime now) {
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _getDayName(date.weekday);
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final statsState = ref.watch(moneySavedStatsProvider);
    final isDark = themeMode != AppThemeMode.light;
    final isAmoled = themeMode == AppThemeMode.amoled;

    // Theme-aware colors
    final backgroundColor = isAmoled
        ? Colors.black
        : (isDark ? const Color(0xFF1A1A1A) : AppColors.background);

    final cardColor = isAmoled
        ? const Color(0xFF0D0D0D)
        : (isDark ? const Color(0xFF2A2A2A) : AppColors.card);

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondary;

    final shimmerBaseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final shimmerHighlightColor = isDark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth > 600
        ? 32.0
        : (screenWidth > 400 ? 20.0 : 16.0);
    final verticalPadding = screenHeight > 800 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Money Saved',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: textPrimary),
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              _refreshData();
            },
          ),
        ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildMoneyHeader(
                        screenWidth,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        statsState,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth > 400 ? 16 : 12),
                _buildFilterDropdown(
                  cardColor,
                  textPrimary,
                  textSecondary,
                  statsState,
                ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                statsState.isLoading
                    ? _buildStatsShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : _buildMoneyStats(
                        screenWidth,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        statsState,
                      ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                statsState.isLoading
                    ? _buildBreakdownShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : _buildSavingsBreakdown(
                        screenWidth,
                        cardColor,
                        textPrimary,
                        textSecondary,
                        statsState,
                      ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                Text(
                  'Your Journey',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                statsState.isLoading
                    ? _buildDailySavingsShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : statsState.dailySavings.isEmpty
                    ? _buildEmptyState(textSecondary)
                    : Column(
                        children: statsState.dailySavings
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildSavingsItem(
                                entry.value,
                                screenWidth,
                                cardColor,
                                textPrimary,
                                textSecondary,
                                delay: entry.key * 100,
                              ),
                            )
                            .toList(),
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    MoneySavedStats state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: state.selectedFilter,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: textPrimary),
        dropdownColor: cardColor,
        style: AppTextStyles.bodyMedium(
          context,
        ).copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        items: ['This Month', 'Last 30 Days', 'Last 90 Days', 'All Time'].map((
          String value,
        ) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: _onFilterChanged,
      ),
    );
  }

  Widget _buildMoneyHeader(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    MoneySavedStats state,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 24.0 : (isSmallScreen ? 16.0 : 20.0);
    final iconSize = screenWidth > 400 ? 80.0 : (isSmallScreen ? 60.0 : 70.0);
    final fontSize = screenWidth > 400 ? 56.0 : (isSmallScreen ? 44.0 : 48.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.successGreen.withOpacity(0.15),
            AppColors.successGreen.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.2),
              child: Image.asset(EmojiAssets.moneyBag),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _numberAnimation,
            builder: (context, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${_numberAnimation.value.toInt()}',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Total Saved',
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _getSubtitleText(state),
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStats(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    MoneySavedStats state,
  ) {
    final spacing = screenWidth > 400 ? 12.0 : 8.0;

    return Row(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: _fadeController,
            child: _buildStatBox(
              emoji: EmojiAssets.chartUp,
              value:
                  '\$${state.dailyAverage.toStringAsFixed(0)}', // Remove decimals
              label: 'Save Per Day',
              color: const Color(0xFF3B82F6),
              screenWidth: screenWidth,
              cardColor: cardColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: FadeTransition(
            opacity: _fadeController,
            child: _buildStatBox(
              emoji: EmojiAssets.target,
              value: '\$${state.yearlyProjection.toInt()}',
              label: 'Yearly Potential',
              color: const Color(0xFFA855F7),
              screenWidth: screenWidth,
              cardColor: cardColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
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
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = screenWidth > 400 ? 36.0 : (isSmallScreen ? 28.0 : 32.0);
    final fontSize = screenWidth > 400 ? 24.0 : (isSmallScreen ? 20.0 : 22.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBreakdown(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    MoneySavedStats state,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 20.0 : (isSmallScreen ? 14.0 : 16.0);
    final totalFontSize = screenWidth > 400
        ? 24.0
        : (isSmallScreen ? 20.0 : 22.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actual Savings',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            emoji: EmojiAssets.checkmark,
            label: 'Mindful Days',
            amount: state.mindfulDaysSavings,
            color: AppColors.successGreen,
            screenWidth: screenWidth,
            textPrimary: textPrimary,
          ),
          const SizedBox(height: 12),
          _buildBreakdownItem(
            emoji: EmojiAssets.target,
            label: 'Reduced Days',
            amount: state.reducedDaysSavings,
            color: AppColors.accentOrange,
            screenWidth: screenWidth,
            textPrimary: textPrimary,
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.border.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  'Total Saved',
                  style: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700, color: textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\$${state.totalSaved.toInt()}',
                    style: TextStyle(
                      fontSize: totalFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String emoji,
    required String label,
    required double amount,
    required Color color,
    required double screenWidth,
    required Color textPrimary,
  }) {
    final isSmallScreen = screenWidth < 360;
    final iconSize = screenWidth > 400 ? 32.0 : (isSmallScreen ? 26.0 : 28.0);
    final emojiSize = screenWidth > 400 ? 16.0 : (isSmallScreen ? 13.0 : 14.0);

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(emoji, width: emojiSize, height: emojiSize),
          ),
        ),
        SizedBox(width: screenWidth > 400 ? 12 : 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '\$${amount.toInt()}',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsItem(
    Map<String, dynamic> day,
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary, {
    int delay = 0,
  }) {
    final saved = day['saved'] as double;
    final type = day['type'] as String;
    final isSmallScreen = screenWidth < 360;

    final iconSize = screenWidth > 400 ? 44.0 : (isSmallScreen ? 36.0 : 40.0);
    final emojiSize = screenWidth > 400 ? 20.0 : (isSmallScreen ? 16.0 : 18.0);
    final amountFontSize = screenWidth > 400
        ? 20.0
        : (isSmallScreen ? 16.0 : 18.0);

    Color badgeColor;
    String badgeText;

    if (type == 'mindful') {
      badgeColor = AppColors.successGreen;
      badgeText = 'Mindful';
    } else if (type == 'reduced') {
      badgeColor = AppColors.accentOrange;
      badgeText = 'Reduced';
    } else {
      badgeColor = textSecondary;
      badgeText = 'Used';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(
        screenWidth > 400 ? 16 : (isSmallScreen ? 12 : 14),
      ),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: saved > 0
                  ? AppColors.successGreen.withOpacity(0.1)
                  : saved < 0
                  ? Colors.red.withOpacity(0.1)
                  : textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: saved > 0
                  ? Image.asset(
                      EmojiAssets.moneyBag,
                      width: emojiSize,
                      height: emojiSize,
                    )
                  : saved < 0
                  ? Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: emojiSize,
                    )
                  : Icon(Icons.close, color: textSecondary, size: emojiSize),
            ),
          ),
          SizedBox(width: screenWidth > 400 ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day['day'],
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      day['date'],
                      style: AppTextStyles.caption(
                        context,
                      ).copyWith(color: textSecondary),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 5 : 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTextStyles.caption(context).copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 9 : 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              saved > 0 ? '\${saved.toInt()}' : '\$0',
              style: TextStyle(
                fontSize: amountFontSize,
                fontWeight: FontWeight.w700,
                color: saved > 0 ? AppColors.successGreen : textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer for stats
  Widget _buildStatsShimmer(
    double screenWidth,
    Color baseColor,
    Color highlightColor,
  ) {
    final spacing = screenWidth > 400 ? 12.0 : 8.0;
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: screenWidth > 400 ? 36.0 : 28.0,
                    height: screenWidth > 400 ? 36.0 : 28.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: screenWidth > 400 ? 12 : 8),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: screenWidth > 400 ? 36.0 : 28.0,
                    height: screenWidth > 400 ? 36.0 : 28.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: screenWidth > 400 ? 12 : 8),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer for breakdown
  Widget _buildBreakdownShimmer(
    double screenWidth,
    Color baseColor,
    Color highlightColor,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 20.0 : (isSmallScreen ? 14.0 : 16.0);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownItemShimmer(screenWidth),
            const SizedBox(height: 12),
            _buildBreakdownItemShimmer(screenWidth),
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItemShimmer(double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    final iconSize = screenWidth > 400 ? 32.0 : (isSmallScreen ? 26.0 : 28.0);

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(width: screenWidth > 400 ? 12 : 8),
        Expanded(
          child: Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 50,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // Shimmer for daily savings list
  Widget _buildDailySavingsShimmer(
    double screenWidth,
    Color baseColor,
    Color highlightColor,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = screenWidth > 400 ? 44.0 : (isSmallScreen ? 36.0 : 40.0);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          7,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: screenWidth > 400 ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Empty state when no data
  Widget _buildEmptyState(Color textSecondary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No days logged yet',
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your days to track your savings',
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
