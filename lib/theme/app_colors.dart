// app_colors.dart

import 'package:flutter/material.dart';
import 'package:grounded/providers/theme_provider.dart';

class AppColors {
  // Primary Colors
  static const primaryGreen = Color(0xFF2D5016);
  static const secondaryGreen = Color(0xFF3D5A3C);
  static const accentOrange = Color(0xFFE89537);
  static const successGreen = Color(0xFF10B981);
  static const background = Color(0xFFFAFAF8);
  static const card = Color(0xFFFFFFFF);

  static const textTertiary = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);

  // Neutrals
  static const backgroundColor = Color(0xFFFAFAF8);
  static const cardColor = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  // Status Colors
  static const errorRed = Color(0xFFEF4444);
  static const warningYellow = Color(0xFFF59E0B);

  // Semantic Colors
  static const primaryButtonColor = primaryGreen;
  static const primaryButtonTextColor = Color(0xFFFFFFFF);
  static const secondaryButtonColor = Color(0xFFFFFFFF);
  static const secondaryButtonBorderColor = borderColor;
  static const secondaryButtonTextColor = textPrimary;

  // Dark Theme Colors
  static const darkBackground = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA0A0A0);
  static const darkBorder = Color(0xFF333333);

  // Theme-based color getters
  static Color getBackgroundColor(AppThemeMode themeMode) {
    return themeMode == AppThemeMode.dark ? darkBackground : backgroundColor;
  }

  static Color getCardColor(AppThemeMode themeMode) {
    return themeMode == AppThemeMode.dark ? darkCard : cardColor;
  }

  static Color getTextPrimaryColor(AppThemeMode themeMode) {
    return themeMode == AppThemeMode.dark ? darkTextPrimary : textPrimary;
  }

  static Color getTextSecondaryColor(AppThemeMode themeMode) {
    return themeMode == AppThemeMode.dark ? darkTextSecondary : textSecondary;
  }

  static Color getBorderColor(AppThemeMode themeMode) {
    return themeMode == AppThemeMode.dark ? darkBorder : borderColor;
  }
}

class GroundedSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}
