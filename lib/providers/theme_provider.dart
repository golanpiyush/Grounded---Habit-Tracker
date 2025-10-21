// ===========================
// lib/providers/theme_provider.dart
// ===========================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme modes available in the app
enum AppThemeMode { light, dark, amoled }

/// Provider for SharedPreferences instance
/// This MUST be overridden in main() with the pre-loaded instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in main() with a pre-loaded instance',
  );
});

/// Notifier for managing app theme
class ThemeNotifier extends Notifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    // Get the pre-loaded SharedPreferences instance (synchronous!)
    final prefs = ref.watch(sharedPreferencesProvider);

    // Read saved theme from SharedPreferences
    final themeString = prefs.getString(_themeKey);

    if (themeString != null) {
      // Find matching enum value
      return AppThemeMode.values.firstWhere(
        (e) => e.name == themeString,
        orElse: () => AppThemeMode.light,
      );
    }

    // Default theme if nothing saved
    return AppThemeMode.light;
  }

  /// Update theme and persist to SharedPreferences
  Future<void> setTheme(AppThemeMode mode) async {
    // Update state immediately (triggers UI rebuild)
    state = mode;

    // Persist to SharedPreferences
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themeKey, mode.name);
  }

  /// Get current theme (convenience method)
  AppThemeMode get currentTheme => state;

  /// Check if dark mode is active (dark or amoled)
  bool get isDarkMode =>
      state == AppThemeMode.dark || state == AppThemeMode.amoled;

  /// Check if AMOLED mode is active
  bool get isAmoledMode => state == AppThemeMode.amoled;
}

/// Provider for theme state
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);
