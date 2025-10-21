import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';

class MonthDetailScreen extends ConsumerStatefulWidget {
  final int daysThisMonth;

  const MonthDetailScreen({Key? key, required this.daysThisMonth})
    : super(key: key);

  @override
  ConsumerState<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends ConsumerState<MonthDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _numberController;
  late Animation<double> _numberAnimation;

  // Data state variables
  final _userDb = UserDatabaseService();
  bool _isLoading = true;
  int _mindfulDays = 0;
  int _daysInMonth = 31;
  int _currentDay = 1;
  String _currentMonth = 'October';
  int _currentYear = 2025;
  List<Map<String, dynamic>> _monthDays = [];
  double _monthProgress = 0.0;
  int _daysLeft = 0;

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

    _numberAnimation =
        Tween<double>(begin: 0, end: widget.daysThisMonth.toDouble()).animate(
          CurvedAnimation(
            parent: _numberController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _numberController.forward();
    });

    // Load real data
    _loadMonthData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthData() async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get current date info
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _currentDay = now.day;
      _currentMonth = _getMonthName(now.month);
      _currentYear = now.year;
      _daysInMonth = endOfMonth.day;

      // Get user's target date from onboarding
      final onboarding = await _userDb.getOnboardingData(userId);
      DateTime? targetDate;
      if (onboarding != null && onboarding['target_date'] != null) {
        targetDate = DateTime.parse(onboarding['target_date']);
      }

      // Calculate days left to target date
      if (targetDate != null) {
        _daysLeft = targetDate.difference(now).inDays;
        if (_daysLeft < 0) _daysLeft = 0; // Past target date
      } else {
        _daysLeft = _daysInMonth - _currentDay; // Fallback to end of month
      }

      // Fetch logs for the month
      final logs = await _userDb.getLogsForRange(
        userId,
        startOfMonth,
        endOfMonth,
      );

      // Create a map of logs by day
      Map<int, Map<String, dynamic>> logsByDay = {};
      for (var log in logs) {
        final logDate = DateTime.parse(log['timestamp']);
        logsByDay[logDate.day] = log;
      }

      // Build month days data
      List<Map<String, dynamic>> monthDaysList = [];
      int mindfulCount = 0;

      for (int day = 1; day <= _daysInMonth; day++) {
        final isPast = day <= _currentDay;
        bool completed = false;

        if (isPast && logsByDay.containsKey(day)) {
          final log = logsByDay[day]!;
          final dayType = log['day_type'] as String?;
          final substances = log['substances_used'] as List?;
          completed = dayType == 'mindful' || substances?.isEmpty == true;
          if (completed) mindfulCount++;
        }
        // ✅ Don't count days without logs as mindful - only count actual logged mindful days

        monthDaysList.add({
          'day': day,
          'completed': completed,
          'isPast': isPast,
        });
      }

      if (mounted) {
        setState(() {
          _mindfulDays = mindfulCount;
          _monthDays = monthDaysList;

          // Calculate progress based on mindful days vs days passed
          final daysPassed = _currentDay;
          _monthProgress = daysPassed > 0
              ? (mindfulCount / daysPassed * 100)
              : 0.0;

          // Days left is already calculated from target date above

          _isLoading = false;
        });

        // Update animation with real count
        _numberAnimation = Tween<double>(begin: 0, end: _mindfulDays.toDouble())
            .animate(
              CurvedAnimation(
                parent: _numberController,
                curve: Curves.easeOutCubic,
              ),
            );
        _numberController.reset();
        _numberController.forward();
      }
    } catch (e) {
      print('Error loading month data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
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
          'Monthly Progress',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textPrimary),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isLoading = true);
              _loadMonthData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            setState(() => _isLoading = true);
            await _loadMonthData();
          },
          color: const Color(0xFFA855F7),
          child: FadeTransition(
            opacity: _fadeController,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthHeader(
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
                      : _buildMonthStats(
                          screenWidth,
                          cardColor,
                          textPrimary,
                          textSecondary,
                        ),
                  SizedBox(height: screenWidth > 400 ? 32 : 24),
                  Text(
                    '$_currentMonth $_currentYear',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontSize: screenWidth > 400 ? 18 : 16,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? _buildCalendarShimmer(
                          screenWidth,
                          shimmerBaseColor,
                          shimmerHighlightColor,
                        )
                      : _buildCalendar(
                          screenWidth,
                          cardColor,
                          textPrimary,
                          textSecondary,
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(
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
            const Color(0xFFA855F7).withOpacity(0.15),
            const Color(0xFFA855F7).withOpacity(0.05),
          ],
        ),
        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(iconSize * 0.2),
              child: Image.asset(EmojiAssets.trophy),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _numberAnimation,
            builder: (context, child) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${_numberAnimation.value.toInt()}',
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
            'Days This Month',
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA855F7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Out of $_daysInMonth days in $_currentMonth',
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStats(
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
            emoji: EmojiAssets.chartUp,
            value: '${_monthProgress.toInt()}%',
            label: 'Month Progress',
            color: const Color(0xFF3B82F6),
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
            value: '$_daysLeft',
            label: 'Days Left',
            color: AppColors.accentOrange,
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
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textPrimary,
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

  Widget _buildCalendar(
    double screenWidth,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final spacing = screenWidth > 400 ? 8.0 : (screenWidth < 360 ? 4.0 : 6.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: _monthDays.length,
      itemBuilder: (context, index) {
        final day = _monthDays[index];
        return _CalendarDay(
          day: day,
          screenWidth: screenWidth,
          cardColor: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        );
      },
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

  // Shimmer for calendar
  Widget _buildCalendarShimmer(
    double screenWidth,
    Color baseColor,
    Color highlightColor,
  ) {
    final spacing = screenWidth > 400 ? 8.0 : (screenWidth < 360 ? 4.0 : 6.0);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: 31,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

// Simplified calendar day widget without animation on scroll
class _CalendarDay extends StatelessWidget {
  final Map<String, dynamic> day;
  final double screenWidth;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;

  const _CalendarDay({
    required this.day,
    required this.screenWidth,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = screenWidth > 400 ? 12.0 : 10.0;

    Color bgColor;
    Widget? icon;

    if (!day['isPast']) {
      bgColor = textSecondary.withOpacity(0.05);
    } else if (day['completed']) {
      bgColor = AppColors.successGreen.withOpacity(0.1);
      icon = Image.asset(
        EmojiAssets.checkmark,
        width: iconSize,
        height: iconSize,
      );
    } else {
      bgColor = AppColors.accentOrange.withOpacity(0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: day['completed']
              ? AppColors.successGreen.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day['day']}',
              style: TextStyle(
                fontSize: screenWidth > 400
                    ? 14
                    : (screenWidth < 360 ? 11 : 12),
                fontWeight: FontWeight.w600,
                color: day['isPast'] ? textPrimary : textSecondary,
              ),
            ),
          ),
          if (icon != null) Positioned(top: 2, right: 2, child: icon),
        ],
      ),
    );
  }
}
