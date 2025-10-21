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

  // Data state variables
  final _userDb = UserDatabaseService();
  bool _isLoading = true;
  double _totalSaved = 0.0;
  double _dailyAverage = 0.0;
  double _yearlyProjection = 0.0;
  double _mindfulDaysSavings = 0.0;
  double _reducedDaysSavings = 0.0;
  List<Map<String, dynamic>> _dailySavings = [];

  // Filter state
  String _selectedFilter = 'All Time';
  final List<String> _filterOptions = [
    'This Month',
    'Last 30 Days',
    'Last 90 Days',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Number counting animation
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _numberAnimation = Tween<double>(begin: 0, end: widget.moneySaved).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeOutCubic),
    );

    // Start animations in sequence
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _numberController.forward();
    });

    // Load real data
    _loadMoneySavedData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadMoneySavedData() async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get date range based on filter
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (_selectedFilter) {
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Last 30 Days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last 90 Days':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'All Time':
          // Get user creation date
          final userProfile = await _userDb.getUserProfile(userId);
          if (userProfile != null && userProfile['created_at'] != null) {
            startDate = DateTime.parse(userProfile['created_at']);
          } else {
            startDate = now.subtract(const Duration(days: 365)); // Fallback
          }
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Fetch logs for the period
      final logs = await _userDb.getLogsForRange(userId, startDate, endDate);

      // Get onboarding data to know substance costs
      final onboarding = await _userDb.getOnboardingData(userId);
      final substancePatterns = await _userDb.getSubstancePatterns(userId);

      // Calculate savings
      double totalSaved = 0.0;
      double mindfulSavings = 0.0;
      double reducedSavings = 0.0;
      double totalSpent = 0.0;
      List<Map<String, dynamic>> dailySavingsList = [];

      // Create a map of substance costs
      Map<String, double> substanceCosts = {};
      for (var pattern in substancePatterns) {
        final cost = pattern['cost_per_use'];
        if (cost != null) {
          substanceCosts[pattern['substance_name']] = (cost as num).toDouble();
        }
      }

      // Calculate potential daily cost (what user would spend if they used everything)
      double potentialDailyCost = 0.0;
      for (var cost in substanceCosts.values) {
        potentialDailyCost += cost;
      }

      // Process logs by date
      Map<String, Map<String, dynamic>> logsByDate = {};
      for (var log in logs) {
        final timestamp = DateTime.parse(log['timestamp']);
        final dateKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        logsByDate[dateKey] = log;
      }

      // Calculate for each day in range
      for (
        DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1))) &&
            date.isBefore(now.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))
      ) {
        final dateKey = '${date.year}-${date.month}-${date.day}';
        double daySavings = 0.0;
        String dayType = 'mindful'; // Default

        if (logsByDate.containsKey(dateKey)) {
          final log = logsByDate[dateKey]!;
          final dayTypeFromLog = log['day_type'] as String?;
          final costSpent = (log['cost_spent'] as num?)?.toDouble() ?? 0.0;

          if (dayTypeFromLog == 'used') {
            // Used day - negative savings (actual spending)
            dayType = 'used';
            daySavings = -costSpent; // Negative because money was spent
            totalSpent += costSpent;
          } else if (dayTypeFromLog == 'reduced') {
            // Reduced day - saved some money
            dayType = 'reduced';
            daySavings = potentialDailyCost - costSpent;
            reducedSavings += daySavings;
            totalSpent += costSpent;
          } else {
            // Mindful day - saved all money
            dayType = 'mindful';
            daySavings = potentialDailyCost;
            mindfulSavings += daySavings;
          }
        } else if (date.isBefore(now)) {
          // No log for past date - assume mindful
          dayType = 'mindful';
          daySavings = potentialDailyCost;
          mindfulSavings += daySavings;
        }

        totalSaved += daySavings;

        // Add to daily savings list (only last 30 for display)
        if (dailySavingsList.length < 30) {
          dailySavingsList.insert(0, {
            'date': '${_getMonthAbbr(date.month)} ${date.day}',
            'day': _getDayLabel(date, now),
            'saved': daySavings,
            'type': dayType,
          });
        }
      }

      // Calculate daily average
      final daysInPeriod = endDate.difference(startDate).inDays + 1;
      final daysCounted = daysInPeriod > now.difference(startDate).inDays + 1
          ? now.difference(startDate).inDays + 1
          : daysInPeriod;
      final dailyAvg = daysCounted > 0 ? totalSaved / daysCounted : 0.0;

      // Project yearly savings
      final yearlyProj = dailyAvg * 365;

      if (mounted) {
        setState(() {
          _totalSaved = totalSaved;
          _dailyAverage = dailyAvg;
          _yearlyProjection = yearlyProj;
          _mindfulDaysSavings = mindfulSavings;
          _reducedDaysSavings = reducedSavings;
          _dailySavings = dailySavingsList;
          _isLoading = false;
        });

        // Update animation with real total
        _numberAnimation = Tween<double>(begin: 0, end: _totalSaved).animate(
          CurvedAnimation(
            parent: _numberController,
            curve: Curves.easeOutCubic,
          ),
        );
        _numberController.reset();
        _numberController.forward();
      }
    } catch (e) {
      print('Error loading money saved data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getSubtitleText() {
    switch (_selectedFilter) {
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth > 400 ? 16 : 12),
                _buildFilterDropdown(cardColor, textPrimary, textSecondary),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                _isLoading
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
                      ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                _isLoading
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
                      ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                Text(
                  'Daily Savings',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? _buildDailySavingsShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : _dailySavings.isEmpty
                    ? _buildEmptyState(textSecondary)
                    : Column(
                        children: _dailySavings
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
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedFilter,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: textPrimary),
        dropdownColor: cardColor,
        style: AppTextStyles.bodyMedium(
          context,
        ).copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        items: _filterOptions.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && newValue != _selectedFilter) {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedFilter = newValue;
              _isLoading = true;
            });
            _loadMoneySavedData();
          }
        },
      ),
    );
  }

  Widget _buildMoneyHeader(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
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
            _getSubtitleText(),
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
  ) {
    final spacing = screenWidth > 400 ? 12.0 : 8.0;

    return Row(
      children: [
        Expanded(
          child: FadeTransition(
            opacity: _fadeController,
            child: _buildStatBox(
              emoji: EmojiAssets.chartUp,
              value: '\$${_dailyAverage.toStringAsFixed(2)}',
              label: 'Daily Average',
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
              value: '\$${_yearlyProjection.toInt()}',
              label: 'Yearly Goal',
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
            'Savings Breakdown',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: textPrimary),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            emoji: EmojiAssets.checkmark,
            label: 'Mindful Days',
            amount: _mindfulDaysSavings,
            color: AppColors.successGreen,
            screenWidth: screenWidth,
            textPrimary: textPrimary,
          ),
          const SizedBox(height: 12),
          _buildBreakdownItem(
            emoji: EmojiAssets.target,
            label: 'Reduced Days',
            amount: _reducedDaysSavings,
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
                  'Total This Month',
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
                    '\$${_totalSaved.toInt()}',
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
              Icons.savings_outlined,
              size: 64,
              color: textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No savings data yet',
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your journey to see your savings',
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
