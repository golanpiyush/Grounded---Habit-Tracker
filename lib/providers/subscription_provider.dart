// subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { free, premium, lifetime }

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionTier _tier = SubscriptionTier.free;
  DateTime? _expiryDate;
  bool _isLoading = false;

  SubscriptionTier get tier => _tier;
  DateTime? get expiryDate => _expiryDate;
  bool get isLoading => _isLoading;

  bool get isPremium =>
      _tier == SubscriptionTier.premium || _tier == SubscriptionTier.lifetime;
  bool get isFree => _tier == SubscriptionTier.free;
  bool get isLifetime => _tier == SubscriptionTier.lifetime;

  // Feature access checks
  bool get canAccessAdvancedAnalytics => isPremium;
  bool get canAccessCustomGoals => isPremium;
  bool get canAccessUnlimitedTracking => isPremium;
  bool get canExportData => isPremium;
  bool get canAccessAIInsights => isPremium;
  bool get hasAdFreeExperience => isPremium;

  // Free tier limits
  int get maxSubstances => isFree ? 3 : 999;
  int get maxDailyCheckIns => isFree ? 1 : 999;
  int get analyticsHistoryDays => isFree ? 7 : 999;

  SubscriptionProvider() {
    loadSubscriptionStatus();
  }

  Future<void> loadSubscriptionStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved subscription data
      final tierString = prefs.getString('subscription_tier') ?? 'free';
      final expiryTimestamp = prefs.getInt('subscription_expiry');

      _tier = SubscriptionTier.values.firstWhere(
        (e) => e.toString().split('.').last == tierString,
        orElse: () => SubscriptionTier.free,
      );

      if (expiryTimestamp != null) {
        _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);

        // Check if subscription has expired
        if (_expiryDate!.isBefore(DateTime.now()) &&
            _tier != SubscriptionTier.lifetime) {
          _tier = SubscriptionTier.free;
          _expiryDate = null;
          await _saveSubscriptionStatus();
        }
      }
    } catch (e) {
      debugPrint('Error loading subscription status: $e');
      _tier = SubscriptionTier.free;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'subscription_tier',
        _tier.toString().split('.').last,
      );

      if (_expiryDate != null) {
        await prefs.setInt(
          'subscription_expiry',
          _expiryDate!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove('subscription_expiry');
      }
    } catch (e) {
      debugPrint('Error saving subscription status: $e');
    }
  }

  Future<void> upgradeToPremium({required Duration duration}) async {
    _tier = SubscriptionTier.premium;
    _expiryDate = DateTime.now().add(duration);
    await _saveSubscriptionStatus();
    notifyListeners();
  }

  Future<void> upgradeToLifetime() async {
    _tier = SubscriptionTier.lifetime;
    _expiryDate = null;
    await _saveSubscriptionStatus();
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    _tier = SubscriptionTier.free;
    _expiryDate = null;
    await _saveSubscriptionStatus();
    notifyListeners();
  }

  // Mock purchase methods (replace with actual payment integration)
  Future<bool> purchaseMonthly() async {
    try {
      // TODO: Integrate with your payment provider (Stripe, RevenueCat, etc.)
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      await upgradeToPremium(duration: const Duration(days: 30));
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  Future<bool> purchaseYearly() async {
    try {
      // TODO: Integrate with your payment provider
      await Future.delayed(const Duration(seconds: 2));

      await upgradeToPremium(duration: const Duration(days: 365));
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  Future<bool> purchaseLifetime() async {
    try {
      // TODO: Integrate with your payment provider
      await Future.delayed(const Duration(seconds: 2));

      await upgradeToLifetime();
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  String getRemainingDaysText() {
    if (_tier == SubscriptionTier.lifetime) {
      return 'Lifetime access';
    }

    if (_expiryDate == null) {
      return 'Free plan';
    }

    final remaining = _expiryDate!.difference(DateTime.now()).inDays;

    if (remaining <= 0) {
      return 'Expired';
    } else if (remaining == 1) {
      return '1 day remaining';
    } else {
      return '$remaining days remaining';
    }
  }
}
