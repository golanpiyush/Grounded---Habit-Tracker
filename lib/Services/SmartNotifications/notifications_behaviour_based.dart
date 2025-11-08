import 'package:Grounded/Services/SmartNotifications/notificationsTemplate.dart';
import 'package:Grounded/Services/SmartNotifications/notifications_context_based.dart';
import 'package:Grounded/models/onboarding_data.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Behavioral notification engine that uses onboarding data
/// to schedule personalized, contextual notifications
class BehavioralNotificationEngine {
  static final BehavioralNotificationEngine _instance =
      BehavioralNotificationEngine._internal();
  factory BehavioralNotificationEngine() => _instance;
  BehavioralNotificationEngine._internal();

  // Notification IDs (start from different ranges to avoid conflicts)
  static const int ID_EMOTIONAL = 1000;
  static const int ID_PREDICTIVE = 2000;
  static const int ID_SUPPORTIVE = 3000;
  static const int ID_REFLECTIVE = 4000;
  static const int ID_GOAL_BASED = 5000;
  static const int ID_POSITIVE = 6000;
  static const int ID_TIME_BASED = 7000;

  /// Main initialization from onboarding data
  Future<void> initializeFromOnboarding(OnboardingData data) async {
    print('🧠 Initializing behavioral notifications from onboarding...');

    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'friend';

    // Cancel all existing scheduled notifications
    await AwesomeNotifications().cancelAllSchedules();

    // Parse usage patterns
    final patterns = data.usagePatterns;
    final reasons = data.selectedReasons?.toList() ?? [];
    final primaryReason = data.primaryReason;
    final goals = data.selectedGoals.toList();
    final timeline = data.selectedTimeline;

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
      patterns: patterns,
      reasons: reasons,
      userName: userName,
    );

    // 4. Schedule supportive prompts (Layer 6)
    await _scheduleSupportivePrompts(
      reasons: reasons,
      patterns: patterns,
      emergencyContacts: data.emergencyContacts,
      userName: userName,
    );

    // 5. Schedule goal-based reminders
    await _scheduleGoalReminders(
      goals: goals,
      timeline: timeline,
      targetDate: data.targetDate,
      userName: userName,
    );

    // 6. Schedule time-based check-ins
    await _scheduleTimeBasedCheckins(patterns: patterns, userName: userName);

    // 7. Schedule weekly reflections (Layer 7)
    await _scheduleWeeklyReflections(userName: userName);

    print('✅ Behavioral notifications initialized successfully');
  }

  /// LAYER 3: Emotional Support Notifications
  Future<void> _scheduleEmotionalSupport({
    required List<String> reasons,
    String? primaryReason,
    Map<String, dynamic>? patterns,
    required String userName,
  }) async {
    print('  💚 Scheduling emotional support...');

    // Get typical time of day
    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];

    // Map reasons to emotional messages
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
          'score': '3', // Will be dynamic with real data
          'percentage': '70',
          'count': '5',
        },
      );

      // Schedule 1 hour before typical use time
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

    // Map reasons to interpretations
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

        // Schedule 2 hours before typical use
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

  /// LAYER 5: Predictive Alerts
  /// LAYER 5: Predictive Alerts
  Future<void> _schedulePredictiveAlerts({
    Map<String, dynamic>? patterns,
    required List<String> reasons,
    required String userName,
  }) async {
    print('  🔮 Scheduling predictive alerts...');

    final timeList = patterns?['time_of_day'] as List<dynamic>?;
    final times = timeList?.cast<String>() ?? [];
    final frequency = patterns?['frequency'] as String?;

    int notifId = ID_PREDICTIVE;

    // Time-based prediction
    if (times.contains('evening') || times.contains('night')) {
      final message = NotificationSelector.getMessage(
        category: 'predictive',
        subcategory: 'time_based_warning',
        variables: {'time': '8-10 PM', 'day': 'weekday', 'when': 'after work'},
      );

      await _scheduleDaily(
        id: notifId++,
        title: 'Pattern alert',
        body: message,
        time: const TimeOfDay(hour: 19, minute: 0), // 7 PM
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
        time: const TimeOfDay(hour: 16, minute: 0), // 4 PM
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
        time: const TimeOfDay(hour: 18, minute: 0), // 6 PM
      );
    }

    // Frequency-based predictions (NEW - using the frequency variable)
    if (frequency != null) {
      await _scheduleFrequencyBasedAlerts(
        frequency,
        notifId++,
        reasons,
        userName,
      );
    }
  }

  /// NEW: Helper method for frequency-based alerts
  Future<void> _scheduleFrequencyBasedAlerts(
    String frequency,
    int notifId,
    List<String> reasons,
    String userName,
  ) async {
    switch (frequency) {
      case 'daily':
        // For daily users, add a morning intention-setting notification
        if (reasons.contains('habit_routine') || reasons.contains('boredom')) {
          final message = NotificationSelector.getMessage(
            category: 'predictive',
            subcategory: 'daily_habit_alert',
            variables: {'userName': userName},
          );

          await _scheduleDaily(
            id: notifId,
            title: 'Daily intention',
            body: message,
            time: const TimeOfDay(hour: 8, minute: 30),
          );
        }
        break;

      case 'weekly':
        // For weekly users, add a weekend preparation notification
        if (reasons.contains('social_situations') ||
            reasons.contains('stress_anxiety')) {
          final message = NotificationSelector.getMessage(
            category: 'predictive',
            subcategory: 'weekly_prep',
            variables: {'frequency': 'weekly', 'userName': userName},
          );

          await _scheduleWeekly(
            id: notifId,
            title: 'Weekend prep',
            body: message,
            dayOfWeek: DateTime.friday,
            time: const TimeOfDay(hour: 17, minute: 0),
          );
        }
        break;

      case 'monthly':
        // For monthly users, add end-of-month reflection
        final message = NotificationSelector.getMessage(
          category: 'predictive',
          subcategory: 'monthly_reflection',
          variables: {'frequency': 'monthly', 'userName': userName},
        );

        // Schedule for the 25th of each month
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notifId,
            channelKey: 'safety_channel',
            title: 'Monthly check-in',
            body: message,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
          ),
          schedule: NotificationCalendar(
            day: 25,
            hour: 10,
            minute: 0,
            second: 0,
            repeats: true,
          ),
        );
        break;

      case 'occasional':
        // For occasional users, add context-based reminders
        if (reasons.contains('stress_anxiety')) {
          final message = NotificationSelector.getMessage(
            category: 'predictive',
            subcategory: 'stress_reminder',
            variables: {'frequency': 'occasional', 'userName': userName},
          );

          await _scheduleWeekly(
            id: notifId,
            title: 'Stress management',
            body: message,
            dayOfWeek: DateTime.wednesday,
            time: const TimeOfDay(hour: 15, minute: 0),
          );
        }
        break;
    }
  }

  /// LAYER 6: Supportive Prompts (Coping Tools)
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

    // Map reasons to coping strategies
    final copingMap = {
      'stress_anxiety': 'breathing_prompts',
      'boredom': 'alternative_activities',
      'emotional_pain': 'social_support',
      'habit_routine': 'mindful_pause',
    };

    for (final reason in reasons) {
      final copingKey = copingMap[reason];
      if (copingKey == null) continue;

      // Get contact name if available
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

      // Schedule 30 min before typical use time
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

    // Always add harm reduction reminder
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

    final messages = NotificationMessages.reflective['progress_monthly']!;
    final message = messages.first;

    await _scheduleWeekly(
      id: ID_REFLECTIVE,
      title: 'Weekly reflection',
      body: message,
      dayOfWeek: DateTime.sunday,
      time: const TimeOfDay(hour: 20, minute: 0), // 8 PM Sunday
      actionButtons: [
        NotificationActionButton(
          key: 'view_report',
          label: 'View weekly report',
        ),
      ],
    );
  }

  /// Schedule goal-based reminders
  Future<void> _scheduleGoalReminders({
    required List<String> goals,
    String? timeline,
    DateTime? targetDate,
    required String userName,
  }) async {
    print('  🎯 Scheduling goal reminders...');

    int notifId = ID_GOAL_BASED;

    // Financial goal
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

    // Health goal
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

    // Relationship goal
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

    // Morning check-in
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

    // Evening check-in (if high-use time)
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

  /// Schedule positive reinforcement after logging
  Future<void> sendPositiveReinforcement({
    required String entryType, // 'mindful', 'reduced', 'used'
    int? streakDays,
    Map<String, dynamic>? additionalData,
  }) async {
    print('  🎉 Sending positive reinforcement for: $entryType');

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
        return;
    }

    final message = NotificationSelector.getMessage(
      category: 'positive',
      subcategory: subcategory,
    );

    // Send immediately
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

    // If streak milestone, send additional celebration
    if (streakDays != null && _isMilestone(streakDays)) {
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
    }
  }

  /// Helper: Check if day count is a milestone
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

  /// Helper: Get target time based on typical usage patterns
  TimeOfDay _getTargetTime(
    List<String> times, {
    int hoursBefore = 0,
    int minutesBefore = 0,
  }) {
    // Default times for each period
    const timeMap = {
      'morning': TimeOfDay(hour: 10, minute: 0),
      'afternoon': TimeOfDay(hour: 15, minute: 0),
      'evening': TimeOfDay(hour: 20, minute: 0),
      'night': TimeOfDay(hour: 22, minute: 0),
    };

    // Get primary time or default to evening
    final primaryTime = times.isNotEmpty ? times.first : 'evening';
    TimeOfDay baseTime =
        timeMap[primaryTime] ?? const TimeOfDay(hour: 20, minute: 0);

    // Subtract hours/minutes
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

  /// Schedule daily notification
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

  /// Schedule weekly notification
  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // DateTime.monday, etc.
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

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAllSchedules();
    print('🔕 All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
    print('🔕 Notification $id cancelled');
  }
}
