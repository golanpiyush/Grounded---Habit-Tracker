import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class StreakDetailScreen extends ConsumerStatefulWidget {
  final int currentStreak;

  const StreakDetailScreen({Key? key, required this.currentStreak})
    : super(key: key);

  @override
  ConsumerState<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends ConsumerState<StreakDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _numberController;
  late Animation<int> _numberAnimation;

  // Data state variables
  final _userDb = UserDatabaseService();
  bool _isLoading = true;
  int _longestStreak = 0;
  double _successRate = 0.0;
  List<Map<String, dynamic>> _recentLogs = [];

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
      duration: const Duration(milliseconds: 1500),
    );

    _numberAnimation = IntTween(begin: 0, end: widget.currentStreak).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _numberController.forward();
      }
    });

    // Load real data
    _loadStreakData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch insights for longest streak and success rate
      final insights = await _userDb.getUserInsights(userId);

      // Fetch recent logs (last 30 days)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final logs = await _userDb.getLogsForRange(userId, startDate, endDate);

      if (mounted) {
        setState(() {
          _longestStreak =
              insights?['current_longest_streak'] ?? widget.currentStreak;

          // Calculate success rate from logs
          if (logs.isNotEmpty) {
            final mindfulDays = logs.where((log) {
              final dayType = log['day_type'] as String?;
              final substances = log['substances_used'] as List?;
              return dayType == 'mindful' || substances?.isEmpty == true;
            }).length;
            _successRate = (mindfulDays / logs.length * 100);
          }

          _recentLogs = logs.take(9).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading streak data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getStreakHistory() {
    if (_recentLogs.isEmpty) {
      // Return empty list if no data
      return [];
    }

    // Convert real logs to display format
    return _recentLogs.map((log) {
      final timestamp = DateTime.parse(log['timestamp']);
      final now = DateTime.now();
      final diff = now.difference(timestamp).inDays;

      String dayLabel;
      if (diff == 0) {
        dayLabel = 'Today';
      } else if (diff == 1) {
        dayLabel = 'Yesterday';
      } else {
        dayLabel = _getDayName(timestamp.weekday);
      }

      final dayType = log['day_type'] as String?;
      final substances = log['substances_used'] as List?;
      final isCompleted = dayType == 'mindful' || substances?.isEmpty == true;

      return {
        'date': '${_getMonthAbbr(timestamp.month)} ${timestamp.day}',
        'day': dayLabel,
        'completed': isCompleted,
      };
    }).toList();
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
          'Streak Details',
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
                _buildStreakHeader(
                  screenWidth,
                  cardColor,
                  textPrimary,
                  textSecondary,
                ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                _isLoading
                    ? _buildStatsShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : _buildStreakStats(
                        screenWidth,
                        cardColor,
                        textPrimary,
                        textSecondary,
                      ),
                SizedBox(height: screenWidth > 400 ? 32 : 24),
                Text(
                  'Recent Activity',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontSize: screenWidth > 400 ? 18 : 16,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? _buildActivityShimmer(
                        screenWidth,
                        shimmerBaseColor,
                        shimmerHighlightColor,
                      )
                    : _getStreakHistory().isEmpty
                    ? _buildEmptyState(textSecondary)
                    : Column(
                        children: _getStreakHistory()
                            .map(
                              (day) => _buildDayItem(
                                day,
                                screenWidth,
                                cardColor,
                                textPrimary,
                                textSecondary,
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

  Widget _buildStreakHeader(
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
            const Color(0xFFEA580C).withOpacity(0.15),
            const Color(0xFFEA580C).withOpacity(0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFFEA580C).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.2),
              child: Image.asset(EmojiAssets.fire),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _numberAnimation,
            builder: (context, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${_numberAnimation.value}',
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
            'Day Streak',
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEA580C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Keep going! You\'re doing great',
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStats(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final spacing = screenWidth > 400 ? 12.0 : 8.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            emoji: EmojiAssets.trophy,
            value: '$_longestStreak',
            label: 'Longest Streak',
            color: const Color(0xFFA855F7),
            screenWidth: screenWidth,
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatBox(
            emoji: EmojiAssets.target,
            value: '${_successRate.toStringAsFixed(0)}%',
            label: 'Success Rate',
            color: AppColors.successGreen,
            screenWidth: screenWidth,
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Image.asset(emoji, fit: BoxFit.contain),
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
              textAlign: TextAlign.center,
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

  Widget _buildDayItem(
    Map<String, dynamic> day,
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSmallScreen = screenWidth < 360;
    final padding = screenWidth > 400 ? 16.0 : (isSmallScreen ? 12.0 : 14.0);
    final iconSize = screenWidth > 400 ? 44.0 : (isSmallScreen ? 36.0 : 40.0);
    final innerIconSize = screenWidth > 400
        ? 20.0
        : (isSmallScreen ? 16.0 : 18.0);
    final fireIconSize = screenWidth > 400
        ? 24.0
        : (isSmallScreen ? 20.0 : 22.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(padding),
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
              color: day['completed']
                  ? AppColors.successGreen.withOpacity(0.1)
                  : textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: day['completed']
                  ? Image.asset(
                      EmojiAssets.checkmark,
                      width: innerIconSize,
                      height: innerIconSize,
                    )
                  : Icon(
                      Icons.close,
                      color: textSecondary,
                      size: innerIconSize,
                    ),
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
                Text(
                  day['date'],
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (day['completed'])
            Image.asset(
              EmojiAssets.fire,
              width: fireIconSize,
              height: fireIconSize,
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
                    width: 50,
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
                    width: 50,
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

  // Shimmer for activity list
  Widget _buildActivityShimmer(
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
                ),
                const SizedBox(width: 8),
                Container(
                  width: screenWidth > 400 ? 24.0 : 20.0,
                  height: screenWidth > 400 ? 24.0 : 20.0,
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

  // Empty state when no logs
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
              'No activity yet',
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your journey to see your progress here',
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
