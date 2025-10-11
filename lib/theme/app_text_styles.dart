// app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    );
  }

  // Caption Styles
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    );
  }

  // Button Styles
  static TextStyle buttonLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryButtonTextColor,
    );
  }

  static TextStyle buttonMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryButtonTextColor,
    );
  }
}
