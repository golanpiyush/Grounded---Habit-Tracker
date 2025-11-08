// lib/services/auto_log_service.dart

import 'package:Grounded/providers/userDB.dart';

class AutoLogService {
  final UserDatabaseService _userDb = UserDatabaseService();

  /// Check and auto-log missing days for users who have it enabled
  Future<void> checkAndAutoLog() async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        print('⚠️ No user logged in, skipping auto-log check');
        return;
      }

      print('🤖 Checking auto-log for user: $userId');

      // Get user preferences
      final onboardingData = await _userDb.getOnboardingData(userId);
      final autoLogEnabled =
          onboardingData?['auto_log_enabled'] as bool? ?? false;

      if (!autoLogEnabled) {
        print('⚠️ Auto-log disabled for this user');
        return;
      }

      print('✅ Auto-log enabled, checking for missing days...');

      // Check yesterday (we don't auto-log today since user might still log it)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStart = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );

      // Check if user logged anything yesterday
      final existingLog = await _userDb.getDailyLog(userId, yesterdayStart);

      if (existingLog == null) {
        print('📝 No log found for ${yesterdayStart.toString().split(' ')[0]}');
        print('🤖 Auto-logging as "used"...');

        // Auto-log as "used" day with a note
        await _userDb.saveDailyLog(
          userId: userId,
          logDate: yesterdayStart,
          dayType: 'used',
          notes: 'Auto-logged (no manual entry)',
        );

        print('✅ Auto-logged successfully');
      } else {
        print(
          '✓ User already logged for ${yesterdayStart.toString().split(' ')[0]}',
        );
      }
    } catch (e) {
      print('❌ Error in auto-log check: $e');
    }
  }

  /// Backfill missing days (optional - run when user enables auto-log)
  /// This will fill in all missing days from the last 7 days
  Future<void> backfillMissingDays({int daysToCheck = 7}) async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) return;

      print('🔄 Backfilling missing days (last $daysToCheck days)...');

      final now = DateTime.now();
      int autoLoggedCount = 0;

      for (int i = 1; i <= daysToCheck; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final normalizedDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        );

        // Check if log exists
        final existingLog = await _userDb.getDailyLog(userId, normalizedDate);

        if (existingLog == null) {
          print('📝 Backfilling ${normalizedDate.toString().split(' ')[0]}');

          await _userDb.saveDailyLog(
            userId: userId,
            logDate: normalizedDate,
            dayType: 'used',
            notes: 'Auto-logged (backfill)',
          );

          autoLoggedCount++;
        }
      }

      print('✅ Backfill complete: $autoLoggedCount days auto-logged');
    } catch (e) {
      print('❌ Error backfilling days: $e');
    }
  }
}
