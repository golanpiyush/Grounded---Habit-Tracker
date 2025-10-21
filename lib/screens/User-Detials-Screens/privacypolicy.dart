import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:Grounded/utils/emoji_assets.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColorsTheme.getCard(currentTheme),
              border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColorsTheme.getTextPrimary(currentTheme),
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.successGreen.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          EmojiAssets.shield,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Privacy Matters',
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColorsTheme.getTextPrimary(
                                currentTheme,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated: October 20, 2025',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColorsTheme.getTextSecondary(
                                currentTheme,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Introduction
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.memo,
                title: 'Introduction',
                content:
                    'Welcome to Grounded. We are committed to protecting your privacy and handling your data with care. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our habit tracking and recovery support application.',
              ),

              // Information We Collect
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.fileFolder,
                title: 'Information We Collect',
                content:
                    'We collect information that you provide directly to us, including:\n\n'
                    '• Account Information: Name, email address, and authentication credentials\n'
                    '• Recovery Data: Substances tracked, goals, target dates, and daily entries\n'
                    '• Usage Data: App interactions, features used, and preferences\n'
                    '• Device Information: Device type, operating system, and app version',
              ),

              // How We Use Your Information
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.settings,
                title: 'How We Use Your Information',
                content:
                    'Your information is used to:\n\n'
                    '• Provide and maintain the Grounded service\n'
                    '• Personalize your recovery journey and insights\n'
                    '• Send reminders and motivational messages (if enabled)\n'
                    '• Improve our app features and user experience\n'
                    '• Ensure the security and integrity of our services',
              ),

              // Data Security
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.lock,
                title: 'Data Security',
                content:
                    'We implement industry-standard security measures to protect your data:\n\n'
                    '• End-to-end encryption for sensitive information\n'
                    '• Secure cloud storage with Supabase\n'
                    '• Regular security audits and updates\n'
                    '• Limited access to personal data by our team',
              ),

              // Your Rights
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.checkmark,
                title: 'Your Rights',
                content:
                    'You have the right to:\n\n'
                    '• Access your personal data at any time\n'
                    '• Update or correct your information\n'
                    '• Export your data in a portable format\n'
                    '• Request deletion of your account and data\n'
                    '• Opt-out of notifications and analytics',
              ),

              // Data Retention
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.calendar,
                title: 'Data Retention',
                content:
                    'We retain your data for as long as your account is active. When you delete your account, all personal data is permanently removed within 30 days. Recovery logs and statistics are anonymized for research purposes only with your explicit consent.',
              ),

              // Third-Party Services
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.link,
                title: 'Third-Party Services',
                content:
                    'Grounded uses the following third-party services:\n\n'
                    '• Supabase: Secure database and authentication\n'
                    '• Analytics: Anonymized usage statistics (optional)\n'
                    '• Notification Services: Push notifications for reminders\n\n'
                    'These services have their own privacy policies and we encourage you to review them.',
              ),

              // Children's Privacy
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.family,
                title: 'Children\'s Privacy',
                content:
                    'Grounded is not intended for users under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with personal data, please contact us immediately.',
              ),

              // Changes to Privacy Policy
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.bell,
                title: 'Changes to This Policy',
                content:
                    'We may update this Privacy Policy from time to time. We will notify you of any significant changes via email or in-app notification. Your continued use of Grounded after changes constitutes acceptance of the updated policy.',
              ),

              // Contact Us
              _buildSection(
                context: context,
                currentTheme: currentTheme,
                emoji: EmojiAssets.email,
                title: 'Contact Us',
                content:
                    'If you have questions or concerns about this Privacy Policy, please contact us:\n\n'
                    'Email: privacy@grounded.app\n'
                    'Support: support@grounded.app\n\n'
                    'We aim to respond to all inquiries within 48 hours.',
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.getCard(currentTheme),
                    border: Border.all(
                      color: AppColorsTheme.getBorder(currentTheme),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Image.asset(EmojiAssets.heart, width: 32, height: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Your recovery journey is private and secure',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required AppThemeMode currentTheme,
    required String emoji,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(emoji, width: 24, height: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColorsTheme.getTextSecondary(currentTheme),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
