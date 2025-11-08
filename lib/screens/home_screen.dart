import 'package:Grounded/Services/SmartNotifications/notificationsTemplate.dart';
import 'package:Grounded/models/dynamic_insight_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/models/dashboard_Data.dart';
import 'package:Grounded/models/user_goal_progress_model.dart';
import 'package:Grounded/models/user_insight_model.dart';
import 'package:Grounded/models/user_weekly_model.dart';
import 'package:Grounded/models/userdailyentrymodel.dart';
import 'package:Grounded/Services/entryService.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/screens/User-Detials-Screens/add_entry.dart';
import 'package:Grounded/screens/User-Detials-Screens/money_saved_detail_screen.dart';
import 'package:Grounded/screens/User-Detials-Screens/month_detail_screen.dart';
import 'package:Grounded/screens/User-Detials-Screens/streak_detail_screen.dart';
import 'package:Grounded/screens/User-Detials-Screens/weekly_avg_detail_screen.dart';
import 'package:Grounded/screens/userSettingsPage.dart';
import 'package:Grounded/screens/weekly_overview_detail_screen.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:Grounded/utils/emoji_assets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late DashboardData _data;
  bool _isLoading = true;
  final UserDatabaseService _userDb = UserDatabaseService();
  final GlobalKey _checkInCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // _data = _getMockData();
    _fadeController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        print('❌ No user logged in');
        setState(() => _isLoading = false);
        return;
      }

      print('📊 Loading dashboard data for user: $userId');

      // Get today's log
      final todayLog = await _userDb.getDailyLog(userId, DateTime.now());

      // Get weekly logs
      final weekStart = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final weeklyLogs = await _userDb.getLogsForRange(
        userId,
        weekStart,
        DateTime.now(),
      );

      // Get insights - FIX: Handle null insights properly
      final insightsData = await _userDb.getUserInsights(userId);
      print('📊 Raw insights data: $insightsData');

      // Get onboarding data for substances
      final onboardingData = await _userDb.getOnboardingData(userId);
      print('📋 Onboarding data: $onboardingData');

      final substances = onboardingData?['selected_substances'] as List? ?? [];
      print('💊 User substances: $substances');

      // Calculate streak (using first substance or overall)
      int currentStreak = 0;
      if (substances.isNotEmpty) {
        currentStreak = await _userDb.getSobrietyStreak(
          userId,
          substances[0].toString(),
        );
      } else {
        // Calculate overall streak from logs
        final allLogs = await _userDb.getLogsForRange(
          userId,
          DateTime.now().subtract(Duration(days: 365)),
          DateTime.now(),
        );
        currentStreak = _calculateOverallStreak(allLogs);
      }
      print('🔥 Current streak: $currentStreak days');

      // Calculate money saved
      final moneySaved = await _userDb.calculateMoneySaved(userId);
      print('💰 Money saved: \$$moneySaved');

      // Get this month's logs
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final monthLogs = await _userDb.getLogsForRange(
        userId,
        monthStart,
        DateTime.now(),
      );

      // Count unique mindful days this month
      final uniqueDays = monthLogs
          .where((log) => (log['day_type'] as String?) == 'mindful')
          .map((log) {
            final timestamp = DateTime.parse(log['timestamp']);
            return DateTime(timestamp.year, timestamp.month, timestamp.day);
          })
          .toSet()
          .length;

      // Calculate weekly average
      final weeksInMonth = (DateTime.now().day / 7).ceil();
      double weeklyAverage = weeksInMonth > 0 ? uniqueDays / weeksInMonth : 0.0;

      // Build weekly data
      final weeklyData = _buildWeeklyDataFromLogs(weeklyLogs);

      // Build insights - FIX: Pass proper data
      final insightsList = await _buildInsights(
        userId,
        weeklyLogs,
        insightsData,
      );

      // Build goal progress
      final goalProgress = _buildGoalProgress(onboardingData, currentStreak);

      // Determine today's entry
      final todaysEntry = _buildTodaysEntry(todayLog);

      setState(() {
        _data = DashboardData(
          currentStreak: currentStreak,
          thisMonth: uniqueDays,
          weeklyAverage: double.parse(weeklyAverage.toStringAsFixed(1)),
          moneySaved: moneySaved,
          todaysEntry: todaysEntry,
          weeklyData: weeklyData,
          insights: insightsList,
          goalProgress: goalProgress,
          currentMood: _getMoodFromLog(todayLog),
        );
        _isLoading = false;
      });

      _fadeController.forward();
      print('✅ Dashboard data loaded successfully');
    } catch (e, stackTrace) {
      print('❌ Error loading dashboard data: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  // Add helper method for overall streak calculation
  int _calculateOverallStreak(List<Map<String, dynamic>> logs) {
    int streak = 0;
    final today = DateTime.now();

    // Sort logs by date descending
    final sortedLogs = List<Map<String, dynamic>>.from(logs)
      ..sort((a, b) {
        final dateA = DateTime.parse(a['timestamp']);
        final dateB = DateTime.parse(b['timestamp']);
        return dateB.compareTo(dateA);
      });

    // Check consecutive mindful days from today backwards
    DateTime currentDate = today;
    for (int i = 0; i < 365; i++) {
      // Check up to 1 year
      final logForDate = sortedLogs.firstWhere((log) {
        final logDate = DateTime.parse(log['timestamp']);
        return logDate.year == currentDate.year &&
            logDate.month == currentDate.month &&
            logDate.day == currentDate.day;
      }, orElse: () => {});

      if (logForDate.isNotEmpty &&
          (logForDate['day_type'] as String?) == 'mindful') {
        streak++;
        currentDate = currentDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Build weekly data from logs
  /// Build weekly data from logs
  List<WeeklyData> _buildWeeklyDataFromLogs(List<Map<String, dynamic>> logs) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekData = <WeeklyData>[];

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));

      // Find logs for this day
      final dayLogs = logs.where((l) {
        final logTimestamp = DateTime.parse(l['timestamp']);
        return logTimestamp.year == date.year &&
            logTimestamp.month == date.month &&
            logTimestamp.day == date.day;
      }).toList();

      DayType dayType;
      double height;
      bool hasLog; // ADD THIS

      if (dayLogs.isEmpty) {
        // No log for this day - don't count as mindful
        dayType = DayType.used; // CHANGED from mindful to used
        height = 60;
        hasLog = false; // ADD THIS
      } else {
        // Check day_type from the log
        final dayTypeStr = dayLogs.first['day_type'] as String?;

        if (dayTypeStr == 'mindful') {
          dayType = DayType.mindful;
          height = 140;
        } else if (dayTypeStr == 'reduced') {
          dayType = DayType.reduced;
          height = 100;
        } else {
          // 'used'
          dayType = DayType.used;
          height = 60;
        }
        hasLog = true; // ADD THIS
      }

      weekData.add(
        WeeklyData(
          day: days[i],
          dayType: dayType,
          height: height,
          hasLog: hasLog, // ADD THIS
        ),
      );
    }

    return weekData;
  }

  /// Build REAL dynamic insights from database and notification templates
  Future<List<DynamicInsight>> _buildInsights(
    String userId,
    List<Map<String, dynamic>> weeklyLogs,
    Map<String, dynamic>? insightsData,
  ) async {
    final insights = <DynamicInsight>[];

    try {
      // Get user insights from database
      final dbInsights = await _userDb.getUserInsights(userId);

      if (dbInsights == null) {
        print('⚠️ No insights data available');
        return insights;
      }

      print('📊 Database insights: $dbInsights');

      if (dbInsights == null || dbInsights.isEmpty) {
        print('⚠️ No insights data available');
        // Provide default encouragement insight
        insights.add(
          DynamicInsight(
            type: InsightType.weeklyProgress,
            title: 'Welcome to Grounded!',
            description:
                'Start your journey by logging your first check-in. Every mindful day counts!',
            icon: Icons.emoji_objects,
            iconColor: AppColors.primaryGreen,
            emoji: EmojiAssets.bell,
          ),
        );
        return insights;
      }
      // 1. WEEKLY PROGRESS (from actual data)
      final totalCheckIns = dbInsights['total_check_ins'] as int? ?? 0;
      final avgMotivation =
          (dbInsights['avg_motivation'] as num?)?.toDouble() ?? 0.0;

      if (totalCheckIns > 0) {
        // FIXED: Only count days with actual logs, not empty days
        final mindfulDays = weeklyLogs.where((log) {
          final dayType = log['day_type'] as String?;
          return dayType ==
              'mindful'; // REMOVED: || (substances?.isEmpty ?? false)
        }).length;

        // FIXED: Use actual logged days for percentage, not total 7
        final totalLoggedDays = weeklyLogs.length;
        final mindfulPercentage = totalLoggedDays > 0
            ? ((mindfulDays / totalLoggedDays) * 100).round()
            : 0;

        // Get message from notification template
        final message = NotificationSelector.getMessage(
          category: 'data',
          subcategory: 'frequency_change',
          variables: {
            'percentage': mindfulPercentage.toString(),
            'count': mindfulDays.toString(),
            'direction': 'this week',
          },
        );

        insights.add(
          DynamicInsight(
            type: InsightType.weeklyProgress,
            title: 'Weekly Progress',
            description: message,
            icon: Icons.trending_up,
            iconColor: mindfulPercentage >= 50
                ? AppColors.successGreen
                : AppColors.accentOrange,
            emoji: EmojiAssets.chartUp,
          ),
        );
      }

      // 2. STREAK MILESTONE (from actual database)
      final currentLongestStreak =
          dbInsights['current_longest_streak'] as int? ?? 0;

      if (currentLongestStreak >= 3) {
        final message = NotificationSelector.getMessage(
          category: 'positive',
          subcategory: 'streak_milestone',
          variables: {'days': currentLongestStreak.toString()},
        );

        insights.add(
          DynamicInsight(
            type: InsightType.streakMilestone,
            title: 'Streak Achievement',
            description: message,
            icon: Icons.local_fire_department,
            iconColor: Color(0xFFEA580C),
            emoji: EmojiAssets.fire,
          ),
        );
      }

      // 3. MONEY SAVED (from actual calculation)
      final moneySaved = dbInsights['total_money_saved'] as num? ?? 0;

      if (moneySaved > 0) {
        final amount = moneySaved.toInt();
        String comparison;

        if (amount >= 5000) {
          comparison = 'a used car';
        } else if (amount >= 2000) {
          comparison = 'a nice vacation';
        } else if (amount >= 1000) {
          comparison = 'a new phone';
        } else if (amount >= 500) {
          comparison = 'a weekend getaway';
        } else {
          comparison = 'a nice dinner out';
        }

        final message = NotificationSelector.getMessage(
          category: 'celebration',
          subcategory: 'cost_savings',
          variables: {'amount': amount.toString(), 'comparison': comparison},
        );

        insights.add(
          DynamicInsight(
            type: InsightType.moneySaved,
            title: 'Money Saved',
            description: message,
            icon: Icons.savings,
            iconColor: AppColors.successGreen,
            emoji: EmojiAssets.moneyBag,
          ),
        );
      }

      // 4. TRIGGER PATTERN (from actual database)
      final triggers = await _userDb.getTriggerAnalysis(userId, days: 30);

      if (triggers.isNotEmpty) {
        final topTrigger = triggers[0];
        final triggerName = topTrigger['trigger_name'] as String;
        final percentage = topTrigger['percentage'] as num;

        final message = NotificationSelector.getMessage(
          category: 'interpretive',
          subcategory: _mapTriggerToCategory(triggerName),
          variables: {'time': 'recently'},
        );

        insights.add(
          DynamicInsight(
            type: InsightType.triggerPattern,
            title: 'Pattern Detected',
            description:
                '$triggerName is your main trigger (${percentage.toInt()}%)',
            icon: Icons.lightbulb_outline,
            iconColor: Color(0xFFF59E0B),
            emoji: EmojiAssets.lightbulb,
          ),
        );
      }

      // 5. MOOD TREND (from actual logs)
      final moodLogs = weeklyLogs
          .where((log) => log['mood_rating'] != null)
          .toList();

      if (moodLogs.length >= 3) {
        final avgMood =
            moodLogs
                .map((log) => log['mood_rating'] as int)
                .reduce((a, b) => a + b) /
            moodLogs.length;

        String emotionalKey;
        String moodEmoji;
        Color moodColor;

        if (avgMood >= 4) {
          emotionalKey = 'celebration';
          moodEmoji = EmojiAssets.smileGood;
          moodColor = Color(0xFF22C55E);
        } else if (avgMood >= 3) {
          emotionalKey = 'boredom';
          moodEmoji = EmojiAssets.neutralFace;
          moodColor = Color(0xFFF59E0B);
        } else {
          emotionalKey = 'stress_anxiety';
          moodEmoji = EmojiAssets.worriedFace;
          moodColor = Color(0xFFEF4444);
        }

        final message = NotificationSelector.getMessage(
          category: 'emotional',
          subcategory: emotionalKey,
          variables: {
            'userName': 'friend',
            'score': avgMood.toStringAsFixed(1),
            'percentage': '${(avgMood * 20).round()}',
            'count': moodLogs.length.toString(),
          },
        );

        insights.add(
          DynamicInsight(
            type: InsightType.moodTrend,
            title: 'Mood Trend',
            description: message,
            icon: Icons.mood,
            iconColor: moodColor,
            emoji: moodEmoji,
          ),
        );
      }

      // 6. IMPROVEMENT TREND (comparing weeks)
      final thisWeekStart = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final weekProgress = await _userDb.getWeeklyProgress(
        userId,
        weekStart: thisWeekStart.subtract(const Duration(days: 7)),
      );

      if (weekProgress.length >= 2) {
        final thisWeek = weekProgress[0];
        final lastWeek = weekProgress[1];

        final thisWeekMindful = thisWeek['mindful_days'] as int? ?? 0;
        final lastWeekMindful = lastWeek['mindful_days'] as int? ?? 0;

        if (thisWeekMindful > lastWeekMindful) {
          final improvement = thisWeekMindful - lastWeekMindful;
          final percentage = lastWeekMindful > 0
              ? ((improvement / lastWeekMindful) * 100).round()
              : 100;

          final message = NotificationSelector.getMessage(
            category: 'data',
            subcategory: 'frequency_change',
            variables: {
              'percentage': percentage.toString(),
              'count': improvement.toString(),
              'direction': 'improved',
            },
          );

          insights.add(
            DynamicInsight(
              type: InsightType.improvement,
              title: 'Week-over-Week',
              description: message,
              icon: Icons.arrow_upward,
              iconColor: AppColors.successGreen,
              emoji: EmojiAssets.target,
            ),
          );
        }
      }

      // 7. CONSISTENCY STREAK (from check-ins)
      if (totalCheckIns >= 5) {
        final message = NotificationSelector.getMessage(
          category: 'positive',
          subcategory: 'mindful_day',
        );

        insights.add(
          DynamicInsight(
            type: InsightType.consistencyStreak,
            title: 'Logging Champion',
            description: '$totalCheckIns total check-ins! $message',
            icon: Icons.calendar_today,
            iconColor: Color(0xFF8B5CF6),
            emoji: EmojiAssets.calendar,
          ),
        );
      }

      // 8. GOAL PROGRESS (from database)
      final onboarding = await _userDb.getOnboardingData(userId);
      if (onboarding != null) {
        final goals = onboarding['selected_goals'] as List?;
        final timeline = onboarding['selected_timeline'] as String?;

        if (goals != null && goals.isNotEmpty) {
          final primaryGoal = goals[0] as String;
          final progress = _calculateGoalProgress(
            currentLongestStreak,
            timeline ?? '30 days',
          );

          if (progress >= 0.25) {
            final message = NotificationSelector.getMessage(
              category: 'goal',
              subcategory: _mapGoalToCategory(primaryGoal),
              variables: {
                'amount': (progress * 100).round().toString(),
                'percentage': (progress * 100).round().toString(),
                'days': currentLongestStreak.toString(),
              },
            );

            insights.add(
              DynamicInsight(
                type: InsightType.goalProgress,
                title: 'Goal: $primaryGoal',
                description: message,
                icon: Icons.emoji_events,
                iconColor: AppColors.primaryGreen,
                emoji: EmojiAssets.trophy,
              ),
            );
          }
        }
      }

      // Sort by priority and return top 3-4
      insights.sort((a, b) {
        final priority = {
          InsightType.streakMilestone: 1,
          InsightType.improvement: 2,
          InsightType.weeklyProgress: 3,
          InsightType.moneySaved: 4,
          InsightType.goalProgress: 5,
          InsightType.triggerPattern: 6,
          InsightType.moodTrend: 7,
          InsightType.consistencyStreak: 8,
        };

        return (priority[a.type] ?? 99).compareTo(priority[b.type] ?? 99);
      });

      return insights.take(4).toList();
    } catch (e, stackTrace) {
      print('❌ Error building insights: $e');
      print('Stack trace: $stackTrace');

      // Fallback insight
      insights.add(
        DynamicInsight(
          type: InsightType.weeklyProgress,
          title: 'Your Journey Starts Here',
          description:
              'Log your daily check-ins to unlock personalized insights and track your progress.',
          icon: Icons.emoji_objects,
          iconColor: AppColors.primaryGreen,
          emoji: EmojiAssets.target,
        ),
      );

      return insights;
    }
  }

  // Helper methods
  String _mapTriggerToCategory(String trigger) {
    final mapping = {
      'stress': 'stress_relief',
      'boredom': 'routine_habit',
      'social': 'social_bonding',
      'emotional': 'emotional_regulation',
      'work': 'reward_system',
      'sleep': 'sleep_aid',
    };

    for (var entry in mapping.entries) {
      if (trigger.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }

    return 'stress_relief'; // default
  }

  String _mapGoalToCategory(String goal) {
    if (goal.contains('money') || goal.contains('save')) {
      return 'financial_goals';
    } else if (goal.contains('health') || goal.contains('sleep')) {
      return 'health_goals';
    } else if (goal.contains('relationship')) {
      return 'relationship_goals';
    }
    return 'health_goals'; // default
  }

  double _calculateGoalProgress(int currentStreak, String timeline) {
    int targetDays = 30;

    if (timeline.contains('90')) {
      targetDays = 90;
    } else if (timeline.contains('180')) {
      targetDays = 180;
    } else if (timeline.contains('365')) {
      targetDays = 365;
    }

    return (currentStreak / targetDays).clamp(0.0, 1.0);
  }

  Future<void> _showCheckInDialogWithAnimation() async {
    // Get the card's position and size
    final RenderBox? cardBox =
        _checkInCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox == null) {
      _showCheckInDialog();
      return;
    }

    final cardPosition = cardBox.localToGlobal(Offset.zero);
    final cardSize = cardBox.size;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Check-in',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _CheckInDialogContent(
          animation: animation,
          cardPosition: cardPosition,
          cardSize: cardSize,

          onSave: (mood, dayType, notes) async {
            print('🔘 ANIMATED DIALOG - Save button pressed');
            try {
              print('🔍 Step 1: Getting user ID');
              final userId = _userDb.currentUser?.id;
              if (userId == null) {
                print('❌ ERROR: No user ID found');
                throw Exception('No user logged in');
              }
              print('✅ User ID: $userId');

              // Determine substances based on day type
              List<String>? substancesUsed;

              print('🔍 Step 2: Checking selected day type');
              print('   Selected day type: "$dayType"');

              if (dayType == 'mindful') {
                print('   → Mindful day selected');
                substancesUsed = []; // Empty list = no substances
                print('   ✅ Set substances to empty array: $substancesUsed');
              } else {
                print('   → Used/Reduced day selected');
                print('   🔍 Step 3: Fetching onboarding data...');

                // For 'used' or 'reduced' days, get substances from onboarding
                final onboarding = await _userDb.getOnboardingData(userId);
                print('   📋 Onboarding data received: $onboarding');

                if (onboarding != null) {
                  print('   ✅ Onboarding data exists');

                  if (onboarding['selected_substances'] != null) {
                    print('   ✅ selected_substances field exists');
                    print('   Raw value: ${onboarding['selected_substances']}');
                    print(
                      '   Type: ${onboarding['selected_substances'].runtimeType}',
                    );

                    substancesUsed = List<String>.from(
                      onboarding['selected_substances'] as List,
                    );
                    print(
                      '   ✅ Got substances from onboarding: $substancesUsed',
                    );
                  } else {
                    print('   ⚠️ selected_substances field is null');
                    substancesUsed = ['substance']; // Fallback
                    print('   ⚠️ Using fallback: $substancesUsed');
                  }
                } else {
                  print('   ⚠️ Onboarding data is null');
                  substancesUsed = ['substance']; // Fallback
                  print('   ⚠️ Using fallback: $substancesUsed');
                }
              }

              print('🔍 Step 4: Preparing to save');
              print('   Final substances to save: $substancesUsed');
              print('   Mood rating: ${_getMoodRating(mood)}');
              print('   Day type: $dayType'); // ✅ ADD THIS LINE
              print('   Notes: ${notes.isNotEmpty ? notes : "(none)"}');

              // Save to database with dayType parameter
              print('💾 Step 5: Calling saveDailyLog...');
              await _userDb.saveDailyLog(
                userId: userId,
                logDate: DateTime.now(),
                dayType: dayType, // ✅ ADD THIS CRITICAL PARAMETER
                substancesUsed: substancesUsed,
                moodRating: _getMoodRating(mood),
                notes: notes.isNotEmpty ? notes : null,
              );
              print('✅ saveDailyLog completed');

              // Reload dashboard
              print('🔄 Step 6: Reloading dashboard...');
              await _loadUserData();
              print('✅ Dashboard reloaded');

              if (context.mounted) {
                print('🚪 Step 7: Closing dialog');
                Navigator.pop(context);

                print('🎉 Step 8: Showing success message');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Check-in saved successfully!'),
                    backgroundColor: AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                print('✅ ALL STEPS COMPLETED SUCCESSFULLY');
              }
            } catch (e, stackTrace) {
              print('❌❌❌ ERROR OCCURRED ❌❌❌');
              print('Error: $e');
              print('Stack trace: $stackTrace');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save check-in: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            }
          },
          userDb: _userDb,
          getFormattedDate: _getFormattedDate,
          themeProvider: ref.watch(themeProvider),
        );
      },
    );
  }

  Future<void> _showCheckInDialog() async {
    String selectedMood = 'good';
    String selectedDayType = 'mindful';
    String notes = '';

    // Get today's existing log to pre-fill
    final userId = _userDb.currentUser?.id;
    if (userId != null) {
      final todayLog = await _userDb.getDailyLog(userId, DateTime.now());
      if (todayLog != null) {
        selectedDayType = todayLog['day_type'] as String? ?? 'mindful';
        final moodRating = todayLog['mood_rating'] as int?;
        if (moodRating != null) {
          selectedMood = _getMoodFromRating(moodRating);
        }
        notes = todayLog['notes'] as String? ?? '';
      }
    }

    final moodOptions = [
      {
        'value': 'great',
        'emoji': EmojiAssets.smileGood,
        'label': 'Great',
        'color': Color(0xFF22C55E),
      },
      {
        'value': 'good',
        'emoji': EmojiAssets.smileGood,
        'label': 'Good',
        'color': Color(0xFF84CC16),
      },
      {
        'value': 'okay',
        'emoji': EmojiAssets.neutralFace,
        'label': 'Okay',
        'color': Color(0xFFF59E0B),
      },
      {
        'value': 'struggling',
        'emoji': EmojiAssets.worriedFace,
        'label': 'Struggling',
        'color': Color(0xFFEF4444),
      },
    ];

    final dayTypeOptions = [
      {
        'value': 'mindful',
        'emoji': EmojiAssets.checkmark,
        'label': 'Mindful Day',
        'color': AppColors.successGreen,
      },
      {
        'value': 'reduced',
        'emoji': EmojiAssets.target,
        'label': 'Reduced Use',
        'color': AppColors.accentOrange,
      },
      {
        'value': 'used',
        'emoji': EmojiAssets.calendar,
        'label': 'Used',
        'color': Color(0xFF6B7280),
      },
    ];

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentTheme = ref.watch(themeProvider);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: AppColorsTheme.getCard(currentTheme),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryGreen.withOpacity(0.1),
                            AppColors.successGreen.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                EmojiAssets.calendar,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today\'s Check-in',
                                  style: AppTextStyles.headlineSmall(context)
                                      .copyWith(
                                        fontSize: 18,
                                        color: AppColorsTheme.getTextPrimary(
                                          currentTheme,
                                        ),
                                      ),
                                ),
                                Text(
                                  _getFormattedDate(),
                                  style: AppTextStyles.caption(context)
                                      .copyWith(
                                        color: AppColorsTheme.getTextSecondary(
                                          currentTheme,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColorsTheme.getTextSecondary(
                                currentTheme,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mood Selection
                          Text(
                            'How are you feeling?',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColorsTheme.getTextPrimary(
                                currentTheme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: moodOptions.map((option) {
                              final isSelected =
                                  selectedMood == option['value'];
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setDialogState(() {
                                    selectedMood = option['value'] as String;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (option['color'] as Color)
                                              .withOpacity(0.15)
                                        : AppColorsTheme.getBackground(
                                            currentTheme,
                                          ),
                                    border: Border.all(
                                      color: isSelected
                                          ? (option['color'] as Color)
                                          : AppColorsTheme.getBorder(
                                              currentTheme,
                                            ),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        option['emoji'] as String,
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        option['label'] as String,
                                        style: AppTextStyles.bodySmall(context)
                                            .copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? (option['color'] as Color)
                                                  : AppColorsTheme.getTextSecondary(
                                                      currentTheme,
                                                    ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Day Type Selection
                          Text(
                            'How was your day?',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColorsTheme.getTextPrimary(
                                currentTheme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: dayTypeOptions.map((option) {
                              final isSelected =
                                  selectedDayType == option['value'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setDialogState(() {
                                      selectedDayType =
                                          option['value'] as String;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (option['color'] as Color)
                                                .withOpacity(0.1)
                                          : AppColorsTheme.getBackground(
                                              currentTheme,
                                            ),
                                      border: Border.all(
                                        color: isSelected
                                            ? (option['color'] as Color)
                                            : AppColorsTheme.getBorder(
                                                currentTheme,
                                              ),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          option['emoji'] as String,
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          option['label'] as String,
                                          style:
                                              AppTextStyles.bodyMedium(
                                                context,
                                              ).copyWith(
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? (option['color'] as Color)
                                                    : AppColorsTheme.getTextPrimary(
                                                        currentTheme,
                                                      ),
                                              ),
                                        ),
                                        const Spacer(),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: option['color'] as Color,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // Notes Section
                          Text(
                            'Notes (Optional)',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColorsTheme.getTextPrimary(
                                currentTheme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) => notes = value,
                            maxLines: 3,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              color: AppColorsTheme.getTextPrimary(
                                currentTheme,
                              ),
                            ),
                            decoration: InputDecoration(
                              hintText: 'How are you feeling? Any thoughts?',
                              hintStyle: AppTextStyles.bodySmall(context)
                                  .copyWith(
                                    color: AppColorsTheme.getTextTertiary(
                                      currentTheme,
                                    ),
                                  ),
                              filled: true,
                              fillColor: AppColorsTheme.getBackground(
                                currentTheme,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColorsTheme.getBorder(currentTheme),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColorsTheme.getBorder(currentTheme),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColorsTheme.getBorder(
                                      currentTheme,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColorsTheme.getTextSecondary(
                                        currentTheme,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                HapticFeedback.mediumImpact();

                                // Save the check-in
                                try {
                                  final userId = _userDb.currentUser?.id;
                                  if (userId == null) {
                                    throw Exception('No user logged in');
                                  }

                                  // Determine substances based on day type
                                  List<String>? substancesUsed;

                                  print(
                                    '🔍 Selected day type: $selectedDayType',
                                  );

                                  if (selectedDayType == 'mindful') {
                                    substancesUsed =
                                        []; // Empty list = no substances
                                    print('✅ Mindful day - no substances');
                                  } else {
                                    // For 'used' or 'reduced' days, get substances from onboarding
                                    final onboarding = await _userDb
                                        .getOnboardingData(userId);
                                    print('📋 Onboarding data: $onboarding');

                                    if (onboarding != null &&
                                        onboarding['selected_substances'] !=
                                            null) {
                                      substancesUsed = List<String>.from(
                                        onboarding['selected_substances']
                                            as List,
                                      );
                                      print(
                                        '✅ Got substances from onboarding: $substancesUsed',
                                      );
                                    } else {
                                      substancesUsed = [
                                        'substance',
                                      ]; // Fallback
                                      print(
                                        '⚠️ No substances found in onboarding, using fallback',
                                      );
                                    }
                                  }

                                  print(
                                    '💾 Saving with substances: $substancesUsed',
                                  );

                                  // Save to database with proper parameters including dayType
                                  await _userDb.saveDailyLog(
                                    userId: userId,
                                    logDate: DateTime.now(),
                                    dayType:
                                        selectedDayType, // ✅ ADD THIS PARAMETER
                                    substancesUsed: substancesUsed,
                                    moodRating: _getMoodRating(selectedMood),
                                    notes: notes.isNotEmpty ? notes : null,
                                  );

                                  // Reload dashboard
                                  await _loadUserData();

                                  Navigator.pop(context);

                                  // Show success message
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Check-in saved successfully!',
                                        ),
                                        backgroundColor: AppColors.successGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('❌ Error saving check-in: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to save check-in: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Save Check-in',
                                style: AppTextStyles.buttonMedium(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build goal progress
  GoalProgress _buildGoalProgress(
    Map<String, dynamic>? onboardingData,
    int currentStreak,
  ) {
    final goalName = onboardingData?['selected_goals']?.first ?? 'Stay Mindful';
    final timeline = onboardingData?['selected_timeline'] ?? '30 days';

    // Calculate progress based on streak and timeline
    int targetDays = 30;
    if (timeline.contains('90')) targetDays = 90;
    if (timeline.contains('180')) targetDays = 180;
    if (timeline.contains('365')) targetDays = 365;

    final progress = (currentStreak / targetDays).clamp(0.0, 1.0);

    return GoalProgress(
      goalName: goalName,
      subtitle: timeline,
      progress: progress,
      metric: '${(progress * 100).round()}% achieved',
    );
  }

  /// Build today's entry
  DailyEntry _buildTodaysEntry(Map<String, dynamic>? todayLog) {
    if (todayLog == null) {
      return DailyEntry(
        date: DateTime.now(),
        isCompleted: false,
        notes: "No entry yet",
        dayType: DayType.mindful,
      );
    }

    final dayTypeStr = todayLog['day_type'] as String?;
    final notes = todayLog['notes'] as String? ?? "Entry logged";

    DayType dayType;
    if (dayTypeStr == 'mindful') {
      dayType = DayType.mindful;
    } else if (dayTypeStr == 'reduced') {
      dayType = DayType.reduced;
    } else {
      dayType = DayType.used;
    }

    return DailyEntry(
      date: DateTime.now(),
      isCompleted: true,
      notes: notes,
      dayType: dayType,
    );
  }

  /// Get mood from log
  UserMood _getMoodFromLog(Map<String, dynamic>? log) {
    if (log == null) return UserMood.okay;

    final moodRating = log['mood_rating'] as int?;
    if (moodRating == null) return UserMood.okay;

    if (moodRating >= 4) return UserMood.good;
    if (moodRating >= 3) return UserMood.okay;
    return UserMood.struggling;
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

  // Get responsive padding based on screen size
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return const EdgeInsets.all(24);
    } else if (width > 400) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }

  // Get responsive emoji size
  double _getEmojiSize(BuildContext context, {required String type}) {
    final width = MediaQuery.of(context).size.width;
    switch (type) {
      case 'header':
        return width > 400 ? 28 : 24;
      case 'stat':
        return width > 400 ? 22 : 20;
      case 'checkin':
        return width > 400 ? 32 : 28;
      case 'insight':
        return width > 400 ? 26 : 24;
      case 'small':
        return width > 400 ? 18 : 16;
      default:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider); // ADD THIS LINE
    final bottomNavHeight = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme), // UPDATED
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Loading your progress...',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColorsTheme.getTextPrimary(
                          currentTheme,
                        ), // UPDATED
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: _getResponsivePadding(context),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(currentTheme), // PASS THEME
                      const SizedBox(height: GroundedSpacing.xl),
                      _buildStatsGrid(currentTheme), // PASS THEME
                      const SizedBox(height: GroundedSpacing.xxl),
                      _buildSectionTitle(
                        'Today\'s Check-in',
                        currentTheme,
                      ), // PASS THEME
                      const SizedBox(height: GroundedSpacing.lg),
                      _buildCheckInCard(currentTheme), // PASS THEME
                      const SizedBox(height: GroundedSpacing.xxl),
                      _buildSectionTitle(
                        'Weekly Overview',
                        currentTheme,
                      ), // PASS THEME
                      const SizedBox(height: GroundedSpacing.lg),
                      _buildWeeklyCard(currentTheme), // PASS THEME
                      const SizedBox(height: GroundedSpacing.xxl),
                      _buildSectionTitle(
                        'Pattern Insights',
                        currentTheme,
                      ), // PASS THEME
                      const SizedBox(height: GroundedSpacing.lg),
                      ..._data.insights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: GroundedSpacing.md,
                          ),
                          child: _buildInsightCard(
                            insight,
                            currentTheme,
                          ), // PASS THEME
                        ),
                      ),
                      const SizedBox(height: GroundedSpacing.xxl),
                      _buildSectionTitle(
                        'Goal Progress',
                        currentTheme,
                      ), // PASS THEME
                      const SizedBox(height: GroundedSpacing.lg),
                      _buildGoalCard(currentTheme), // PASS THEME
                      SizedBox(height: 80 + bottomNavHeight),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: _buildFAB(currentTheme), // PASS THEME
    );
  }

  // Update this part in your dashboard_screen.dart

  Widget _buildHeader(AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerSize = screenWidth > 400 ? 48.0 : 44.0;
    final iconSize = screenWidth > 400 ? 44.0 : 40.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: headerSize,
              height: headerSize,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D5016), Color(0xFF3D5A3C)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5016).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 24),
            ),
            const SizedBox(width: GroundedSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Grounded',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                Text(
                  'Hi Piyush',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColorsTheme.getTextSecondary(currentTheme),
                  ),
                ),
                Text(
                  _getFormattedDate(),
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColorsTheme.getTextTertiary(currentTheme),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColorsTheme.getCard(currentTheme),
            border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            icon: Image.asset(
              EmojiAssets.settings,
              width: _getEmojiSize(context, type: 'checkin'),
              height: _getEmojiSize(context, type: 'checkin'),
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.lightImpact();

              final screenWidth = MediaQuery.of(context).size.width;
              final topPadding = MediaQuery.of(context).padding.top;
              final horizontalPadding = _getResponsivePadding(context).left;

              final tapPosition = Offset(
                screenWidth - horizontalPadding - (iconSize / 2),
                topPadding + horizontalPadding + (iconSize / 2),
              );

              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.transparent,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return SettingsScreen(tapPosition: tapPosition);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final childAspectRatio = screenWidth > 400 ? 1.5 : 1.4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: GroundedSpacing.md,
      crossAxisSpacing: GroundedSpacing.md,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          currentTheme: currentTheme,
          emoji: EmojiAssets.fire,
          iconColor: const Color(0xFFEA580C),
          value: '${_data.currentStreak}',
          label: 'Day Streak',
        ),
        _buildStatCard(
          currentTheme: currentTheme,
          emoji: EmojiAssets.trophy,
          iconColor: const Color(0xFFA855F7),
          value: '${_data.thisMonth}',
          label: 'This Month',
        ),
        _buildStatCard(
          currentTheme: currentTheme,
          emoji: EmojiAssets.barChart,
          iconColor: const Color(0xFF3B82F6),
          value: '${_data.weeklyAverage}',
          label: 'Weekly Avg',
        ),
        _buildStatCard(
          currentTheme: currentTheme,
          emoji: EmojiAssets.moneyBag,
          iconColor: AppColors.successGreen,
          value: '\$${_data.moneySaved.toInt()}',
          label: 'Money Saved',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required AppThemeMode currentTheme,
    required String emoji,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final emojiContainerSize = screenWidth > 400 ? 40.0 : 36.0;

    final isMoneySaved = label == 'Money Saved';
    final moneyValue = isMoneySaved ? _data.moneySaved : 0.0;
    final isNegative = isMoneySaved && moneyValue < 0;

    final displayLabel = isNegative ? 'Money Spent' : label;
    final displayColor = isNegative
        ? Colors.red
        : AppColorsTheme.getTextPrimary(currentTheme);
    final displayIconColor = isNegative ? Colors.red : iconColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (label == 'Day Streak') {
                return StreakDetailScreen(currentStreak: _data.currentStreak);
              } else if (label == 'This Month') {
                return MonthDetailScreen(daysThisMonth: _data.thisMonth);
              } else if (label == 'Weekly Avg') {
                return WeeklyAvgDetailScreen(
                  weeklyAverage: _data.weeklyAverage,
                );
              } else if (label == 'Money Saved') {
                return MoneySavedDetailScreen(moneySaved: _data.moneySaved);
              }
              return Container();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);
                  var fadeAnimation = animation.drive(
                    Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeIn)),
                  );

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: fadeAnimation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(
          screenWidth > 400 ? GroundedSpacing.lg : GroundedSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
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
            Container(
              width: emojiContainerSize,
              height: emojiContainerSize,
              decoration: BoxDecoration(
                color: displayIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  emoji,
                  width: _getEmojiSize(context, type: 'stat'),
                  height: _getEmojiSize(context, type: 'stat'),
                ),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: screenWidth > 400 ? 28 : 24,
                fontWeight: FontWeight.w700,
                color: displayColor,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: GroundedSpacing.xs),
            Text(
              displayLabel,
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.w500,
                color: isNegative
                    ? Colors.red.withOpacity(0.8)
                    : AppColorsTheme.getTextSecondary(currentTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppThemeMode currentTheme) {
    return Text(
      title,
      style: AppTextStyles.headlineSmall(context).copyWith(
        fontSize: 18,
        color: AppColorsTheme.getTextPrimary(currentTheme),
      ),
    );
  }

  Widget _buildCheckInCard(AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth > 400 ? 64.0 : 56.0;
    final iconButtonSize = screenWidth > 400 ? 44.0 : 40.0;

    // Get real data from _data
    final todaysEntry = _data.todaysEntry;
    final hasEntry = todaysEntry?.isCompleted == true; // Explicit boolean check

    // Determine mood emoji and text
    String moodEmoji;
    String moodText;
    String dayTypeText;
    String dayTypeEmoji;
    Color dayTypeColor;

    if (hasEntry) {
      // Get mood text based on current mood
      switch (_data.currentMood) {
        case UserMood.good:
          moodEmoji = EmojiAssets.smileGood;
          moodText = 'Feeling good';
          break;
        case UserMood.okay:
          moodEmoji = EmojiAssets.neutralFace;
          moodText = 'Feeling okay';
          break;
        case UserMood.struggling:
          moodEmoji = EmojiAssets.worriedFace;
          moodText = 'Feeling challenged';
          break;
        default:
          moodEmoji = EmojiAssets.smileGood;
          moodText = 'Feeling good';
      }

      // Get day type details - handle null case
      switch (todaysEntry?.dayType) {
        case DayType.mindful:
          dayTypeEmoji = EmojiAssets.checkmark;
          dayTypeText = 'Mindful day';
          dayTypeColor = AppColors.successGreen;
          break;
        case DayType.reduced:
          dayTypeEmoji = EmojiAssets.target;
          dayTypeText = 'Reduced use';
          dayTypeColor = AppColors.accentOrange;
          break;
        case DayType.used:
          dayTypeEmoji = EmojiAssets.calendar;
          dayTypeText = 'Used today';
          dayTypeColor = const Color(0xFF6B7280);
          break;
        case null: // Handle null case
        default:
          dayTypeEmoji = EmojiAssets.calendar;
          dayTypeText = 'Unknown day type';
          dayTypeColor = const Color(0xFF6B7280);
      }
    } else {
      // No entry yet today
      moodEmoji = EmojiAssets.calendar;
      moodText = 'No check-in yet';
      dayTypeEmoji = EmojiAssets.pencil;
      dayTypeText = 'Tap to check in';
      dayTypeColor = AppColorsTheme.getTextSecondary(currentTheme);
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCheckInDialogWithAnimation();
      },
      child: Container(
        key: _checkInCardKey,
        padding: EdgeInsets.all(
          screenWidth > 400 ? GroundedSpacing.lg : GroundedSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
          borderRadius: BorderRadius.circular(16),
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
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: hasEntry
                      ? [
                          dayTypeColor.withOpacity(0.15),
                          dayTypeColor.withOpacity(0.05),
                        ]
                      : [
                          AppColorsTheme.getBorder(
                            currentTheme,
                          ).withOpacity(0.3),
                          AppColorsTheme.getBorder(
                            currentTheme,
                          ).withOpacity(0.1),
                        ],
                ),
                border: Border.all(
                  color: hasEntry
                      ? dayTypeColor.withOpacity(0.2)
                      : AppColorsTheme.getBorder(currentTheme),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  moodEmoji,
                  width: _getEmojiSize(context, type: 'checkin'),
                  height: _getEmojiSize(context, type: 'checkin'),
                ),
              ),
            ),
            const SizedBox(width: GroundedSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodText,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                  const SizedBox(height: GroundedSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GroundedSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: dayTypeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(dayTypeEmoji, width: 14, height: 14),
                        const SizedBox(width: 4),
                        Text(
                          dayTypeText,
                          style: AppTextStyles.caption(context).copyWith(
                            fontWeight: FontWeight.w500,
                            color: dayTypeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: iconButtonSize,
              height: iconButtonSize,
              decoration: BoxDecoration(
                color: AppColorsTheme.getCard(currentTheme),
                border: Border.all(
                  color: AppColorsTheme.getBorder(currentTheme),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Image.asset(
                  EmojiAssets.pencil,
                  width: _getEmojiSize(context, type: 'small'),
                  height: _getEmojiSize(context, type: 'small'),
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showCheckInDialogWithAnimation();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;

    // FIXED: Only count days with actual mindful logs (height > 80 indicates real mindful day)
    final mindfulCount = _data.weeklyData
        .where((d) => d.dayType == DayType.mindful && d.height > 80)
        .length;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return WeeklyOverviewDetailScreen(weeklyData: _data.weeklyData);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);
                  var fadeAnimation = animation.drive(
                    Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeIn)),
                  );

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: fadeAnimation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(
          screenWidth > 400 ? GroundedSpacing.lg : GroundedSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
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
            SizedBox(
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _data.weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isToday = index == _data.weeklyData.length - 1;
                  return _buildWeeklyBar(data, isToday, currentTheme);
                }).toList(),
              ),
            ),
            const SizedBox(height: GroundedSpacing.lg),
            Container(
              padding: const EdgeInsets.all(GroundedSpacing.md),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(EmojiAssets.checkmark, width: 22, height: 22),
                  const SizedBox(width: GroundedSpacing.sm),
                  Flexible(
                    child: Text(
                      '$mindfulCount mindful days this week',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColorsTheme.getTextSecondary(currentTheme),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBar(
    WeeklyData data,
    bool isToday,
    AppThemeMode currentTheme,
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
          width: 32,
          height: data.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [barColor, barColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: GroundedSpacing.sm),
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

  Widget _buildInsightCard(Insight insight, AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 400 ? 52.0 : 48.0;

    // Get emoji and color from DynamicInsight if available
    final String emojiAsset;
    final Color iconColor;

    if (insight is DynamicInsight) {
      emojiAsset = insight.emoji;
      iconColor = insight.iconColor;
    } else {
      // Fallback for regular Insight
      emojiAsset = insight.icon == Icons.trending_up
          ? EmojiAssets.chartUp
          : EmojiAssets.lightbulb;
      iconColor = AppColors.successGreen;
    }

    return Container(
      padding: EdgeInsets.all(
        screenWidth > 400 ? GroundedSpacing.lg : GroundedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(16),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withOpacity(0.15),
                  iconColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                emojiAsset,
                width: _getEmojiSize(context, type: 'insight'),
                height: _getEmojiSize(context, type: 'insight'),
              ),
            ),
          ),
          const SizedBox(width: GroundedSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                const SizedBox(height: GroundedSpacing.xs),
                Text(
                  insight.description,
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

  Widget _buildGoalCard(AppThemeMode currentTheme) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(
        screenWidth > 400 ? GroundedSpacing.lg : GroundedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data.goalProgress.goalName,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                    const SizedBox(height: GroundedSpacing.xs),
                    Text(
                      _data.goalProgress.subtitle,
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColorsTheme.getTextSecondary(currentTheme),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(_data.goalProgress.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: screenWidth > 400 ? 24 : 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: GroundedSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: _data.goalProgress.progress,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: GroundedSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _data.goalProgress.metric,
                style: AppTextStyles.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColorsTheme.getTextSecondary(currentTheme),
                ),
              ),
              Row(
                children: [
                  Image.asset(EmojiAssets.target, width: 18, height: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Keep going',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(AppThemeMode currentTheme) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 8 : 0),
      child: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.mediumImpact();

          final result = await Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.5),
              barrierDismissible: true,
              pageBuilder: (context, animation, secondaryAnimation) {
                return const AddEntryScreen();
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );

          if (result != null) {
            HapticFeedback.lightImpact();
            _refreshDashboard();
          }
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 8,
        icon: Image.asset(EmojiAssets.plus, width: 22, height: 22),
        label: Text(
          'Add Entry',
          style: AppTextStyles.buttonMedium(context).copyWith(fontSize: 15),
        ),
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    final stats = await EntryService.getDashboardStats();

    setState(() {
      _data = DashboardData(
        currentStreak: stats['currentStreak'] as int,
        thisMonth: stats['thisMonth'] as int,
        weeklyAverage: stats['weeklyAverage'] as double,
        moneySaved: stats['moneySaved'] as double,
        todaysEntry: DailyEntry(
          date: DateTime.now(),
          isCompleted: stats['todayEntries'] > 0,
          notes: "Entry logged",
          dayType: _getDayTypeFromString(stats['todayType'] as String),
        ),
        weeklyData: _data.weeklyData, // Keep existing or regenerate
        insights: _data.insights,
        goalProgress: _data.goalProgress,
        currentMood: UserMood.good,
      );
    });
  }

  int _getMoodRating(String mood) {
    switch (mood) {
      case 'great':
        return 5;
      case 'good':
        return 4;
      case 'okay':
        return 3;
      case 'struggling':
        return 2;
      default:
        return 3;
    }
  }

  String _getMoodFromRating(int rating) {
    if (rating >= 5) return 'great';
    if (rating >= 4) return 'good';
    if (rating >= 3) return 'okay';
    return 'struggling';
  }

  DayType _getDayTypeFromString(String type) {
    switch (type) {
      case 'mindful':
        return DayType.mindful;
      case 'reduced':
        return DayType.reduced;
      case 'used':
        return DayType.used;
      default:
        return DayType.mindful;
    }
  }
}

class _CheckInDialogContent extends StatefulWidget {
  final Animation<double> animation;
  final Offset cardPosition;
  final Size cardSize;
  final Future<void> Function(String mood, String dayType, String notes) onSave;
  final UserDatabaseService userDb;
  final String Function() getFormattedDate;
  final AppThemeMode themeProvider;

  const _CheckInDialogContent({
    required this.animation,
    required this.cardPosition,
    required this.cardSize,
    required this.onSave,
    required this.userDb,
    required this.getFormattedDate,
    required this.themeProvider,
  });

  @override
  State<_CheckInDialogContent> createState() => _CheckInDialogContentState();
}

class _CheckInDialogContentState extends State<_CheckInDialogContent> {
  String selectedMood = 'good';
  String selectedDayType = 'mindful';
  final TextEditingController notesController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final userId = widget.userDb.currentUser?.id;
    if (userId != null) {
      final todayLog = await widget.userDb.getDailyLog(userId, DateTime.now());
      if (todayLog != null && mounted) {
        setState(() {
          selectedDayType = todayLog['day_type'] as String? ?? 'mindful';
          final moodRating = todayLog['mood_rating'] as int?;
          if (moodRating != null) {
            selectedMood = _getMoodFromRating(moodRating);
          }
          notesController.text = todayLog['notes'] as String? ?? '';
        });
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  String _getMoodFromRating(int rating) {
    if (rating >= 5) return 'great';
    if (rating >= 4) return 'good';
    if (rating >= 3) return 'okay';
    return 'struggling';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Animation curves
    final slideAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
    );

    final fadeAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    // Calculate positions
    final startX = widget.cardPosition.dx;
    final startY = widget.cardPosition.dy;
    final endX =
        (screenSize.width - 500.0.clamp(300, screenSize.width - 40)) / 2;
    final endY = screenSize.height * 0.15;

    final moodOptions = [
      {
        'value': 'great',
        'emoji': EmojiAssets.noWorries,
        'label': 'Great',
        'color': Color(0xFF22C55E),
      },
      {
        'value': 'good',
        'emoji': EmojiAssets.smileGood,
        'label': 'Good',
        'color': Color(0xFF84CC16),
      },
      {
        'value': 'okay',
        'emoji': EmojiAssets.neutralFace,
        'label': 'Okay',
        'color': Color(0xFFF59E0B),
      },
      {
        'value': 'struggling',
        'emoji': EmojiAssets.sadFace,
        'label': 'Struggling',
        'color': Color(0xFFEF4444),
      },
    ];

    final dayTypeOptions = [
      {
        'value': 'mindful',
        'emoji': EmojiAssets.checkmark,
        'label': 'Mindful Day',
        'color': AppColors.successGreen,
      },
      {
        'value': 'reduced',
        'emoji': EmojiAssets.target,
        'label': 'Reduced Use',
        'color': AppColors.accentOrange,
      },
      {
        'value': 'used',
        'emoji': EmojiAssets.calendar,
        'label': 'Used',
        'color': Color(0xFF6B7280),
      },
    ];

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final t = slideAnimation.value;
        final currentX = startX + (endX - startX) * t;
        final currentY = startY + (endY - startY) * t;
        final currentWidth =
            widget.cardSize.width +
            (500.0.clamp(300, screenSize.width - 40) - widget.cardSize.width) *
                t;
        final currentHeight =
            widget.cardSize.height + (600.0 - widget.cardSize.height) * t;

        return Stack(
          children: [
            Positioned(
              left: currentX,
              top: currentY,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: currentWidth,
                  height: currentHeight,
                  decoration: BoxDecoration(
                    color: AppColorsTheme.getCard(widget.themeProvider),
                    borderRadius: BorderRadius.circular(16 + (8 * t)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1 + (0.1 * t)),
                        blurRadius: 3 + (17 * t),
                        offset: Offset(0, 1 + (9 * t)),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16 + (8 * t)),
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryGreen.withOpacity(0.1),
                                    AppColors.successGreen.withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        EmojiAssets.calendar,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today\'s Check-in',
                                          style:
                                              AppTextStyles.headlineSmall(
                                                context,
                                              ).copyWith(
                                                fontSize: 18,
                                                color:
                                                    AppColorsTheme.getTextPrimary(
                                                      widget.themeProvider,
                                                    ),
                                              ),
                                        ),
                                        Text(
                                          widget.getFormattedDate(),
                                          style: AppTextStyles.caption(context)
                                              .copyWith(
                                                color:
                                                    AppColorsTheme.getTextSecondary(
                                                      widget.themeProvider,
                                                    ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: AppColorsTheme.getTextSecondary(
                                        widget.themeProvider,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mood Selection
                                  Text(
                                    'How are you feeling?',
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColorsTheme.getTextPrimary(
                                            widget.themeProvider,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: moodOptions.map((option) {
                                      final isSelected =
                                          selectedMood == option['value'];
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(
                                            () => selectedMood =
                                                option['value'] as String,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (option['color'] as Color)
                                                      .withOpacity(0.15)
                                                : AppColorsTheme.getBackground(
                                                    widget.themeProvider,
                                                  ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? (option['color'] as Color)
                                                  : AppColorsTheme.getBorder(
                                                      widget.themeProvider,
                                                    ),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                option['emoji'] as String,
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                option['label'] as String,
                                                style:
                                                    AppTextStyles.bodySmall(
                                                      context,
                                                    ).copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? (option['color']
                                                                as Color)
                                                          : AppColorsTheme.getTextSecondary(
                                                              widget
                                                                  .themeProvider,
                                                            ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),

                                  // Day Type Selection
                                  Text(
                                    'How was your day?',
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColorsTheme.getTextPrimary(
                                            widget.themeProvider,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...dayTypeOptions.map((option) {
                                    final isSelected =
                                        selectedDayType == option['value'];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          print(
                                            '🎯 DAY TYPE TAPPED: ${option['value']}',
                                          );
                                          print(
                                            '   Previous value: $selectedDayType',
                                          );
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            selectedDayType =
                                                option['value'] as String;
                                          });
                                          print(
                                            '   New value: $selectedDayType',
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (option['color'] as Color)
                                                      .withOpacity(0.1)
                                                : AppColorsTheme.getBackground(
                                                    widget.themeProvider,
                                                  ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? (option['color'] as Color)
                                                  : AppColorsTheme.getBorder(
                                                      widget.themeProvider,
                                                    ),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                option['emoji'] as String,
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                option['label'] as String,
                                                style:
                                                    AppTextStyles.bodyMedium(
                                                      context,
                                                    ).copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? (option['color']
                                                                as Color)
                                                          : AppColorsTheme.getTextPrimary(
                                                              widget
                                                                  .themeProvider,
                                                            ),
                                                    ),
                                              ),
                                              const Spacer(),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color:
                                                      option['color'] as Color,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),

                            // Buttons
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: BorderSide(
                                            color: AppColorsTheme.getBorder(
                                              widget.themeProvider,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: AppTextStyles.bodyMedium(context)
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppColorsTheme.getTextSecondary(
                                                    widget.themeProvider,
                                                  ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        // Call the onSave callback with current values
                                        await widget.onSave(
                                          selectedMood,
                                          selectedDayType,
                                          notesController.text,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Save Check-in',
                                        style: AppTextStyles.buttonMedium(
                                          context,
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
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
