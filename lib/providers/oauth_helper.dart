// helpers/oauth_helper.dart
// Helper functions for OAuth sign in flow

import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthHelper {
  static final _supabase = Supabase.instance.client;

  /// Checks if a user has existing data in the database
  /// Returns true if user has data (existing user), false if new user
  static Future<bool> checkUserHasData(String userId) async {
    try {
      // Check if user has any data in your main tables
      // Adjust table names and queries based on your database schema

      // Example: Check if user has profile data
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (profileData != null) {
        return true; // User has profile data
      }

      // Example: Check if user has any habits/goals
      final habitsData = await _supabase
          .from('habits')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (habitsData.isNotEmpty) {
        return true; // User has habits
      }

      // Example: Check if user has substance goals
      final goalsData = await _supabase
          .from('substance_goals')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (goalsData.isNotEmpty) {
        return true; // User has goals
      }

      // No data found, this is a new user
      return false;
    } catch (e) {
      print('Error checking user data: $e');
      // On error, assume new user to be safe (show welcome screen)
      return false;
    }
  }

  /// Signs in with Apple and determines if user is new or existing
  static Future<OAuthResult> signInWithApple() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'your-app-scheme://callback', // Configure your deep link
      );

      // Note: OAuth flow redirects to browser, you'll need to handle the callback
      // The actual user data will be available after redirect
      return OAuthResult(
        success: true,
        isNewUser: null, // Will be determined after callback
      );
    } catch (e) {
      print('Apple sign in error: $e');
      return OAuthResult(success: false, error: e.toString());
    }
  }

  /// Signs in with Google and determines if user is new or existing
  static Future<OAuthResult> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'your-app-scheme://callback', // Configure your deep link
      );

      // Note: OAuth flow redirects to browser, you'll need to handle the callback
      // The actual user data will be available after redirect
      return OAuthResult(
        success: true,
        isNewUser: null, // Will be determined after callback
      );
    } catch (e) {
      print('Google sign in error: $e');
      return OAuthResult(success: false, error: e.toString());
    }
  }

  /// Handle OAuth callback after redirect
  /// Call this when app receives the OAuth callback
  static Future<UserNavigationTarget> handleOAuthCallback() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session == null || user == null) {
        return UserNavigationTarget.authChoice;
      }

      // Check if user has existing data
      final hasData = await checkUserHasData(user.id);

      if (hasData) {
        return UserNavigationTarget.dashboard;
      } else {
        return UserNavigationTarget.welcome;
      }
    } catch (e) {
      print('Error handling OAuth callback: $e');
      return UserNavigationTarget.authChoice;
    }
  }
}

/// Result of OAuth sign in attempt
class OAuthResult {
  final bool success;
  final bool? isNewUser;
  final String? error;

  OAuthResult({required this.success, this.isNewUser, this.error});
}

/// Target screen after OAuth authentication
enum UserNavigationTarget {
  welcome, // New user - show welcome/setup screens
  dashboard, // Existing user - go to dashboard
  authChoice, // Error or not authenticated - go to auth choice
}
