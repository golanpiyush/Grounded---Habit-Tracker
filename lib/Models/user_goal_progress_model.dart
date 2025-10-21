class GoalProgress {
  final String goalName;
  final String subtitle;
  final double progress;
  final String metric;

  GoalProgress({
    required this.goalName,
    required this.subtitle,
    required this.progress,
    required this.metric,
  });
}

enum UserMood { good, balanced, okay, struggling }
