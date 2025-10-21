import 'package:grounded/models/user_goal_progress_model.dart';
import 'package:grounded/models/user_insight_model.dart';
import 'package:grounded/models/user_weekly_model.dart';
import 'package:grounded/models/userdailyentrymodel.dart' hide DailyEntry;

class DashboardData {
  final int currentStreak;
  final int thisMonth;
  final double weeklyAverage;
  final double moneySaved;
  final DailyEntry? todaysEntry;
  final List<WeeklyData> weeklyData;
  final List<Insight> insights;
  final GoalProgress goalProgress;
  final UserMood currentMood;

  DashboardData({
    required this.currentStreak,
    required this.thisMonth,
    required this.weeklyAverage,
    required this.moneySaved,
    this.todaysEntry,
    required this.weeklyData,
    required this.insights,
    required this.goalProgress,
    required this.currentMood,
  });
}
