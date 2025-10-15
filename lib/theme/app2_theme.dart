// // app_theme.dart
// import 'package:flutter/material.dart';
// import 'app_colors.dart';

// class AppTheme {
//   // Light Theme
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       primaryColor: AppColors.primaryGreen,
//       scaffoldBackgroundColor: AppColors.backgroundColor,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: AppColors.textPrimary),
//         titleTextStyle: TextStyle(
//           color: AppColors.textPrimary,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         color: AppColors.cardColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: EdgeInsets.zero,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.cardColor,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.borderColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.borderColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primaryGreen),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.errorRed),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.errorRed),
//         ),
//         labelStyle: const TextStyle(
//           color: AppColors.textSecondary,
//           fontSize: 14,
//         ),
//         hintStyle: const TextStyle(
//           color: AppColors.textSecondary,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }

//   // Dark Theme
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       primaryColor: AppColors.primaryGreen,
//       scaffoldBackgroundColor: const Color(0xFF121212),
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         color: const Color(0xFF1E1E1E),
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: EdgeInsets.zero,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFF1E1E1E),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primaryGreen),
//         ),
//         labelStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
//         hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
//       ),
//     );
//   }

//   // AMOLED Theme (Pure Black)
//   static ThemeData get amoledTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       primaryColor: AppColors.primaryGreen,
//       scaffoldBackgroundColor: Colors.black,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//         titleTextStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         color: const Color(0xFF0A0A0A),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: Colors.grey.withOpacity(0.1)),
//         ),
//         margin: EdgeInsets.zero,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFF0A0A0A),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF1A1A1A)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primaryGreen),
//         ),
//         labelStyle: const TextStyle(color: Color(0xFF909090), fontSize: 14),
//         hintStyle: const TextStyle(color: Color(0xFF909090), fontSize: 14),
//       ),
//     );
//   }
// }
