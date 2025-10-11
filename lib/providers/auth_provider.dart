// auth_provider.dart

import 'package:flutter/foundation.dart';

enum AuthStatus { unauthenticated, authenticated, guest }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _userId;
  String? _userEmail;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, always succeed
    _status = AuthStatus.authenticated;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, always succeed
    _status = AuthStatus.authenticated;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = email;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _status = AuthStatus.authenticated;
    _userId = 'user_apple_${DateTime.now().millisecondsSinceEpoch}';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _status = AuthStatus.authenticated;
    _userId = 'user_google_${DateTime.now().millisecondsSinceEpoch}';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _status = AuthStatus.guest;
    _userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();
  }

  Future<void> signOut() async {
    _status = AuthStatus.unauthenticated;
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
