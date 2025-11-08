// lib/services/integrated_notification_service.dart

import 'package:Grounded/Services/SmartNotifications/notificationsTemplate.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../providers/userDB.dart';
import '../models/onboarding_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integrated notification service that connects:
/// - UserDatabaseService (Supabase data)
/// - Stats providers (real-time calculations)
/// - Notification messages (7-layer insight model)
class IntegratedNotificationService {
  static final IntegratedNotificationService _instance =
      IntegratedNotificationService._internal();
  factory IntegratedNotificationService() => _instance;
  IntegratedNotificationService._internal();

  final UserDatabaseService _db = UserDatabaseService();

  // Notification IDs
  static const int ID_EMOTIONAL = 1000;
  static const int ID_PREDICTIVE = 2000;
  static const int ID_SUPPORTIVE = 3000;
  static const int ID_REFLECTIVE = 4000;
  static const int ID_GOAL_BASED = 5000;
  static const int ID_POSITIVE = 6000;
  static const int ID_TIME_BASED = 7000;

  /// Initialize notifications after user authentication
  Future<void> initializeAfterAuth(String userId) async {
    print('🔔 Initializing notifications for user: $userId');

    try {
      // Check if user has completed onboarding
      final hasOnboarding = await _db.isOnboardingComplete(userId);

      if (!hasOnboarding) {
        print('⚠️ User has not completed onboarding yet');
        return;
      }

      // Fetch onboarding data from Supabase
      final onboardingData = await _db.getOnboardingData(userId);
      if (onboardingData == null) {
        print('⚠️ No onboarding data found');
        return;
      }

      // Convert Map to OnboardingData model
      final data = _mapToOnboardingData(onboardingData);

      // Schedule all notifications based on real data
      await scheduleFromOnboardingData(userId, data);

      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Schedule notifications from onboarding data (from Supabase)
  Future<void> scheduleFromOnboardingData(
    String userId,
    OnboardingData data,
  ) async {
    print('🔔 Scheduling notifications from onboarding data...');

    // Get user profile for personalization
    final profile = await _db.getUserProfile(userId);
    final userName =
        profile?['full_name']?.toString().split(' ').first ?? 'friend';

    // Save user name for use in notifications
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);

    // Parse usage patterns
    final patterns = data.usagePatterns;
    final reasons = data.selectedReasons?.toList() ?? [];
    final primaryReason = data.primaryReason;
    final goals = data.selectedGoals.toList();
    final emergencyContacts = data.emergencyContacts;

    // Cancel all existing notifications first
    await AwesomeNotifications().cancelAllSchedules();

    // 1. Schedule emotional support (Layer 3)
    await _scheduleEmotionalSupport(
      reasons: reasons,
      primaryReason: primaryReason,
      patterns: patterns,
      userName: userName,
    );

    // 2. Schedule interpretive insights (Layer 4)
    await _scheduleInterpretiveInsights(
      reasons: reasons,
      primaryReason: primaryReason,
      patterns: patterns,
      userName: userName,
    );

    // 3. Schedule predictive alerts (Layer 5)
    await _schedulePredictiveAlerts(
      userId: userId,
      patterns: patterns,
      reasons: reasons,
      userName: userName,
    );

    // 4. Schedule supportive prompts (Layer 6)
    await _scheduleSupportivePrompts(
      reasons: reasons,
      patterns: patterns,
      emergencyContacts: emergencyContacts,
      userName: userName,
    );

    // 5. Schedule goal reminders
    await _scheduleGoalReminders(
      goals: goals,
      timeline: data.selectedTimeline,
      targetDate: data.targetDate,
      userName: userName,
    );

    // 6. Schedule time-based check-ins
    await _scheduleTimeBasedCheckins(patterns: patterns, userName: userName);

    // 7. Schedule weekly reflections (Layer 7)
    await _scheduleWeeklyReflections(userName: userName);

    print('✅ All notifications scheduled');
  }

  /// LAYER 3: Emotional Support
  Future<void> _scheduleEmotionalSupport({
    required List<String> reasons,
    String? primaryReason,
    Map<String, dynamic>? patterns,
    required String userName,
  }) async {
    print('  💚 Scheduling emotional support...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    final emotionalMap = {
      'stress_anxiety': 'stress_anxiety',
      'boredom': 'boredom',
      'loneliness': 'loneliness',
      'emotional_pain': 'loneliness',
      'social_situations': 'celebration',
    };

    int notifId = ID_EMOTIONAL;

    for (final reason in reasons) {
      final emotionalKey = emotionalMap[reason];
      if (emotionalKey == null) continue;

      final message = NotificationSelector.getMessage(
        category: 'emotional',
        subcategory: emotionalKey,
        variables: {
          'userName': userName,
          'score': '3',
          'percentage': '70',
          'count': '5',
        },
      );

      final targetTime = _getTargetTime(times, hoursBefore: 1);

      await _scheduleDaily(
        id: notifId++,
        title: 'Emotional check-in',
        body: message,
        time: targetTime,
        actionButtons: [
          NotificationActionButton(key: 'log_mood', label: 'Log mood'),
          NotificationActionButton(key: 'breathing', label: '3-min breathing'),
        ],
      );
    }
  }

  /// LAYER 4: Interpretive Insights
  Future<void> _scheduleInterpretiveInsights({
    required List<String> reasons,
    String? primaryReason,
    Map<String, dynamic>? patterns,
    required String userName,
  }) async {
    print('  🧠 Scheduling interpretive insights...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    final interpretiveMap = {
      'stress_anxiety': 'stress_relief',
      'boredom': 'routine_habit',
      'social_situations': 'social_bonding',
      'emotional_pain': 'emotional_regulation',
      'after_work': 'reward_system',
      'sleep_issues': 'sleep_aid',
    };

    int notifId = ID_EMOTIONAL + 100;

    final mainReason =
        primaryReason ?? (reasons.isNotEmpty ? reasons.first : null);
    if (mainReason != null) {
      final interpretiveKey = interpretiveMap[mainReason];
      if (interpretiveKey != null) {
        final message = NotificationSelector.getMessage(
          category: 'interpretive',
          subcategory: interpretiveKey,
          variables: {'time': '8 PM'},
        );

        final targetTime = _getTargetTime(times, hoursBefore: 2);

        await _scheduleDaily(
          id: notifId++,
          title: '$userName, quick reflection',
          body: message,
          time: targetTime,
          actionButtons: [
            NotificationActionButton(key: 'reflect', label: 'Tell me more'),
            NotificationActionButton(key: 'dismiss', label: 'Not now'),
          ],
        );
      }
    }
  }

  /// LAYER 5: Predictive Alerts (uses real historical data)
  Future<void> _schedulePredictiveAlerts({
    required String userId,
    Map<String, dynamic>? patterns,
    required List<String> reasons,
    required String userName,
  }) async {
    print('  🔮 Scheduling predictive alerts...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    int notifId = ID_PREDICTIVE;

    // Fetch actual usage patterns from last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final logs = await _db.getLogsForRange(userId, startDate, endDate);

    // Analyze actual usage times
    final Map<int, int> hourUsage = {};
    for (var log in logs) {
      final timestamp = DateTime.parse(log['timestamp'] as String);
      final hour = timestamp.hour;
      hourUsage[hour] = (hourUsage[hour] ?? 0) + 1;
    }

    // Find peak usage hour
    int? peakHour;
    int maxCount = 0;
    hourUsage.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        peakHour = hour;
      }
    });

    // Time-based prediction using real data
    if (peakHour != null) {
      final timeStr = _formatHour(peakHour!);
      final message = NotificationSelector.getMessage(
        category: 'predictive',
        subcategory: 'time_based_warning',
        variables: {'time': timeStr, 'day': 'weekday', 'when': 'after work'},
      );

      // Schedule 1 hour before peak usage
      final notifHour = (peakHour! - 1).clamp(0, 23);
      await _scheduleDaily(
        id: notifId++,
        title: 'Pattern alert',
        body: message,
        time: TimeOfDay(hour: notifHour, minute: 0),
      );
    }

    // Stress prediction (Wednesdays)
    if (reasons.contains('stress_anxiety') || reasons.contains('after_work')) {
      final message = NotificationSelector.getMessage(
        category: 'predictive',
        subcategory: 'stress_prediction',
        variables: {'days': 'Wednesday'},
      );

      await _scheduleWeekly(
        id: notifId++,
        title: 'Midweek check-in',
        body: message,
        dayOfWeek: DateTime.wednesday,
        time: const TimeOfDay(hour: 16, minute: 0),
      );
    }

    // Weekend social prediction
    if (reasons.contains('social_situations')) {
      final message = NotificationSelector.getMessage(
        category: 'predictive',
        subcategory: 'social_weekend',
        variables: {'percentage': '40'},
      );

      await _scheduleWeekly(
        id: notifId++,
        title: 'Weekend heads-up',
        body: message,
        dayOfWeek: DateTime.friday,
        time: const TimeOfDay(hour: 18, minute: 0),
      );
    }
  }

  /// LAYER 6: Supportive Prompts
  Future<void> _scheduleSupportivePrompts({
    required List<String> reasons,
    Map<String, dynamic>? patterns,
    List<Map<String, String>>? emergencyContacts,
    required String userName,
  }) async {
    print('  🛠️ Scheduling supportive prompts...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    int notifId = ID_SUPPORTIVE;

    final copingMap = {
      'stress_anxiety': 'breathing_prompts',
      'boredom': 'alternative_activities',
      'emotional_pain': 'social_support',
      'habit_routine': 'mindful_pause',
    };

    for (final reason in reasons) {
      final copingKey = copingMap[reason];
      if (copingKey == null) continue;

      final contactName = emergencyContacts?.isNotEmpty == true
          ? emergencyContacts!.first['name'] ?? 'your support person'
          : 'your support person';

      final message = NotificationSelector.getMessage(
        category: 'supportive',
        subcategory: copingKey,
        variables: {
          'contact_name': contactName,
          'amount': '2 joints',
          'activity': 'a quick walk',
        },
      );

      final targetTime = _getTargetTime(times, minutesBefore: 30);

      await _scheduleDaily(
        id: notifId++,
        title: 'Try this first?',
        body: message,
        time: targetTime,
        actionButtons: [
          NotificationActionButton(
            key: 'try_it',
            label: copingKey == 'breathing_prompts'
                ? 'Start breathing'
                : 'Show options',
          ),
          NotificationActionButton(key: 'skip', label: 'Skip'),
        ],
      );
    }

    // Harm reduction reminder
    final harmReductionMsg = NotificationSelector.getMessage(
      category: 'supportive',
      subcategory: 'harm_reduction',
      variables: {'amount': '2 joints'},
    );

    final targetTime = _getTargetTime(times, minutesBefore: 15);
    await _scheduleDaily(
      id: notifId++,
      title: 'Safety reminder',
      body: harmReductionMsg,
      time: targetTime,
    );
  }

  /// LAYER 7: Weekly Reflections
  Future<void> _scheduleWeeklyReflections({required String userName}) async {
    print('  🌟 Scheduling weekly reflections...');

    final message = NotificationSelector.getMessage(
      category: 'reflective',
      subcategory: 'progress_monthly',
    );

    await _scheduleWeekly(
      id: ID_REFLECTIVE,
      title: 'Weekly reflection',
      body: message,
      dayOfWeek: DateTime.sunday,
      time: const TimeOfDay(hour: 20, minute: 0),
      actionButtons: [
        NotificationActionButton(
          key: 'view_report',
          label: 'View weekly report',
        ),
      ],
    );
  }

  /// Schedule goal reminders
  Future<void> _scheduleGoalReminders({
    required List<String> goals,
    String? timeline,
    DateTime? targetDate,
    required String userName,
  }) async {
    print('  🎯 Scheduling goal reminders...');

    int notifId = ID_GOAL_BASED;

    if (goals.contains('save_money') || goals.contains('reduce_spending')) {
      final message = NotificationSelector.getMessage(
        category: 'goal',
        subcategory: 'financial_goals',
        variables: {
          'amount': '500',
          'percentage': '20',
          'days': '10',
          'remaining': '2000',
        },
      );

      await _scheduleWeekly(
        id: notifId++,
        title: '💰 Financial update',
        body: message,
        dayOfWeek: DateTime.monday,
        time: const TimeOfDay(hour: 9, minute: 0),
      );
    }

    if (goals.contains('improve_health') || goals.contains('better_sleep')) {
      final message = NotificationSelector.getMessage(
        category: 'goal',
        subcategory: 'health_goals',
        variables: {'days': '7', 'substance': 'cannabis', 'percentage': '15'},
      );

      await _scheduleWeekly(
        id: notifId++,
        title: '💪 Health progress',
        body: message,
        dayOfWeek: DateTime.friday,
        time: const TimeOfDay(hour: 18, minute: 0),
      );
    }

    if (goals.contains('improve_relationships')) {
      final message = NotificationSelector.getMessage(
        category: 'goal',
        subcategory: 'relationship_goals',
        variables: {'contact_name': 'your loved ones', 'count': '3'},
      );

      await _scheduleWeekly(
        id: notifId++,
        title: '💚 Connection check',
        body: message,
        dayOfWeek: DateTime.wednesday,
        time: const TimeOfDay(hour: 19, minute: 0),
      );
    }
  }

  /// Schedule time-based check-ins
  Future<void> _scheduleTimeBasedCheckins({
    Map<String, dynamic>? patterns,
    required String userName,
  }) async {
    print('  🕐 Scheduling time-based check-ins...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    int notifId = ID_TIME_BASED;

    if (!times.contains('morning')) {
      final message = NotificationSelector.getMessage(
        category: 'time',
        subcategory: 'morning',
      );

      await _scheduleDaily(
        id: notifId++,
        title: '☀️ Good morning',
        body: message,
        time: const TimeOfDay(hour: 9, minute: 0),
      );
    }

    if (times.contains('evening') || times.contains('night')) {
      final message = NotificationSelector.getMessage(
        category: 'time',
        subcategory: 'evening',
      );

      await _scheduleDaily(
        id: notifId++,
        title: '🌙 Evening check-in',
        body: message,
        time: const TimeOfDay(hour: 19, minute: 0),
      );
    }
  }

  /// Send positive reinforcement after logging (CONNECTED TO YOUR LOG SAVING)
  /// Send positive reinforcement after logging (CONNECTED TO YOUR LOG SAVING)
  Future<void> sendPositiveReinforcement({
    required String userId,
    required String entryType, // 'mindful', 'reduced', 'used'
    int? streakDays,
  }) async {
    print('  🎉 Sending positive reinforcement for: $entryType');

    try {
      // Check permissions
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        print('  ⚠️ Notifications are disabled - requesting permission...');
        final granted = await AwesomeNotifications()
            .requestPermissionToSendNotifications();
        if (!granted) {
          print('  ❌ User denied notification permission');
          return;
        }
      }

      String subcategory;
      String emoji;

      switch (entryType) {
        case 'mindful':
          subcategory = 'mindful_day';
          emoji = '🌿';
          break;
        case 'reduced':
          subcategory = 'reduced_usage';
          emoji = '💪';
          break;
        case 'used':
          subcategory = 'used_day';
          emoji = '📝';
          break;
        default:
          print('  ⚠️ Unknown entry type: $entryType');
          return;
      }

      print('  Step A: Getting message for $subcategory...');
      final message = NotificationSelector.getMessage(
        category: 'positive',
        subcategory: subcategory,
      );

      print('  Step B: Creating notification...');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: ID_POSITIVE + DateTime.now().millisecondsSinceEpoch % 1000,
          channelKey: 'safety_channel',
          title: '$emoji Entry logged',
          body: message,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
        ),
      );

      print('  Step C: Checking for milestone...');
      // ✅ FIX: Only celebrate milestone if streak > 0 AND it's a milestone number
      if (streakDays != null && streakDays > 0 && _isMilestone(streakDays)) {
        print('  Step D: Celebrating milestone (streak: $streakDays)...');
        final streakMessage = NotificationSelector.getMessage(
          category: 'positive',
          subcategory: 'streak_milestone',
          variables: {'days': streakDays.toString()},
        );

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: ID_POSITIVE + 1 + DateTime.now().millisecondsSinceEpoch % 1000,
            channelKey: 'safety_channel',
            title: '🔥 Milestone reached!',
            body: streakMessage,
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Status,
          ),
        );

        print('  Step E: Saving milestone to DB...');
        // Save milestone to database
        await _db.saveMilestone(
          userId: userId,
          milestoneType: 'streak_days',
          milestoneValue: streakDays,
        );
      } else {
        print('  ⏭️ No milestone (streak: $streakDays)');
      }

      print('  ✅ Positive reinforcement complete');
    } catch (e, stackTrace) {
      print('  ❌ Error in sendPositiveReinforcement: $e');
      print('  Stack trace: $stackTrace');
    }
  }

  /// Send weekly report notification (CONNECTED TO YOUR STATS)
  Future<void> sendWeeklyReport({required String userId}) async {
    print('📊 Generating weekly report notification...');

    try {
      // Fetch actual stats from database
      final endDate = DateTime.now();
      final thisWeekStart = _getWeekStart(endDate);
      final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

      final thisWeekLogs = await _db.getLogsForRange(
        userId,
        thisWeekStart,
        endDate,
      );
      final lastWeekLogs = await _db.getLogsForRange(
        userId,
        lastWeekStart,
        thisWeekStart,
      );

      // Count mindful days
      final thisWeekMindful = thisWeekLogs.where((log) {
        final dayType = log['day_type'] as String?;
        final substances = log['substances_used'] as List?;
        return dayType == 'mindful' || (substances?.isEmpty ?? false);
      }).length;

      final lastWeekMindful = lastWeekLogs.where((log) {
        final dayType = log['day_type'] as String?;
        final substances = log['substances_used'] as List?;
        return dayType == 'mindful' || (substances?.isEmpty ?? false);
      }).length;

      final change = thisWeekMindful - lastWeekMindful;
      final direction = change >= 0 ? 'improved' : 'decreased';

      final message = NotificationSelector.getMessage(
        category: 'data',
        subcategory: 'frequency_change',
        variables: {
          'percentage': change.abs().toString(),
          'count': change.abs().toString(),
          'direction': direction,
        },
      );

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 9000,
          channelKey: 'safety_channel',
          title: '📊 Your weekly summary',
          body: message,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Status,
          payload: {'type': 'weekly_report'},
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'view_report',
            label: 'View full report',
          ),
        ],
      );
    } catch (e) {
      print('❌ Error sending weekly report: $e');
    }
  }

  /// Celebrate milestone (CONNECTED TO YOUR STATS PROVIDERS)
  Future<void> celebrateMilestone({
    required String userId,
    required String milestoneType,
    required Map<String, dynamic> data,
  }) async {
    print('🎉 Celebrating milestone: $milestoneType');

    final message = NotificationSelector.getMessage(
      category: 'celebration',
      subcategory: milestoneType,
      variables: data,
    );

    String emoji;
    switch (milestoneType) {
      case 'first_week':
        emoji = '🎉';
        break;
      case 'first_month':
        emoji = '🎊';
        break;
      case 'cost_savings':
        emoji = '💰';
        break;
      case 'reduction_success':
        emoji = '⭐';
        break;
      default:
        emoji = '🌟';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 9100 + DateTime.now().millisecondsSinceEpoch % 100,
        channelKey: 'safety_channel',
        title: '$emoji Milestone reached!',
        body: message,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Status,
      ),
      actionButtons: [
        NotificationActionButton(key: 'view', label: 'View progress'),
      ],
    );

    // Save to database
    await _db.saveMilestone(
      userId: userId,
      milestoneType: milestoneType,
      milestoneValue: data['days'] ?? data['amount'],
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  TimeOfDay _getTargetTime(
    List<String> times, {
    int hoursBefore = 0,
    int minutesBefore = 0,
  }) {
    const timeMap = {
      'morning': TimeOfDay(hour: 10, minute: 0),
      'afternoon': TimeOfDay(hour: 15, minute: 0),
      'evening': TimeOfDay(hour: 20, minute: 0),
      'night': TimeOfDay(hour: 22, minute: 0),
    };

    final primaryTime = times.isNotEmpty ? times.first : 'evening';
    TimeOfDay baseTime =
        timeMap[primaryTime] ?? const TimeOfDay(hour: 20, minute: 0);

    int targetHour = baseTime.hour - hoursBefore;
    int targetMinute = baseTime.minute - minutesBefore;

    if (targetMinute < 0) {
      targetHour -= 1;
      targetMinute += 60;
    }

    if (targetHour < 0) targetHour = 0;
    if (targetHour > 23) targetHour = 23;

    return TimeOfDay(hour: targetHour, minute: targetMinute);
  }

  String _formatHour(int hour) {
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
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

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    List<NotificationActionButton>? actionButtons,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'safety_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      actionButtons: actionButtons,
      schedule: NotificationCalendar(
        hour: time.hour,
        minute: time.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required TimeOfDay time,
    List<NotificationActionButton>? actionButtons,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'safety_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      actionButtons: actionButtons,
      schedule: NotificationCalendar(
        weekday: dayOfWeek,
        hour: time.hour,
        minute: time.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  /// Convert Supabase map to OnboardingData model
  OnboardingData _mapToOnboardingData(Map<String, dynamic> map) {
    return OnboardingData(
      selectedGoals:
          (map['selected_goals'] as List?)?.cast<String>().toSet() ?? {},
      selectedTimeline: map['selected_timeline'] as String?,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      motivationLevel: map['motivation_level'] as int? ?? 5,
      primaryReason: map['primary_reason'] as String?,
      selectedReasons: (map['selected_reasons'] as List?)
          ?.cast<String>()
          .toSet(),
      selectedSubstances:
          (map['selected_substances'] as List?)?.cast<String>().toSet() ?? {},
      substanceDurations: Map<String, String>.from(
        map['substance_durations'] as Map? ?? {},
      ),
      substanceAttempts: map['substance_attempts'] != null
          ? Map<String, String>.from(map['substance_attempts'])
          : {},
      usagePatterns: map['usage_patterns'] as Map<String, dynamic>?,
      emergencyContacts:
          (map['emergency_contacts'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map((e) => Map<String, String>.from(e))
              .toList() ??
          [],
      supportSystem: map['support_system'] as String?,
      withdrawalConcern: map['withdrawal_concern'] as String?,
      usageContext: map['usage_context'] as String?,
      crisisResourcesEnabled: map['crisis_resources_enabled'] as bool? ?? true,
      harmReductionInfo: map['harm_reduction_info'] as bool? ?? false,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAllSchedules();
    print('🔕 All notifications cancelled');
  }
}
