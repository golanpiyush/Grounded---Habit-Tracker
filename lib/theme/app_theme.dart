// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useAmoled = false;

  ThemeMode get themeMode => _themeMode;
  bool get useAmoled => _useAmoled;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('app_theme') ?? 'System';
    _useAmoled = prefs.getBool('use_amoled') ?? false;

    switch (themeName) {
      case 'Light':
        _themeMode = ThemeMode.light;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'AMOLED':
        _themeMode = ThemeMode.dark;
        _useAmoled = true;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', themeName);

    switch (themeName) {
      case 'Light':
        _themeMode = ThemeMode.light;
        _useAmoled = false;
        break;
      case 'Dark':
        _themeMode = ThemeMode.dark;
        _useAmoled = false;
        break;
      case 'AMOLED':
        _themeMode = ThemeMode.dark;
        _useAmoled = true;
        await prefs.setBool('use_amoled', true);
        break;
      default:
        _themeMode = ThemeMode.system;
        _useAmoled = false;
    }

    notifyListeners();
  }
}

// Add this extension to your AppColors class
extension AppColorsTheme on AppColors {
  static Color getBackground(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFFFAFAF8);
      case AppThemeMode.dark:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.amoled:
        return const Color(0xFF000000);
    }
  }

  static Color getCard(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFFFFFFFF);
      case AppThemeMode.dark:
        return const Color(0xFF2A2A2A);
      case AppThemeMode.amoled:
        return const Color(0xFF0D0D0D);
    }
  }

  static Color getBorder(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFFE5E7EB);
      case AppThemeMode.dark:
        return const Color(0xFF3A3A3A);
      case AppThemeMode.amoled:
        return const Color(0xFF1F1F1F);
    }
  }

  static Color getTextPrimary(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.dark:
        return const Color(0xFFE5E7EB);
      case AppThemeMode.amoled:
        return const Color(0xFFFFFFFF);
    }
  }

  static Color getTextSecondary(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFF6B7280);
      case AppThemeMode.dark:
        return const Color(0xFF9CA3AF);
      case AppThemeMode.amoled:
        return const Color(0xFFB0B0B0);
    }
  }

  static Color getTextTertiary(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFF9CA3AF);
      case AppThemeMode.dark:
        return const Color(0xFF6B7280);
      case AppThemeMode.amoled:
        return const Color(0xFF808080);
    }
  }
}
