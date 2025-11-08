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
