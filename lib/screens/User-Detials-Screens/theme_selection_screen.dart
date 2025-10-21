// ===========================
// lib/screens/theme_selection_screen.dart
// ===========================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:Grounded/utils/emoji_assets.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColorsTheme.getTextPrimary(currentTheme),
            size: 20,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Theme',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(GroundedSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your preferred theme',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColorsTheme.getTextSecondary(currentTheme)),
            ),
            const SizedBox(height: GroundedSpacing.xl),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: AppThemeMode.light,
              title: 'Light',
              description: 'Bright and clear',
              emoji: EmojiAssets.sun,
              currentTheme: currentTheme,
            ),
            const SizedBox(height: GroundedSpacing.md),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: AppThemeMode.dark,
              title: 'Dark',
              description: 'Easy on the eyes',
              emoji: EmojiAssets.moon,
              currentTheme: currentTheme,
            ),
            const SizedBox(height: GroundedSpacing.md),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: AppThemeMode.amoled,
              title: 'AMOLED',
              description: 'Pure black for OLED screens',
              emoji: EmojiAssets.sparkles,
              currentTheme: currentTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemeMode mode,
    required String title,
    required String description,
    required String emoji,
    required AppThemeMode currentTheme,
  }) {
    final isSelected = currentTheme == mode;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeProvider.notifier).setTheme(mode);
      },
      child: Container(
        padding: const EdgeInsets.all(GroundedSpacing.lg),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColorsTheme.getBorder(currentTheme),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColorsTheme.getBorder(currentTheme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Image.asset(emoji, width: 24, height: 24)),
            ),
            const SizedBox(width: GroundedSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
