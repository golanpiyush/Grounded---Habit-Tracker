// theme_provider.dart
import 'package:flutter/material.dart';
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
