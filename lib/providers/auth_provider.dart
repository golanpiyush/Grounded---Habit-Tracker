// auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unauthenticated, authenticated, loading }

enum AuthMethod { email, apple, google, guest }

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.loading;
  bool? _isNewUser;
  AuthMethod? _authMethod;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool? get isNewUser => _isNewUser;
  AuthMethod? get authMethod => _authMethod;

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _checkInitialAuthState();
    _setupAuthListener();
  }

  // Listen to auth state changes (important for OAuth)
  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final user = session?.user;

      if (user != null) {
        _status = AuthStatus.authenticated;
        _userId = user.id;
        _userEmail = user.email;

        // Try to determine auth method from user metadata if not already set
        if (_authMethod == null) {
          _determineAuthMethodFromUser(user);
        }

        notifyListeners();
      } else if (_authMethod != AuthMethod.guest) {
        // Don't update status if we're in guest mode
        _status = AuthStatus.unauthenticated;
        _userId = null;
        _userEmail = null;
        _authMethod = null;
        _isNewUser = null;
        notifyListeners();
      }
    });
  }

  void _determineAuthMethodFromUser(User user) {
    // Check app_metadata for OAuth providers
    final appMetadata = user.appMetadata;
    final providers = appMetadata['providers'] as List?;

    if (providers != null && providers.isNotEmpty) {
      final provider = providers.first.toString().toLowerCase();
      if (provider.contains('apple')) {
        _authMethod = AuthMethod.apple;
      } else if (provider.contains('google')) {
        _authMethod = AuthMethod.google;
      } else {
        _authMethod = AuthMethod.email;
      }
    } else {
      _authMethod = AuthMethod.email;
    }
  }

  // Check if user is already logged in when app starts
  Future<void> _checkInitialAuthState() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session != null && user != null) {
        _status = AuthStatus.authenticated;
        _userId = user.id;
        _userEmail = user.email;
        _determineAuthMethodFromUser(user);
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('Error checking auth state: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Check if current user has existing data in database
  Future<bool> checkUserHasData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check user_onboarding table for onboarding completion
      final onboardingResponse = await _supabase
          .from('user_onboarding')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return onboardingResponse != null;
    } catch (e) {
      print('Error checking user data: $e');
      // Assume new user if check fails
      return false;
    }
  }

  /// Check if current user has completed onboarding (more specific check)
  Future<bool> checkUserHasOnboardingData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      print('🔍 Checking onboarding data for user: ${user.id}');

      // Check if user_onboarding record exists
      final response = await _supabase
          .from('user_onboarding')
          .select('id, selected_goals, selected_substances')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        print('❌ No onboarding data found');
        return false;
      }

      // Verify that essential fields are filled
      final hasGoals =
          response['selected_goals'] != null &&
          (response['selected_goals'] as List).isNotEmpty;
      final hasSubstances =
          response['selected_substances'] != null &&
          (response['selected_substances'] as List).isNotEmpty;

      final hasOnboardingData = hasGoals || hasSubstances;

      print('✅ Onboarding data check: $hasOnboardingData');
      print('  - Has goals: $hasGoals');
      print('  - Has substances: $hasSubstances');

      return hasOnboardingData;
    } catch (e) {
      print('❌ Error checking onboarding data: $e');
      // Assume new user if check fails
      return false;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    print('\n🔐 signUpWithEmail called');
    print('  - Email: $email');

    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.email;
    _isNewUser = true;
    notifyListeners();

    try {
      print('  - Calling Supabase auth.signUp...');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      print('  - Response received');
      print('    - User ID: ${response.user?.id}');
      print('    - Email: ${response.user?.email}');

      if (response.user != null) {
        _status = AuthStatus.authenticated;
        _userId = response.user!.id;
        _userEmail = response.user!.email;
        print('  ✅ Sign up successful');
        print('    - Status: $_status');
        print('    - Auth method: $_authMethod');
        print('    - Is new user: $_isNewUser');
      } else {
        _error = 'Sign up failed';
        print('  ❌ Sign up failed: no user returned');
      }
    } catch (e) {
      _error = e.toString();
      print('  ❌ Sign up error: $e');
    }

    _isLoading = false;
    print('  - Calling notifyListeners()...');
    notifyListeners();
    print('  - notifyListeners() complete');
  }

  Future<void> signInWithEmail(String email, String password) async {
    print('\n🔐 signInWithEmail called');
    print('  - Email: $email');

    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.email;
    _isNewUser = false;
    notifyListeners();

    try {
      print('  - Calling Supabase auth.signInWithPassword...');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('  - Response received');
      print('    - User ID: ${response.user?.id}');
      print('    - Email: ${response.user?.email}');

      if (response.user != null) {
        _status = AuthStatus.authenticated;
        _userId = response.user!.id;
        _userEmail = response.user!.email;
        print('  ✅ Sign in successful');
        print('    - Status: $_status');
        print('    - Auth method: $_authMethod');
        print('    - Is new user: $_isNewUser');
      } else {
        _error = 'Login failed';
        print('  ❌ Login failed: no user returned');
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      print('  ❌ Sign in error: $e');
    }

    _isLoading = false;
    print('  - Calling notifyListeners()...');
    notifyListeners();
    print('  - notifyListeners() complete');
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.apple;
    notifyListeners();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo:
            'io.supabase.grounded://callback', // Update with your app scheme
      );

      // OAuth redirects to browser
      // Auth state will be updated via listener after redirect
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      _authMethod = null;
      print('Apple sign in error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.google;
    notifyListeners();

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.grounded://callback', // Update with your app scheme
      );

      // OAuth redirects to browser
      // Auth state will be updated via listener after redirect
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      _authMethod = null;
      print('Google sign in error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _authMethod = AuthMethod.guest;
    _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = null;
    _isNewUser = true;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      if (_authMethod != AuthMethod.guest) {
        await _supabase.auth.signOut();
      }
    } catch (e) {
      print('Sign out error: $e');
    }

    _status = AuthStatus.unauthenticated;
    _userId = null;
    _userEmail = null;
    _isNewUser = null;
    _authMethod = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearNewUserFlag() {
    _isNewUser = null;
    notifyListeners();
  }
}
