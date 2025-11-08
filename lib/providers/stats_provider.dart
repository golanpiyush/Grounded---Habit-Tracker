// lib/providers/stats_provider.dart

import 'package:Grounded/Services/integrated_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============================================
// STATS STATE MODELS
// ============================================

/// Streak Stats State
class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final double successRate;
  final List<Map<String, dynamic>> recentLogs;
  final bool isLoading;
  final String? error;

  StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.successRate,
    required this.recentLogs,
    this.isLoading = false,
    this.error,
  });

  StreakStats copyWith({
    int? currentStreak,
    int? longestStreak,
    double? successRate,
    List<Map<String, dynamic>>? recentLogs,
    bool? isLoading,
    String? error,
  }) {
    return StreakStats(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      successRate: successRate ?? this.successRate,
      recentLogs: recentLogs ?? this.recentLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Weekly Stats State
class WeeklyStats {
  final double weeklyAverage;
  final double improvement;
  final double bestWeek;
  final List<Map<String, dynamic>> weeklyHistory;
  final bool isLoading;
  final String? error;

  WeeklyStats({
    required this.weeklyAverage,
    required this.improvement,
    required this.bestWeek,
    required this.weeklyHistory,
    this.isLoading = false,
    this.error,
  });

  WeeklyStats copyWith({
    double? weeklyAverage,
    double? improvement,
    double? bestWeek,
    List<Map<String, dynamic>>? weeklyHistory,
    bool? isLoading,
    String? error,
  }) {
    return WeeklyStats(
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      improvement: improvement ?? this.improvement,
      bestWeek: bestWeek ?? this.bestWeek,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Money Saved Stats State
class MoneySavedStats {
  final double totalSaved;
  final double dailyAverage;
  final double yearlyProjection;
  final double mindfulDaysSavings;
  final double reducedDaysSavings;
  final List<Map<String, dynamic>> dailySavings;
  final String selectedFilter;
  final bool isLoading;
  final String? error;

  MoneySavedStats({
    required this.totalSaved,
    required this.dailyAverage,
    required this.yearlyProjection,
    required this.mindfulDaysSavings,
    required this.reducedDaysSavings,
    required this.dailySavings,
    this.selectedFilter = 'All Time',
    this.isLoading = false,
    this.error,
  });

  MoneySavedStats copyWith({
    double? totalSaved,
    double? dailyAverage,
    double? yearlyProjection,
    double? mindfulDaysSavings,
    double? reducedDaysSavings,
    List<Map<String, dynamic>>? dailySavings,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return MoneySavedStats(
      totalSaved: totalSaved ?? this.totalSaved,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      yearlyProjection: yearlyProjection ?? this.yearlyProjection,
      mindfulDaysSavings: mindfulDaysSavings ?? this.mindfulDaysSavings,
      reducedDaysSavings: reducedDaysSavings ?? this.reducedDaysSavings,
      dailySavings: dailySavings ?? this.dailySavings,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Month Stats State
class MonthStats {
  final int mindfulDays;
  final int daysInMonth;
  final int currentDay;
  final String currentMonth;
  final int currentYear;
  final List<Map<String, dynamic>> monthDays;
  final double monthProgress;
  final int daysLeft;
  final bool isLoading;
  final String? error;

  MonthStats({
    required this.mindfulDays,
    required this.daysInMonth,
    required this.currentDay,
    required this.currentMonth,
    required this.currentYear,
    required this.monthDays,
    required this.monthProgress,
    required this.daysLeft,
    this.isLoading = false,
    this.error,
  });

  MonthStats copyWith({
    int? mindfulDays,
    int? daysInMonth,
    int? currentDay,
    String? currentMonth,
    int? currentYear,
    List<Map<String, dynamic>>? monthDays,
    double? monthProgress,
    int? daysLeft,
    bool? isLoading,
    String? error,
  }) {
    return MonthStats(
      mindfulDays: mindfulDays ?? this.mindfulDays,
      daysInMonth: daysInMonth ?? this.daysInMonth,
      currentDay: currentDay ?? this.currentDay,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      monthDays: monthDays ?? this.monthDays,
      monthProgress: monthProgress ?? this.monthProgress,
      daysLeft: daysLeft ?? this.daysLeft,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Streak Stats Provider
final streakStatsProvider =
    StateNotifierProvider<StreakStatsNotifier, StreakStats>((ref) {
      return StreakStatsNotifier(ref);
    });

class StreakStatsNotifier extends StateNotifier<StreakStats> {
  final Ref ref;
  final UserDatabaseService _dbService = UserDatabaseService();

  StreakStatsNotifier(this.ref)
    : super(
        StreakStats(
          currentStreak: 0,
          longestStreak: 0,
          successRate: 0.0,
          recentLogs: [],
          isLoading: true,
        ),
      );

  Future<void> loadStreakData(int currentStreak) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _dbService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No user logged in');
        return;
      }

      // Fetch insights for longest streak
      final insights = await _dbService.getUserInsights(userId);

      // Fetch recent logs (last 30 days to have enough data)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final allLogs = await _dbService.getLogsForRange(
        userId,
        startDate,
        endDate,
      );

      // Sort logs by date (most recent first) and remove duplicates
      Map<String, Map<String, dynamic>> uniqueLogsByDate = {};
      for (var log in allLogs) {
        final logDate = DateTime.parse(log['timestamp'] as String);
        final dateKey =
            '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';

        if (!uniqueLogsByDate.containsKey(dateKey)) {
          uniqueLogsByDate[dateKey] = log;
        }
      }

      // Convert back to list and take only the 9 most recent
      List<Map<String, dynamic>> recentLogs = uniqueLogsByDate.values.toList();

      recentLogs.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp'] as String);
        final dateB = DateTime.parse(b['timestamp'] as String);
        return dateB.compareTo(dateA);
      });

      recentLogs = recentLogs.take(9).toList();

      // Calculate success rate from ALL logs in the period
      double successRate = 0.0;
      if (allLogs.isNotEmpty) {
        final mindfulDays = uniqueLogsByDate.values.where((log) {
          final dayType = log['day_type'] as String?;
          final substances = log['substances_used'] as List?;
          return dayType == 'mindful' || (substances?.isEmpty ?? false);
        }).length;
        successRate = (mindfulDays / uniqueLogsByDate.length) * 100;
      }

      final longestStreak =
          insights?['current_longest_streak'] ?? currentStreak;

      state = state.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        successRate: successRate,
        recentLogs: recentLogs,
        isLoading: false,
      );

      // ✅ ADD THIS: Check for streak milestones
      await _checkStreakMilestones(
        userId: userId,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
    } catch (e) {
      print('Error loading streak data: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading streak data: $e',
      );
    }
  }

  /// Check and celebrate streak milestones
  Future<void> _checkStreakMilestones({
    required String userId,
    required int currentStreak,
    required int longestStreak,
  }) async {
    print('🏆 Checking streak milestones...');

    try {
      final notifService = IntegratedNotificationService();

      // Check if this is a milestone
      if (_isMilestone(currentStreak)) {
        String milestoneType = currentStreak == 7
            ? 'first_week'
            : currentStreak == 30
            ? 'first_month'
            : 'reduction_success';

        await notifService.celebrateMilestone(
          userId: userId,
          milestoneType: milestoneType,
          data: {'days': currentStreak.toString()},
        );
      }

      // Check if new longest streak
      if (currentStreak > longestStreak) {
        await notifService.celebrateMilestone(
          userId: userId,
          milestoneType: 'reduction_success',
          data: {
            'days': currentStreak.toString(),
            'achievement': 'New longest streak!',
          },
        );
      }
    } catch (e) {
      print('❌ Error checking milestones: $e');
    }
  }

  bool _isMilestone(int days) {
    return days == 3 ||
        days == 7 ||
        days == 14 ||
        days == 21 ||
        days == 30 ||
        days == 60 ||
        days == 90 ||
        days % 100 == 0;
  }

  void reset() {
    state = StreakStats(
      currentStreak: 0,
      longestStreak: 0,
      successRate: 0.0,
      recentLogs: [],
      isLoading: true,
    );
  }
}

/// Weekly Stats Provider
final weeklyStatsProvider =
    StateNotifierProvider<WeeklyStatsNotifier, WeeklyStats>((ref) {
      return WeeklyStatsNotifier(ref);
    });

class WeeklyStatsNotifier extends StateNotifier<WeeklyStats> {
  final Ref ref;
  final UserDatabaseService _dbService = UserDatabaseService();

  WeeklyStatsNotifier(this.ref)
    : super(
        WeeklyStats(
          weeklyAverage: 0.0,
          improvement: 0.0,
          bestWeek: 0.0,
          weeklyHistory: [],
          isLoading: true,
        ),
      );

  Future<void> loadWeeklyData(double initialAverage) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _dbService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No user logged in');
        return;
      }

      // Get user creation date
      final userProfile = await _dbService.getUserProfile(userId);
      final userCreatedAt = userProfile?['created_at'] != null
          ? DateTime.parse(userProfile!['created_at'] as String)
          : DateTime.now().subtract(const Duration(days: 365));

      final now = DateTime.now();

      // Calculate number of weeks since user joined
      final weeksSinceJoined = _calculateWeeksBetween(userCreatedAt, now);
      final weeksToShow = (weeksSinceJoined + 1).clamp(1, 5);

      // Calculate data for weeks
      final List<Map<String, dynamic>> weeklyData = [];

      for (int i = 0; i < weeksToShow; i++) {
        final weekStart = _getWeekStart(now.subtract(Duration(days: i * 7)));
        final weekEnd = weekStart.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );

        if (weekStart.isBefore(userCreatedAt)) continue;

        final logs = await _dbService.getLogsForRange(
          userId,
          weekStart,
          weekEnd,
        );

        Map<String, bool> loggedDays = {};

        for (var log in logs) {
          final logDate = DateTime.parse(log['timestamp'] as String);
          final dayKey =
              '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';

          final dayType = log['day_type'] as String?;
          final substances = log['substances_used'] as List?;
          final isMindful =
              dayType == 'mindful' || (substances?.isEmpty ?? false);

          loggedDays[dayKey] = isMindful;
        }

        final mindfulDays = loggedDays.values
            .where((isMindful) => isMindful)
            .length;

        final totalLoggedDays = loggedDays.length;
        final average = totalLoggedDays > 0 ? (mindfulDays / 7.0) * 7.0 : 0.0;

        weeklyData.add({
          'week': i == 0
              ? 'This Week'
              : i == 1
              ? 'Last Week'
              : '$i Weeks Ago',
          'average': double.parse(average.toStringAsFixed(1)),
          'total': mindfulDays,
          'weekStart': weekStart,
        });
      }

      // Calculate improvement
      double improvement = 0.0;
      if (weeklyData.length >= 2) {
        final thisWeekTotal = weeklyData[0]['total'] as int;
        final lastWeekTotal = weeklyData[1]['total'] as int;
        improvement = (thisWeekTotal - lastWeekTotal).toDouble();
      }

      final bestWeek = weeklyData.isNotEmpty
          ? weeklyData
                .map((w) => w['average'] as double)
                .reduce((a, b) => a > b ? a : b)
          : 0.0;

      final calculatedAverage = weeklyData.isNotEmpty
          ? (weeklyData[0]['average'] as double)
          : initialAverage;

      state = state.copyWith(
        weeklyAverage: calculatedAverage,
        improvement: improvement,
        bestWeek: bestWeek,
        weeklyHistory: weeklyData,
        isLoading: false,
      );

      // ✅ ADD THIS: Send weekly report if it's Sunday evening
      await _sendWeeklyReportIfDue(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading weekly data: $e',
      );
    }
  }

  /// Send weekly report on Sunday evenings
  Future<void> _sendWeeklyReportIfDue(String userId) async {
    print('📊 Checking if weekly report is due...');

    try {
      final now = DateTime.now();

      // Only send on Sunday evenings (after 7 PM)
      if (now.weekday == DateTime.sunday && now.hour >= 19) {
        final notifService = IntegratedNotificationService();
        await notifService.sendWeeklyReport(userId: userId);
      }
    } catch (e) {
      print('❌ Error sending weekly report: $e');
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Returns Monday of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int _calculateWeeksBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).floor();
  }

  void reset() {
    state = WeeklyStats(
      weeklyAverage: 0.0,
      improvement: 0.0,
      bestWeek: 0.0,
      weeklyHistory: [],
      isLoading: true,
    );
  }
}

/// Money Saved Stats Provider
final moneySavedStatsProvider =
    StateNotifierProvider<MoneySavedStatsNotifier, MoneySavedStats>((ref) {
      return MoneySavedStatsNotifier(ref);
    });

// Complete MoneySavedStatsNotifier class - Replace in stats_provider.dart

class MoneySavedStatsNotifier extends StateNotifier<MoneySavedStats> {
  final Ref ref;
  final UserDatabaseService _dbService = UserDatabaseService();

  MoneySavedStatsNotifier(this.ref)
    : super(
        MoneySavedStats(
          totalSaved: 0.0,
          dailyAverage: 0.0,
          yearlyProjection: 0.0,
          mindfulDaysSavings: 0.0,
          reducedDaysSavings: 0.0,
          dailySavings: [],
          isLoading: true,
        ),
      );

  Future<void> loadMoneySavedData({String? filter}) async {
    final selectedFilter = filter ?? state.selectedFilter;
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedFilter: selectedFilter,
    );

    try {
      final userId = _dbService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No user logged in');
        return;
      }

      // Get date range based on filter
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      switch (selectedFilter) {
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
          final userProfile = await _dbService.getUserProfile(userId);
          if (userProfile != null && userProfile['created_at'] != null) {
            startDate = DateTime.parse(userProfile['created_at']);
          } else {
            startDate = now.subtract(const Duration(days: 365));
          }
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Normalize start date to beginning of day
      startDate = DateTime(startDate.year, startDate.month, startDate.day);

      print('DEBUG: Date range - Start: $startDate, End: $endDate');

      // Fetch logs and substance patterns
      final logs = await _dbService.getLogsForRange(userId, startDate, endDate);
      final substancePatterns = await _dbService.getSubstancePatterns(userId);

      print('DEBUG: Found ${logs.length} logs');
      print('DEBUG: Found ${substancePatterns.length} substance patterns');

      // Calculate potential daily cost from substance patterns
      double potentialDailyCost = 0.0;
      for (var pattern in substancePatterns) {
        final cost = pattern['cost_per_use'];
        final substanceName = pattern['substance_name'];
        if (cost != null) {
          final costValue = (cost as num).toDouble();
          potentialDailyCost += costValue;
          print('DEBUG: Substance $substanceName costs \$$costValue per use');
        }
      }

      print('DEBUG: Total potential daily cost = \$$potentialDailyCost');

      // Initialize savings trackers
      double totalSaved = 0.0;
      double mindfulSavings = 0.0;
      double reducedSavings = 0.0;
      List<Map<String, dynamic>> dailySavingsList = [];

      // Create a map to store unique logs by date (avoid duplicates)
      Map<String, Map<String, dynamic>> logsByDate = {};

      for (var log in logs) {
        final timestamp = DateTime.parse(log['timestamp'] as String);
        final dateKey =
            '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

        // Keep only the first log per day (should be most recent due to query ordering)
        if (!logsByDate.containsKey(dateKey)) {
          logsByDate[dateKey] = log;
          print('DEBUG: Added log for date $dateKey');
        }
      }

      print('DEBUG: Processing ${logsByDate.length} unique days');

      // Process each logged day
      final sortedDates = logsByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

      for (var dateKey in sortedDates) {
        final log = logsByDate[dateKey]!;

        // Parse date from log
        final timestamp = DateTime.parse(log['timestamp'] as String);

        // Get log details
        final dayTypeFromLog = log['day_type'] as String?;
        final costSpent = (log['cost_spent'] as num?)?.toDouble() ?? 0.0;
        final substancesUsed = log['substances_used'] as List?;

        print('DEBUG: ===== Processing $dateKey =====');
        print('DEBUG: day_type from log: $dayTypeFromLog');
        print('DEBUG: cost_spent: \$$costSpent');
        print('DEBUG: substances_used: $substancesUsed');

        double daySavings = 0.0;
        String dayType = 'used'; // Default to used

        // Determine actual day type and calculate savings
        if (dayTypeFromLog == 'used') {
          // User explicitly marked as "used" day
          dayType = 'used';
          daySavings = 0.0; // No savings on used days
          print('DEBUG: Marked as USED day - no savings');
        } else if (dayTypeFromLog == 'reduced') {
          // User reduced usage
          dayType = 'reduced';
          daySavings = (potentialDailyCost - costSpent).clamp(
            0.0,
            potentialDailyCost,
          );
          reducedSavings += daySavings;
          print('DEBUG: Marked as REDUCED day - saved \$$daySavings');
        } else if (dayTypeFromLog == 'mindful') {
          // User marked as mindful - should have NO substances and NO cost
          if ((substancesUsed == null || substancesUsed.isEmpty) &&
              costSpent == 0.0) {
            dayType = 'mindful';
            daySavings = potentialDailyCost;
            mindfulSavings += daySavings;
            print(
              'DEBUG: Marked as MINDFUL day (verified) - saved \$$daySavings',
            );
          } else {
            // Logged as mindful but has substances or cost - treat as used
            dayType = 'used';
            daySavings = 0.0;
            print(
              'DEBUG: WARNING: Marked mindful but has substances/cost - treating as USED',
            );
          }
        } else {
          // Unknown day type - check substances to determine
          if (substancesUsed == null || substancesUsed.isEmpty) {
            dayType = 'mindful';
            daySavings = potentialDailyCost;
            mindfulSavings += daySavings;
            print(
              'DEBUG: No day_type but no substances - treating as MINDFUL - saved \$$daySavings',
            );
          } else {
            dayType = 'used';
            daySavings = 0.0;
            print('DEBUG: No day_type and has substances - treating as USED');
          }
        }

        totalSaved += daySavings;

        // Add to display list (limit to 30 most recent)
        if (dailySavingsList.length < 30) {
          dailySavingsList.add({
            'date': '${_getMonthAbbr(timestamp.month)} ${timestamp.day}',
            'day': _getDayLabel(timestamp, now),
            'saved': daySavings,
            'type': dayType,
          });
        }
      }

      print('DEBUG: ===== FINAL TOTALS =====');
      print('DEBUG: Total Saved: \$$totalSaved');
      print('DEBUG: Mindful Savings: \$$mindfulSavings');
      print('DEBUG: Reduced Savings: \$$reducedSavings');
      print('DEBUG: Daily Average (Potential): \$$potentialDailyCost');
      print('DEBUG: Yearly Projection: \$${potentialDailyCost * 365}');

      // Update state
      state = state.copyWith(
        totalSaved: totalSaved,
        dailyAverage: potentialDailyCost,
        yearlyProjection: potentialDailyCost * 365,
        mindfulDaysSavings: mindfulSavings,
        reducedDaysSavings: reducedSavings,
        dailySavings: dailySavingsList,
        isLoading: false,
      );

      // ✅ ADD THIS: Check money saved milestones
      await _checkMoneySavedMilestones(userId: userId, totalSaved: totalSaved);
    } catch (e, stackTrace) {
      print('ERROR loading money data: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading money data: $e',
      );
    }
  }

  /// Check and celebrate money saved milestones
  Future<void> _checkMoneySavedMilestones({
    required String userId,
    required double totalSaved,
  }) async {
    print('💰 Checking money saved milestones...');

    try {
      final notifService = IntegratedNotificationService();

      // Check significant savings milestones
      final milestones = [100, 500, 1000, 2000, 5000, 10000];

      for (final milestone in milestones) {
        // Check if we just crossed this milestone (within $100 range)
        if (totalSaved >= milestone && totalSaved < milestone + 100) {
          await notifService.celebrateMilestone(
            userId: userId,
            milestoneType: 'cost_savings',
            data: {
              'amount': milestone.toString(),
              'comparison': _getComparison(milestone),
            },
          );
          break; // Only celebrate one milestone at a time
        }
      }
    } catch (e) {
      print('❌ Error checking money milestones: $e');
    }
  }

  String _getComparison(int amount) {
    if (amount >= 5000) return 'a used car';
    if (amount >= 2000) return 'a nice vacation';
    if (amount >= 1000) return 'a new phone';
    if (amount >= 500) return 'a weekend getaway';
    return 'a nice dinner out';
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
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  void reset() {
    state = MoneySavedStats(
      totalSaved: 0.0,
      dailyAverage: 0.0,
      yearlyProjection: 0.0,
      mindfulDaysSavings: 0.0,
      reducedDaysSavings: 0.0,
      dailySavings: [],
      isLoading: true,
    );
  }
}

/// Month Stats Provider
final monthStatsProvider =
    StateNotifierProvider<MonthStatsNotifier, MonthStats>((ref) {
      return MonthStatsNotifier(ref);
    });

class MonthStatsNotifier extends StateNotifier<MonthStats> {
  final Ref ref;
  final UserDatabaseService _dbService = UserDatabaseService();

  MonthStatsNotifier(this.ref)
    : super(
        MonthStats(
          mindfulDays: 0,
          daysInMonth: 31,
          currentDay: 1,
          currentMonth: 'October',
          currentYear: 2025,
          monthDays: [],
          monthProgress: 0.0,
          daysLeft: 0,
          isLoading: true,
        ),
      );

  Future<void> loadMonthData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userId = _dbService.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'No user logged in');
        return;
      }

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final currentDay = now.day;
      final currentMonth = _getMonthName(now.month);
      final currentYear = now.year;
      final daysInMonth = endOfMonth.day;

      // Get target date
      final onboarding = await _dbService.getOnboardingData(userId);
      DateTime? targetDate;
      if (onboarding != null && onboarding['target_date'] != null) {
        targetDate = DateTime.parse(onboarding['target_date'] as String);
      }

      int daysLeft = 0;
      if (targetDate != null) {
        daysLeft = targetDate.difference(now).inDays;
        if (daysLeft < 0) daysLeft = 0;
      } else {
        daysLeft = daysInMonth - currentDay;
      }

      // Fetch logs
      final logs = await _dbService.getLogsForRange(
        userId,
        startOfMonth,
        endOfMonth,
      );

      Map<int, Map<String, dynamic>> logsByDay = {};
      for (var log in logs) {
        final logDate = DateTime.parse(log['timestamp'] as String);
        logsByDay[logDate.day] = log;
      }

      List<Map<String, dynamic>> monthDaysList = [];
      int mindfulCount = 0;

      for (int day = 1; day <= daysInMonth; day++) {
        final isPast = day <= currentDay;
        bool completed = false;

        if (isPast && logsByDay.containsKey(day)) {
          final log = logsByDay[day]!;
          final dayType = log['day_type'] as String?;
          final substances = log['substances_used'] as List?;
          completed = dayType == 'mindful' || (substances?.isEmpty ?? false);
          if (completed) mindfulCount++;
        }

        monthDaysList.add({
          'day': day,
          'completed': completed,
          'isPast': isPast,
        });
      }

      final daysPassed = currentDay;
      final monthProgress = daysPassed > 0
          ? (mindfulCount / daysPassed) * 100
          : 0.0;

      state = state.copyWith(
        mindfulDays: mindfulCount,
        daysInMonth: daysInMonth,
        currentDay: currentDay,
        currentMonth: currentMonth,
        currentYear: currentYear,
        monthDays: monthDaysList,
        monthProgress: monthProgress,
        daysLeft: daysLeft,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error loading month data: $e',
      );
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

  void reset() {
    state = MonthStats(
      mindfulDays: 0,
      daysInMonth: 31,
      currentDay: 1,
      currentMonth: 'October',
      currentYear: 2025,
      monthDays: [],
      monthProgress: 0.0,
      daysLeft: 0,
      isLoading: true,
    );
  }
}
