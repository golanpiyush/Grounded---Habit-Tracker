// onboarding_provider.dart

import 'package:flutter/foundation.dart';

class OnboardingProvider with ChangeNotifier {
  int _currentPage = 0;
  bool _onboardingCompleted = false;

  int get currentPage => _currentPage;
  bool get onboardingCompleted => _onboardingCompleted;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingCompleted = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _currentPage = 0;
    _onboardingCompleted = false;
    notifyListeners();
  }

  // Add this method to set onboarding completed from main.dart
  void setOnboardingCompleted(bool completed) {
    _onboardingCompleted = completed;
    notifyListeners();
  }
}
