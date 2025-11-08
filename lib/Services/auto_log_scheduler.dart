// lib/services/auto_log_scheduler.dart

import 'package:workmanager/workmanager.dart';
import 'package:Grounded/Services/auto_log_service.dart';

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🤖 Auto-log background task started');

      final autoLogService = AutoLogService();
      await autoLogService.checkAndAutoLog();

      print('✅ Auto-log background task completed');
      return Future.value(true);
    } catch (e) {
      print('❌ Auto-log background task failed: $e');
      return Future.value(false);
    }
  });
}

class AutoLogScheduler {
  static const String AUTO_LOG_TASK = 'auto_log_daily_check';

  /// Initialize the background task scheduler
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
    print('✅ Auto-log scheduler initialized');
  }

  /// Schedule daily auto-log check (runs at 11:59 PM daily)
  static Future<void> scheduleDailyCheck() async {
    await Workmanager().registerPeriodicTask(
      AUTO_LOG_TASK,
      AUTO_LOG_TASK,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
    );
    print('✅ Daily auto-log check scheduled');
  }

  /// Cancel scheduled auto-log tasks
  static Future<void> cancelScheduledChecks() async {
    await Workmanager().cancelByUniqueName(AUTO_LOG_TASK);
    print('✅ Auto-log schedule cancelled');
  }

  /// Calculate delay until 11:59 PM today
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, 23, 59);

    if (now.isAfter(targetTime)) {
      // If it's already past 11:59 PM, schedule for tomorrow
      return targetTime.add(const Duration(days: 1)).difference(now);
    } else {
      return targetTime.difference(now);
    }
  }

  /// Manual trigger for testing
  static Future<void> triggerManualCheck() async {
    print('🔧 Manually triggering auto-log check...');
    final autoLogService = AutoLogService();
    await autoLogService.checkAndAutoLog();
  }
}
