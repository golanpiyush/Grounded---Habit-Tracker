// auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unauthenticated, authenticated, guest, loading }

enum AuthMethod { email, apple, google, guest }

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool? _isNewUser;
  AuthMethod? _authMethod;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool? get isNewUser => _isNewUser;
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    _checkInitialAuthState();
    _setupAuthListener();
  }

  AuthMethod? get authMethod => _authMethod;

  // Listen to auth state changes (important for OAuth)
  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final user = session?.user;

      if (user != null) {
        _status = AuthStatus.authenticated;
        _userId = user.id;
        _userEmail = user.email;
        notifyListeners();
      } else {
        _status = AuthStatus.unauthenticated;
        _userId = null;
        _userEmail = null;
        notifyListeners();
      }
    });
  }

  // Check if user is already logged in when app starts
  Future<void> _checkInitialAuthState() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      if (session != null && user != null) {
        _status = AuthStatus.authenticated;
        _userId = user.id;
        _userEmail = user.email;
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

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user data: $e');
      // If table doesn't exist, treat as no data
      return false;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.email;
    _isNewUser = true;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _status = AuthStatus.authenticated;
        _userId = response.user!.id;
        _userEmail = response.user!.email;
      }
    } catch (e) {
      _error = e.toString();
      print('Sign up error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.email;
    _isNewUser = false;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _status = AuthStatus.authenticated;
        _userId = response.user!.id;
        _userEmail = response.user!.email;
      }
    } catch (e) {
      _error = e.toString();
      print('Sign in error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.apple;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo:
            'your-app-scheme://callback', // TODO: Configure your deep link
      );

      // OAuth redirects to browser
      // Auth state will be updated via listener after redirect
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    _authMethod = AuthMethod.google;

    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'your-app-scheme://callback', // TODO: Configure your deep link
      );

      // OAuth redirects to browser
      // Auth state will be updated via listener after redirect
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _status = AuthStatus.guest;
    _authMethod = AuthMethod.guest;
    _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    _isNewUser = true;
    _status = AuthStatus.authenticated;

    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }

    _status = AuthStatus.unauthenticated;
    _userId = null;
    _userEmail = null;
    _isNewUser = null;
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
