import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ============================================================================
// DATA MODELS
// ============================================================================

class DashboardData {
  final int currentStreak;
  final int soberDaysThisMonth;
  final double weeklyAverage;
  final double moneySaved;
  final DailyEntry? todaysEntry;
  final List<WeeklyData> weeklyData;
  final List<Insight> insights;
  final GoalProgress goalProgress;
  final UserMood currentMood;

  DashboardData({
    required this.currentStreak,
    required this.soberDaysThisMonth,
    required this.weeklyAverage,
    required this.moneySaved,
    this.todaysEntry,
    required this.weeklyData,
    required this.insights,
    required this.goalProgress,
    required this.currentMood,
  });
}

class DailyEntry {
  final DateTime date;
  final bool isCompleted;
  final String? notes;
  final int usageLevel; // 0-3 scale

  DailyEntry({
    required this.date,
    required this.isCompleted,
    this.notes,
    required this.usageLevel,
  });
}

class WeeklyData {
  final String day;
  final int usageLevel;
  final bool isSober;

  WeeklyData({
    required this.day,
    required this.usageLevel,
    required this.isSober,
  });
}

class Insight {
  final String title;
  final String description;
  final IconData icon;
  final InsightType type;

  Insight({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

enum InsightType { positive, neutral, informative }

class GoalProgress {
  final String goalName;
  final double progress;
  final String metric;

  GoalProgress({
    required this.goalName,
    required this.progress,
    required this.metric,
  });
}

enum UserMood { great, good, okay, struggling, notSet }

// ============================================================================
// DESIGN SYSTEM
// ============================================================================

class GroundedColors {
  static const primaryGreen = Color(0xFF2D5016);
  static const secondaryGreen = Color(0xFF3D5A3C);
  static const accentOrange = Color(0xFFE89537);
  static const backgroundColor = Color(0xFFFAFAF8);
  static const cardColor = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const successGreen = Color(0xFF10B981);
}

class GroundedSpacing {
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
}

// ============================================================================
// DASHBOARD SCREEN
// ============================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  bool _isLoading = true;
  DashboardData? _data;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Simulate data loading
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _data = _getMockData();
      _isLoading = false;
    });

    _staggerController.forward();
  }

  Future<void> _refreshData() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _data = _getMockData();
    });
  }

  DashboardData _getMockData() {
    return DashboardData(
      currentStreak: 7,
      soberDaysThisMonth: 18,
      weeklyAverage: 1.4,
      moneySaved: 145.50,
      todaysEntry: DailyEntry(
        date: DateTime.now(),
        isCompleted: true,
        notes: "Feeling good today",
        usageLevel: 0,
      ),
      weeklyData: [
        WeeklyData(day: 'Mon', usageLevel: 1, isSober: false),
        WeeklyData(day: 'Tue', usageLevel: 0, isSober: true),
        WeeklyData(day: 'Wed', usageLevel: 0, isSober: true),
        WeeklyData(day: 'Thu', usageLevel: 2, isSober: false),
        WeeklyData(day: 'Fri', usageLevel: 0, isSober: true),
        WeeklyData(day: 'Sat', usageLevel: 0, isSober: true),
        WeeklyData(day: 'Sun', usageLevel: 0, isSober: true),
      ],
      insights: [
        Insight(
          title: 'Weekday Progress',
          description: 'You have 78% sober days on weekdays',
          icon: Icons.trending_up,
          type: InsightType.positive,
        ),
        Insight(
          title: 'Pattern Detected',
          description: 'Thursday tends to be more challenging',
          icon: Icons.lightbulb_outline,
          type: InsightType.informative,
        ),
      ],
      goalProgress: GoalProgress(
        goalName: 'Reduce by 50%',
        progress: 0.68,
        metric: '68% achieved',
      ),
      currentMood: UserMood.good,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroundedColors.backgroundColor,
      body: _isLoading ? _buildLoadingState() : _buildDataState(),
      floatingActionButton: _isLoading ? null : _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(GroundedSpacing.spacing16),
        child: Column(
          children: [
            _buildSkeletonHeader(),
            const SizedBox(height: GroundedSpacing.spacing24),
            _buildSkeletonGrid(),
            const SizedBox(height: GroundedSpacing.spacing24),
            _buildSkeletonCard(height: 200),
            const SizedBox(height: GroundedSpacing.spacing16),
            _buildSkeletonCard(height: 300),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmer(width: 150, height: 28),
            const SizedBox(height: GroundedSpacing.spacing8),
            _buildShimmer(width: 120, height: 16),
          ],
        ),
        _buildShimmer(width: 40, height: 40, isCircle: true),
      ],
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: GroundedSpacing.spacing12,
      crossAxisSpacing: GroundedSpacing.spacing12,
      childAspectRatio: 1.5,
      children: List.generate(4, (index) => _buildShimmer(height: 100)),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return _buildShimmer(height: height);
  }

  Widget _buildShimmer({
    double? width,
    required double height,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GroundedColors.cardColor,
        borderRadius: isCircle ? null : BorderRadius.circular(16),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: const _ShimmerEffect(),
    );
  }

  Widget _buildDataState() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: GroundedColors.primaryGreen,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(GroundedSpacing.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: GroundedSpacing.spacing24),
              _buildQuickStats(),
              const SizedBox(height: GroundedSpacing.spacing24),
              _buildTodayCheckIn(),
              const SizedBox(height: GroundedSpacing.spacing24),
              _buildWeeklyOverview(),
              const SizedBox(height: GroundedSpacing.spacing24),
              _buildPatternInsights(),
              const SizedBox(height: GroundedSpacing.spacing24),
              _buildGoalsProgress(),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _StaggeredAnimation(
      controller: _staggerController,
      delay: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🌿', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: GroundedSpacing.spacing8),
                  Text(
                    'Grounded',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: GroundedColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GroundedSpacing.spacing4),
              Text(
                'Hi Alex,',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: GroundedColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                _getFormattedDate(),
                style: TextStyle(
                  fontSize: 14,
                  color: GroundedColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
            color: GroundedColors.textPrimary,
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Widget _buildQuickStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: GroundedSpacing.spacing12,
      crossAxisSpacing: GroundedSpacing.spacing12,
      childAspectRatio: 1.5,
      children: [
        _StaggeredAnimation(
          controller: _staggerController,
          delay: 1,
          child: StatCard(
            icon: Icons.local_fire_department,
            title: 'Current Streak',
            value: '${_data!.currentStreak}',
            subtitle: 'days strong',
            color: GroundedColors.accentOrange,
          ),
        ),
        _StaggeredAnimation(
          controller: _staggerController,
          delay: 2,
          child: StatCard(
            icon: Icons.celebration_outlined,
            title: 'This Month',
            value: '${_data!.soberDaysThisMonth}',
            subtitle: 'sober days',
            color: GroundedColors.successGreen,
          ),
        ),
        _StaggeredAnimation(
          controller: _staggerController,
          delay: 3,
          child: StatCard(
            icon: Icons.trending_down,
            title: 'Weekly Average',
            value: '${_data!.weeklyAverage}',
            subtitle: 'days per week',
            color: GroundedColors.primaryGreen,
          ),
        ),
        _StaggeredAnimation(
          controller: _staggerController,
          delay: 4,
          child: StatCard(
            icon: Icons.savings_outlined,
            title: 'Money Saved',
            value: '\$${_data!.moneySaved.toStringAsFixed(0)}',
            subtitle: 'this month',
            color: GroundedColors.secondaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCheckIn() {
    return _StaggeredAnimation(
      controller: _staggerController,
      delay: 5,
      child: TodayCheckInCard(
        entry: _data!.todaysEntry,
        mood: _data!.currentMood,
        onEdit: () {
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return _StaggeredAnimation(
      controller: _staggerController,
      delay: 6,
      child: WeeklyOverviewCard(weeklyData: _data!.weeklyData),
    );
  }

  Widget _buildPatternInsights() {
    return _StaggeredAnimation(
      controller: _staggerController,
      delay: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pattern Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GroundedColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: GroundedSpacing.spacing12),
          ..._data!.insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: GroundedSpacing.spacing12),
              child: InsightCard(insight: insight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress() {
    return _StaggeredAnimation(
      controller: _staggerController,
      delay: 8,
      child: GoalsProgressCard(goalProgress: _data!.goalProgress),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.heavyImpact();
      },
      backgroundColor: GroundedColors.primaryGreen,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Add Entry',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM WIDGETS
// ============================================================================

class StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(GroundedSpacing.spacing16),
          decoration: BoxDecoration(
            color: GroundedColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 24),
                  _AnimatedNumber(value: widget.value),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 12,
                      color: GroundedColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: GroundedColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayCheckInCard extends StatelessWidget {
  final DailyEntry? entry;
  final UserMood mood;
  final VoidCallback onEdit;

  const TodayCheckInCard({
    Key? key,
    required this.entry,
    required this.mood,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GroundedSpacing.spacing16),
      decoration: BoxDecoration(
        color: GroundedColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Check-in',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GroundedColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              if (entry != null && entry!.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GroundedSpacing.spacing12,
                    vertical: GroundedSpacing.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: GroundedColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: GroundedColors.successGreen,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: GroundedSpacing.spacing16),
          Row(
            children: [
              MoodIndicator(mood: mood),
              const SizedBox(width: GroundedSpacing.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodText(mood),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: GroundedColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: GroundedSpacing.spacing4),
                    Text(
                      entry?.usageLevel == 0 ? 'Sober day' : 'Usage logged',
                      style: TextStyle(
                        fontSize: 14,
                        color: GroundedColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                color: GroundedColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMoodText(UserMood mood) {
    switch (mood) {
      case UserMood.great:
        return 'Feeling great!';
      case UserMood.good:
        return 'Feeling good';
      case UserMood.okay:
        return 'Doing okay';
      case UserMood.struggling:
        return 'Taking it day by day';
      case UserMood.notSet:
        return 'How are you feeling?';
    }
  }
}

class MoodIndicator extends StatelessWidget {
  final UserMood mood;

  const MoodIndicator({Key? key, required this.mood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getMoodColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(_getMoodEmoji(), style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  String _getMoodEmoji() {
    switch (mood) {
      case UserMood.great:
        return '😄';
      case UserMood.good:
        return '🙂';
      case UserMood.okay:
        return '😐';
      case UserMood.struggling:
        return '😔';
      case UserMood.notSet:
        return '❓';
    }
  }

  Color _getMoodColor() {
    switch (mood) {
      case UserMood.great:
        return GroundedColors.successGreen;
      case UserMood.good:
        return GroundedColors.primaryGreen;
      case UserMood.okay:
        return GroundedColors.accentOrange;
      case UserMood.struggling:
        return GroundedColors.secondaryGreen;
      case UserMood.notSet:
        return GroundedColors.textSecondary;
    }
  }
}

class WeeklyOverviewCard extends StatefulWidget {
  final List<WeeklyData> weeklyData;

  const WeeklyOverviewCard({Key? key, required this.weeklyData})
    : super(key: key);

  @override
  State<WeeklyOverviewCard> createState() => _WeeklyOverviewCardState();
}

class _WeeklyOverviewCardState extends State<WeeklyOverviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GroundedSpacing.spacing16),
      decoration: BoxDecoration(
        color: GroundedColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GroundedColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: GroundedSpacing.spacing24),
          SizedBox(
            height: 200,
            child: WeeklyBarChart(
              data: widget.weeklyData,
              controller: _controller,
            ),
          ),
          const SizedBox(height: GroundedSpacing.spacing16),
          _buildWeeklySummary(),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    final soberDays = widget.weeklyData.where((d) => d.isSober).length;
    return Container(
      padding: const EdgeInsets.all(GroundedSpacing.spacing12),
      decoration: BoxDecoration(
        color: GroundedColors.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: GroundedColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: GroundedSpacing.spacing8),
          Text(
            '$soberDays sober days this week',
            style: TextStyle(
              fontSize: 14,
              color: GroundedColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyBarChart extends StatelessWidget {
  final List<WeeklyData> data;
  final AnimationController controller;

  const WeeklyBarChart({Key? key, required this.data, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        data.length,
        (index) => _AnimatedBar(
          data: data[index],
          controller: controller,
          delay: index * 100,
          isToday: index == data.length - 1,
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final WeeklyData data;
  final AnimationController controller;
  final int delay;
  final bool isToday;

  const _AnimatedBar({
    required this.data,
    required this.controller,
    required this.delay,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay / 1000,
          (delay + 300) / 1000,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final height = _getBarHeight(data.usageLevel) * animation.value;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 32,
              height: height,
              decoration: BoxDecoration(
                color: _getBarColor(),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: GroundedSpacing.spacing8),
            Text(
              data.day,
              style: TextStyle(
                fontSize: 12,
                color: isToday
                    ? GroundedColors.primaryGreen
                    : GroundedColors.textSecondary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ],
        );
      },
    );
  }

  double _getBarHeight(int level) {
    switch (level) {
      case 0:
        return 150.0; // Sober day - tallest
      case 1:
        return 100.0;
      case 2:
        return 70.0;
      case 3:
        return 40.0;
      default:
        return 40.0;
    }
  }

  Color _getBarColor() {
    if (data.isSober) {
      return GroundedColors.successGreen;
    }
    switch (data.usageLevel) {
      case 1:
        return GroundedColors.primaryGreen.withOpacity(0.6);
      case 2:
        return GroundedColors.accentOrange.withOpacity(0.6);
      case 3:
        return GroundedColors.secondaryGreen.withOpacity(0.6);
      default:
        return GroundedColors.textSecondary.withOpacity(0.3);
    }
  }
}

class InsightCard extends StatelessWidget {
  final Insight insight;

  const InsightCard({Key? key, required this.insight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GroundedSpacing.spacing16),
      decoration: BoxDecoration(
        color: GroundedColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor().withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insight.icon, color: _getIconColor(), size: 24),
          ),
          const SizedBox(width: GroundedSpacing.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GroundedColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: GroundedSpacing.spacing4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: GroundedColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (insight.type) {
      case InsightType.positive:
        return GroundedColors.successGreen;
      case InsightType.neutral:
        return GroundedColors.secondaryGreen;
      case InsightType.informative:
        return GroundedColors.accentOrange;
    }
  }

  Color _getIconColor() {
    switch (insight.type) {
      case InsightType.positive:
        return GroundedColors.successGreen;
      case InsightType.neutral:
        return GroundedColors.secondaryGreen;
      case InsightType.informative:
        return GroundedColors.accentOrange;
    }
  }
}

class GoalsProgressCard extends StatefulWidget {
  final GoalProgress goalProgress;

  const GoalsProgressCard({Key? key, required this.goalProgress})
    : super(key: key);

  @override
  State<GoalsProgressCard> createState() => _GoalsProgressCardState();
}

class _GoalsProgressCardState extends State<GoalsProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.goalProgress.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GroundedSpacing.spacing16),
      decoration: BoxDecoration(
        color: GroundedColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: GroundedColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: GroundedSpacing.spacing4),
                  Text(
                    widget.goalProgress.goalName,
                    style: TextStyle(
                      fontSize: 14,
                      color: GroundedColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              ProgressRing(progress: _progressAnimation, size: 80),
            ],
          ),
          const SizedBox(height: GroundedSpacing.spacing16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: GroundedColors.primaryGreen.withOpacity(
                        0.1,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GroundedColors.primaryGreen,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: GroundedSpacing.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.goalProgress.metric,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: GroundedColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Keep going! 🎯',
                        style: TextStyle(
                          fontSize: 14,
                          color: GroundedColors.successGreen,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final Animation<double> progress;
  final double size;

  const ProgressRing({Key? key, required this.progress, required this.size})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ProgressRingPainter(
              progress: progress.value,
              backgroundColor: GroundedColors.primaryGreen.withOpacity(0.1),
              foregroundColor: GroundedColors.primaryGreen,
            ),
            child: Center(
              child: Text(
                '${(progress.value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w600,
                  color: GroundedColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color foregroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.12;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================================
// ANIMATION HELPERS
// ============================================================================

class _StaggeredAnimation extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _StaggeredAnimation({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delayMs = delay * 100;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delayMs / 800,
          (delayMs + 300) / 800,
          curve: Curves.easeOut,
        ),
      ),
    );

    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delayMs / 800,
              (delayMs + 300) / 800,
              curve: Curves.easeOut,
            ),
          ),
        );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: slideAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AnimatedNumber extends StatefulWidget {
  final String value;

  const _AnimatedNumber({required this.value});

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0;
  double _targetValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _parseAndAnimate();
  }

  @override
  void didUpdateWidget(_AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseAndAnimate();
    }
  }

  void _parseAndAnimate() {
    final cleanValue = widget.value.replaceAll(RegExp(r'[^\d.]'), '');
    _targetValue = double.tryParse(cleanValue) ?? 0;

    _animation = Tween<double>(
      begin: _currentValue,
      end: _targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        _currentValue = _animation.value;
        String displayValue;

        // Fixed the string parsing logic
        if (widget.value.startsWith('\$')) {
          // Handle currency values like "$50"
          displayValue = '\$${_animation.value.toStringAsFixed(0)}';
        } else if (widget.value.contains('.')) {
          // Handle decimal values
          displayValue = _animation.value.toStringAsFixed(1);
        } else {
          // Handle integer values
          displayValue = _animation.value.toStringAsFixed(0);
        }

        return Text(
          displayValue,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: GroundedColors.textPrimary,
            fontFamily: 'Inter',
          ),
        );
      },
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GroundedColors.backgroundColor,
                GroundedColors.textSecondary.withOpacity(0.1),
                GroundedColors.backgroundColor,
              ],
              stops:
                  [
                        _controller.value - 0.3,
                        _controller.value,
                        _controller.value + 0.3,
                      ]
                      .map((stop) => stop.clamp(0.0, 1.0))
                      .toList(), // Fixed: ensure stops are within 0-1 range
            ),
          ),
        );
      },
    );
  }
}
