// lib/services/user_db.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/onboarding_data.dart';

class UserDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      print('🔐 Signing up user: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        print('✅ Sign up successful: ${response.user!.id}');

        // Create user profile
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );
      }

      return response;
    } catch (e) {
      print('❌ Sign up error: $e');
      rethrow;
    }
  }

  /// Log in existing user
  Future<AuthResponse> logIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Logging in user: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Login successful: ${response.user!.id}');
        await _updateLastLogin(response.user!.id);
      }

      return response;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Log out current user
  Future<void> logOut() async {
    try {
      print('🔐 Logging out user');
      await _supabase.auth.signOut();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Password reset error: $e');
      rethrow;
    }
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    try {
      print('👤 Creating user profile for: $userId');

      // Method 1: Try direct insert first (remove the unused response variable)
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ User profile created');
    } catch (e) {
      print('❌ Error creating user profile: $e');

      // Method 2: Try using the database function (if you created it)
      try {
        await _supabase.rpc(
          'create_user_profile',
          params: {
            'user_id': userId,
            'user_email': email,
            'user_full_name': fullName,
          },
        );
        print('✅ User profile created via function');
      } catch (e2) {
        print('❌ Error creating user profile via function: $e2');

        // Method 3: Last resort - use upsert
        try {
          await _supabase.from('users').upsert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('✅ User profile created via upsert');
        } catch (e3) {
          print('❌ All methods failed: $e3');
          rethrow;
        }
      }
    }
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      print('⚠️ Error updating last login: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('👤 Fetching user profile: $userId');

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      print('✅ User profile fetched');
      return response;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? profileImageUrl,
    String? timezone,
  }) async {
    try {
      print('👤 Updating user profile: $userId');

      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (profileImageUrl != null)
        updates['profile_image_url'] = profileImageUrl;
      if (timezone != null) updates['timezone'] = timezone;

      await _supabase.from('users').update(updates).eq('id', userId);

      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ============================================
  // ONBOARDING DATA
  // ============================================

  /// Save complete onboarding data
  Future<void> saveOnboardingData({
    required String userId,
    required OnboardingData onboardingData,
  }) async {
    try {
      print('\n=== SAVING ONBOARDING DATA TO SUPABASE ===');
      print('User ID: $userId');

      // Save onboarding main data
      await _saveOnboardingMain(userId, onboardingData);

      // Mark onboarding as complete
      await _supabase
          .from('users')
          .update({
            'onboarding_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('✅ ALL ONBOARDING DATA SAVED SUCCESSFULLY');
      print('==========================================\n');
    } catch (e) {
      print('❌ Error saving onboarding data: $e');
      rethrow;
    }
  }

  /// Save main onboarding data
  /// Save main onboarding data
  Future<void> _saveOnboardingMain(String userId, OnboardingData data) async {
    print('💾 Saving main onboarding data...');

    final onboardingMap = {
      'user_id': userId,

      // Goals & Motivation
      'selected_goals': data.selectedGoals.toList(),
      'selected_timeline': data.selectedTimeline,
      'target_date': data.targetDate?.toIso8601String(),
      'motivation_level': data.motivationLevel,
      'primary_reason': data.primaryReason,
      'selected_reasons': data.selectedReasons?.toList(),

      // Substances
      'selected_substances': data.selectedSubstances.toList(),
      'previous_attempts': data.previousAttempts,
      'substance_durations': data.substanceDurations,

      // Usage Patterns (stored as JSONB)
      'usage_patterns': data.usagePatterns,

      // Safety
      'support_system': data.supportSystem,
      'emergency_contacts': data.emergencyContacts,
      'withdrawal_concern': data.withdrawalConcern,
      'usage_context': data.usageContext,
      'crisis_resources_enabled': data.crisisResourcesEnabled,
      'harm_reduction_info': data.harmReductionInfo,

      // Timestamps
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('user_onboarding').upsert(onboardingMap);
    print('  ✓ Main onboarding data saved');
  }

  /// Save individual substance pattern
  Future<void> saveSubstancePattern({
    required String userId,
    required String substanceName,
    String? frequency,
    String? context,
    List<String>? consumptionMethods,
    Map<String, String>? typicalAmounts,
    String? costPerUse,
    String? currency,
    List<String>? triggers,
    List<String>? impacts,
    String? timeOfDay,
  }) async {
    try {
      print('💊 Saving pattern for: $substanceName');

      final patternMap = {
        'user_id': userId,
        'substance_name': substanceName,
        'frequency': frequency,
        'context': context,
        'consumption_methods': consumptionMethods,
        'typical_amounts': typicalAmounts,
        'cost_per_use': costPerUse != null && costPerUse.isNotEmpty
            ? double.tryParse(costPerUse)
            : null,
        'currency': currency ?? '\$',
        'triggers': triggers,
        'impacts': impacts,
        'time_of_day': timeOfDay,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('substance_patterns').upsert(patternMap);
      print('  ✓ Pattern saved for $substanceName');
    } catch (e) {
      print('❌ Error saving substance pattern: $e');
      rethrow;
    }
  }

  /// Get user onboarding data
  Future<Map<String, dynamic>?> getOnboardingData(String userId) async {
    try {
      print('📥 Fetching onboarding data for: $userId');

      final response = await _supabase
          .from('user_onboarding')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        print('✅ Onboarding data fetched');
      } else {
        print('⚠️ No onboarding data found');
      }

      return response;
    } catch (e) {
      print('❌ Error fetching onboarding data: $e');
      return null;
    }
  }

  /// Get substance patterns
  Future<List<Map<String, dynamic>>> getSubstancePatterns(String userId) async {
    try {
      print('📥 Fetching substance patterns for: $userId');

      final response = await _supabase
          .from('substance_patterns')
          .select()
          .eq('user_id', userId);

      print('✅ Substance patterns fetched: ${response.length} substances');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching substance patterns: $e');
      return [];
    }
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('onboarding_completed')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return false;

      return response['onboarding_completed'] as bool? ?? false;
    } catch (e) {
      print('⚠️ Error checking onboarding status: $e');
      return false;
    }
  }

  // ============================================
  // DAILY LOGS
  // ============================================

  /// Save daily log
  Future<void> saveDailyLog({
    required String userId,
    required DateTime logDate,
    List<String>? substancesUsed,
    Map<String, dynamic>? amountsUsed,
    double? costSpent,
    int? moodRating,
    List<String>? emotions,
    List<String>? triggersExperienced,
    String? notes,
  }) async {
    try {
      print('📝 Saving daily log for: ${logDate.toString().split(' ')[0]}');

      final logMap = {
        'user_id': userId,
        'timestamp': logDate.toIso8601String(), // ✅ Changed to 'timestamp'
        'day_type':
            'mindful', // ✅ Add required field (determine based on substances)
        'substances_used': substancesUsed,
        'amounts_used': amountsUsed,
        'cost_spent': costSpent,
        'mood_rating': moodRating,
        'emotions': emotions,
        'triggers_experienced': triggersExperienced,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('daily_logs').upsert(logMap);
      print('✅ Daily log saved');
    } catch (e) {
      print('❌ Error saving daily log: $e');
      rethrow;
    }
  }

  /// Get daily log
  Future<Map<String, dynamic>?> getDailyLog(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .gte('timestamp', startOfDay.toIso8601String())
          .lt('timestamp', endOfDay.toIso8601String())
          .order('timestamp', ascending: false)
          .limit(1) // ✅ Add this
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error fetching daily log: $e');
      return null;
    }
  }

  /// Get logs for date range
  Future<List<Map<String, dynamic>>> getLogsForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print(
        '📥 Fetching logs from ${startDate.toString().split(' ')[0]} to ${endDate.toString().split(' ')[0]}',
      );

      final response = await _supabase
          .from('daily_logs')
          .select()
          .eq('user_id', userId)
          .gte('timestamp', startDate.toIso8601String())
          .lte(
            'timestamp',
            endDate.add(const Duration(days: 1)).toIso8601String(),
          )
          .order('timestamp', ascending: false);

      print('✅ Fetched ${response.length} logs');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching logs: $e');
      return [];
    }
  }

  /// Delete daily log
  Future<void> deleteDailyLog(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      await _supabase
          .from('daily_logs')
          .delete()
          .eq('user_id', userId)
          .gte('timestamp', startOfDay.toIso8601String())
          .lt('timestamp', endOfDay.toIso8601String());

      print('✅ Daily log deleted');
    } catch (e) {
      print('❌ Error deleting daily log: $e');
      rethrow;
    }
  }

  // Add these methods to your UserDatabaseService class

  // ============================================
  // UPDATE METHODS FOR SETTINGS
  // ============================================

  /// Update user substances
  Future<void> updateSubstances({
    required String userId,
    required List<String> substances,
  }) async {
    try {
      print('💊 Updating substances for user: $userId');
      print('  Selected substances: $substances');

      await _supabase
          .from('user_onboarding')
          .update({
            'selected_substances': substances,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Substances updated successfully');
    } catch (e) {
      print('❌ Error updating substances: $e');
      rethrow;
    }
  }

  /// Update user goals
  Future<void> updateGoals({
    required String userId,
    required List<String> goals,
  }) async {
    try {
      print('🎯 Updating goals for user: $userId');
      print('  Selected goals: $goals');

      await _supabase
          .from('user_onboarding')
          .update({
            'selected_goals': goals,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Goals updated successfully');
    } catch (e) {
      print('❌ Error updating goals: $e');
      rethrow;
    }
  }

  /// Update target date
  Future<void> updateTargetDate({
    required String userId,
    required String timeline,
    required DateTime targetDate,
  }) async {
    try {
      print('📅 Updating target date for user: $userId');
      print('  Timeline: $timeline');
      print('  Target date: ${targetDate.toString().split(' ')[0]}');

      await _supabase
          .from('user_onboarding')
          .update({
            'selected_timeline': timeline,
            'target_date': targetDate.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Target date updated successfully');
    } catch (e) {
      print('❌ Error updating target date: $e');
      rethrow;
    }
  }

  // ============================================
  // ANALYTICS & INSIGHTS
  // ============================================

  /// Get sobriety streak for a substance
  Future<int> getSobrietyStreak(String userId, String substance) async {
    try {
      print('📊 Calculating sobriety streak for: $substance');

      final response = await _supabase.rpc(
        'get_sobriety_streak',
        params: {'p_user_id': userId, 'p_substance': substance},
      );

      final streak = response as int? ?? 0;
      print('✅ Sobriety streak: $streak days');
      return streak;
    } catch (e) {
      print('❌ Error calculating sobriety streak: $e');
      return 0;
    }
  }

  /// Calculate money saved
  Future<double> calculateMoneySaved(
    String userId, {
    String? substance,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('💰 Calculating money saved...');

      final params = {
        'p_user_id': userId,
        'p_substance': substance,
        'p_start_date': startDate?.toIso8601String().split('T')[0],
        'p_end_date':
            endDate?.toIso8601String().split('T')[0] ??
            DateTime.now().toIso8601String().split('T')[0],
      };

      final response = await _supabase.rpc(
        'calculate_money_saved',
        params: params,
      );

      final saved = (response as num?)?.toDouble() ?? 0.0;
      print('✅ Money saved: \$$saved');
      return saved;
    } catch (e) {
      print('❌ Error calculating money saved: $e');
      return 0.0;
    }
  }

  /// Get user insights
  Future<Map<String, dynamic>?> getUserInsights(String userId) async {
    try {
      print('📊 Fetching user insights...');

      final response = await _supabase.rpc(
        'get_user_insights',
        params: {'p_user_id': userId},
      );

      if (response != null && response is List && response.isNotEmpty) {
        final insights = response[0] as Map<String, dynamic>;
        print('✅ Insights fetched');
        print('  - Total substances: ${insights['total_substances']}');
        print('  - Motivation: ${insights['avg_motivation']}');
        print('  - Check-ins: ${insights['total_check_ins']}');
        print('  - Longest streak: ${insights['current_longest_streak']} days');
        print('  - Money saved: \$${insights['total_money_saved']}');
        return insights;
      }

      return null;
    } catch (e) {
      print('❌ Error fetching insights: $e');
      return null;
    }
  }

  /// Get weekly progress
  Future<List<Map<String, dynamic>>> getWeeklyProgress(
    String userId, {
    DateTime? weekStart,
  }) async {
    try {
      print('📊 Fetching weekly progress...');

      final start =
          weekStart ?? DateTime.now().subtract(const Duration(days: 7));

      final response = await _supabase.rpc(
        'get_weekly_progress',
        params: {
          'p_user_id': userId,
          'p_week_start': start.toIso8601String().split('T')[0],
        },
      );

      final progress = List<Map<String, dynamic>>.from(response);
      print('✅ Weekly progress fetched: ${progress.length} days');
      return progress;
    } catch (e) {
      print('❌ Error fetching weekly progress: $e');
      return [];
    }
  }

  /// Get trigger analysis
  Future<List<Map<String, dynamic>>> getTriggerAnalysis(
    String userId, {
    int days = 30,
  }) async {
    try {
      print('📊 Fetching trigger analysis for last $days days...');

      final response = await _supabase.rpc(
        'get_trigger_analysis',
        params: {'p_user_id': userId, 'p_days': days},
      );

      final analysis = List<Map<String, dynamic>>.from(response);
      print('✅ Trigger analysis fetched: ${analysis.length} triggers');

      for (final trigger in analysis) {
        print(
          '  - ${trigger['trigger_name']}: ${trigger['occurrence_count']} times (${trigger['percentage']}%)',
        );
      }

      return analysis;
    } catch (e) {
      print('❌ Error fetching trigger analysis: $e');
      return [];
    }
  }

  // ============================================
  // MILESTONES
  // ============================================

  /// Save milestone
  Future<void> saveMilestone({
    required String userId,
    required String milestoneType,
    int? milestoneValue,
    String? substanceName,
  }) async {
    try {
      print('🏆 Saving milestone: $milestoneType');

      await _supabase.from('milestones').insert({
        'user_id': userId,
        'milestone_type': milestoneType,
        'milestone_value': milestoneValue,
        'substance_name': substanceName,
        'achieved_at': DateTime.now().toIso8601String(),
      });

      print('✅ Milestone saved');
    } catch (e) {
      print('❌ Error saving milestone: $e');
      rethrow;
    }
  }

  /// Get user milestones
  Future<List<Map<String, dynamic>>> getMilestones(
    String userId, {
    int limit = 50,
  }) async {
    try {
      print('🏆 Fetching milestones...');

      final response = await _supabase
          .from('milestones')
          .select()
          .eq('user_id', userId)
          .order('achieved_at', ascending: false)
          .limit(limit);

      print('✅ Fetched ${response.length} milestones');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching milestones: $e');
      return [];
    }
  }

  /// Mark milestone as celebrated
  Future<void> celebrateMilestone(String milestoneId) async {
    try {
      await _supabase
          .from('milestones')
          .update({'is_celebrated': true})
          .eq('id', milestoneId);

      print('🎉 Milestone celebrated!');
    } catch (e) {
      print('❌ Error celebrating milestone: $e');
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Delete user account and all data
  Future<void> deleteUserAccount(String userId) async {
    try {
      print('🗑️ Deleting user account: $userId');

      // Delete from users table (RLS policies will handle cascades)
      await _supabase.from('users').delete().eq('id', userId);

      print('✅ User account deleted');
    } catch (e) {
      print('❌ Error deleting user account: $e');
      rethrow;
    }
  }

  /// Export user data (for GDPR compliance)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      print('📦 Exporting user data...');

      final userData = await getUserProfile(userId);
      final onboardingData = await getOnboardingData(userId);
      final substancePatterns = await getSubstancePatterns(userId);
      final logs = await getLogsForRange(
        userId,
        DateTime.now().subtract(const Duration(days: 365)),
        DateTime.now(),
      );
      final milestones = await getMilestones(userId);

      final exportData = {
        'user_profile': userData,
        'onboarding': onboardingData,
        'substance_patterns': substancePatterns,
        'daily_logs': logs,
        'milestones': milestones,
        'exported_at': DateTime.now().toIso8601String(),
      };

      print('✅ User data exported');
      return exportData;
    } catch (e) {
      print('❌ Error exporting user data: $e');
      rethrow;
    }
  }

  /// Update app preferences
  Future<void> updateAppPreferences({
    required String userId,
    String? appTheme,
    bool? dailyReminders,
    String? reminderTime,
    bool? analyticsEnabled,
    bool? motivationalMessages,
    String? dataSharing,
  }) async {
    try {
      print('⚙️ Updating app preferences...');

      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (appTheme != null) updates['app_theme'] = appTheme;
      if (dailyReminders != null) updates['daily_reminders'] = dailyReminders;
      if (reminderTime != null) updates['reminder_time'] = reminderTime;
      if (analyticsEnabled != null)
        updates['analytics_enabled'] = analyticsEnabled;
      if (motivationalMessages != null) {
        updates['motivational_messages'] = motivationalMessages;
      }
      if (dataSharing != null) updates['data_sharing'] = dataSharing;

      await _supabase
          .from('user_onboarding')
          .update(updates)
          .eq('user_id', userId);

      print('✅ App preferences updated');
    } catch (e) {
      print('❌ Error updating app preferences: $e');
      rethrow;
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS (Optional)
  // ============================================

  /// Subscribe to user profile changes
  RealtimeChannel subscribeToProfile(
    String userId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    print('🔔 Subscribing to profile updates...');

    return _supabase
        .channel('profile-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            print('🔔 Profile updated');
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
    print('🔕 Unsubscribed from channel');
  }
}
