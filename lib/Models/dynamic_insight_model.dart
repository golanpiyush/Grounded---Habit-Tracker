import 'dart:ui';

import 'package:Grounded/models/user_insight_model.dart';

enum InsightType {
  weeklyProgress,
  triggerPattern,
  streakMilestone,
  moneySaved,
  moodTrend,
  timePattern,
  improvement,
  weekendPattern,
  consistencyStreak,
  goalProgress,
}

class DynamicInsight extends Insight {
  final InsightType type;
  final Color iconColor;
  final String emoji;

  DynamicInsight({
    required super.title,
    required super.description,
    required super.icon,
    required this.type,
    required this.iconColor,
    required this.emoji,
  });
}
