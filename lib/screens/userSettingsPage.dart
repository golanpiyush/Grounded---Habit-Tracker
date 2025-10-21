// Add this to your pubspec.yaml dependencies:
// shimmer: ^3.0.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grounded/providers/theme_provider.dart';
import 'package:grounded/providers/userDB.dart';
import 'package:grounded/screens/User-Detials-Screens/editDetails.dart';
import 'package:grounded/screens/User-Detials-Screens/editGoals.dart';
import 'package:grounded/screens/User-Detials-Screens/editSubstances.dart';
import 'package:grounded/screens/User-Detials-Screens/editTargetDate.dart';
import 'package:grounded/screens/User-Detials-Screens/privacypolicy.dart';
import 'package:grounded/screens/User-Detials-Screens/theme_selection_screen.dart';
import 'package:grounded/theme/app_colors.dart';
import 'package:grounded/theme/app_text_styles.dart';
import 'package:grounded/theme/app_theme.dart';
import 'package:grounded/utils/emoji_assets.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class SettingsScreen extends ConsumerStatefulWidget {
  final Offset tapPosition;

  const SettingsScreen({Key? key, required this.tapPosition}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final UserDatabaseService _userDb = UserDatabaseService();

  bool _isLoading = true;
  bool _showShimmer = true;

  // Cached data
  static Map<String, dynamic>? _cachedUserProfile;
  static Map<String, dynamic>? _cachedOnboardingData;
  static List<Map<String, dynamic>> _cachedSubstancePatterns = [];
  static DateTime? _lastCacheUpdate;

  // Current data
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _onboardingData;
  List<Map<String, dynamic>> _substancePatterns = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _userDb.currentUser?.id;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _showShimmer = false;
        });
        return;
      }

      // Check if we have cached data and it's recent (less than 5 minutes old)
      final cacheIsValid =
          _cachedUserProfile != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < Duration(minutes: 5);

      if (cacheIsValid) {
        // Use cached data immediately
        setState(() {
          _userProfile = _cachedUserProfile;
          _onboardingData = _cachedOnboardingData;
          _substancePatterns = _cachedSubstancePatterns;
          _isLoading = false;
          _showShimmer = false;
        });

        // Load fresh data in background
        _loadFreshData(userId);
      } else {
        // Show shimmer while loading
        setState(() {
          _showShimmer = true;
          _isLoading = true;
        });

        // Load fresh data
        await _loadFreshData(userId);

        setState(() {
          _isLoading = false;
          _showShimmer = false;
        });
      }
    } catch (e) {
      print('❌ Error loading settings data: $e');
      setState(() {
        _isLoading = false;
        _showShimmer = false;
      });
    }
  }

  Future<void> _loadFreshData(String userId) async {
    final profile = await _userDb.getUserProfile(userId);
    final onboarding = await _userDb.getOnboardingData(userId);
    final substances = await _userDb.getSubstancePatterns(userId);

    // Update cache
    _cachedUserProfile = profile;
    _cachedOnboardingData = onboarding;
    _cachedSubstancePatterns = substances;
    _lastCacheUpdate = DateTime.now();

    // Update UI if data changed
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _onboardingData = onboarding;
        _substancePatterns = substances;
      });
    }
  }

  // Invalidate cache when data is updated
  void _invalidateCache() {
    _cachedUserProfile = null;
    _cachedOnboardingData = null;
    _cachedSubstancePatterns = [];
    _lastCacheUpdate = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  double _calculateMaxRadius(Size size, Offset center) {
    final double maxX = math.max(center.dx, size.width - center.dx);
    final double maxY = math.max(center.dy, size.height - center.dy);
    return math.sqrt(maxX * maxX + maxY * maxY);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = _calculateMaxRadius(size, widget.tapPosition);
    final currentTheme = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: () async {
        await _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return ClipPath(
              clipper: CircularRevealClipper(
                center: widget.tapPosition,
                radius: maxRadius * _scaleAnimation.value,
              ),
              child: Container(
                color: AppColorsTheme.getBackground(currentTheme),
                child: child,
              ),
            );
          },
          child: SafeArea(
            child: _showShimmer ? _buildShimmerContent() : _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    final currentTheme = ref.watch(themeProvider);

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildShimmerProfile(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recovery Settings'),
              const SizedBox(height: 12),
              _buildShimmerCard(),
              const SizedBox(height: 12),
              _buildShimmerCard(),
              const SizedBox(height: 12),
              _buildShimmerCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('App Preferences'),
              const SizedBox(height: 12),
              _buildShimmerCard(height: 200),
              const SizedBox(height: 24),
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              _buildShimmerCard(height: 180),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerProfile() {
    final currentTheme = ref.watch(themeProvider);

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.getBorder(currentTheme).withOpacity(0.3),
      highlightColor: AppColorsTheme.getCard(currentTheme),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColorsTheme.getBorder(currentTheme),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColorsTheme.getBorder(currentTheme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColorsTheme.getBorder(currentTheme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard({double height = 80}) {
    final currentTheme = ref.watch(themeProvider);

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.getBorder(currentTheme).withOpacity(0.3),
      highlightColor: AppColorsTheme.getCard(currentTheme),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColorsTheme.getCard(currentTheme),
          border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recovery Settings'),
              const SizedBox(height: 12),
              _buildSubstancesCard(),
              const SizedBox(height: 12),
              _buildGoalsCard(),
              const SizedBox(height: 12),
              _buildTargetDateCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('App Preferences'),
              const SizedBox(height: 12),
              _buildPreferencesCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              _buildAccountCard(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    final currentTheme = ref.watch(themeProvider);

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
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
        onPressed: _handleBack,
      ),
      title: Text(
        'Settings',
        style: AppTextStyles.headlineSmall(
          context,
        ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
      ),
    );
  }

  Widget _buildProfileSection() {
    final currentTheme = ref.watch(themeProvider);
    final fullName = _userProfile?['full_name'] ?? 'User';
    final email = _userProfile?['email'] ?? '';

    return GestureDetector(
      onTap: () => _editProfile(),
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
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.2),
                    AppColors.primaryGreen.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: AppColorsTheme.getTextSecondary(currentTheme),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final currentTheme = ref.watch(themeProvider);

    return Text(
      title,
      style: AppTextStyles.headlineSmall(context).copyWith(
        fontSize: 18,
        color: AppColorsTheme.getTextPrimary(currentTheme),
      ),
    );
  }

  Widget _buildSubstancesCard() {
    final substances = _onboardingData?['selected_substances'] as List? ?? [];

    return _buildSettingCard(
      emoji: EmojiAssets.pill,
      title: 'Substances',
      subtitle: substances.isEmpty
          ? 'No substances tracked'
          : '${substances.length} substance${substances.length > 1 ? 's' : ''}',
      onTap: () => _editSubstances(),
    );
  }

  Widget _buildGoalsCard() {
    final goals = _onboardingData?['selected_goals'] as List? ?? [];
    final goalText = goals.isEmpty ? 'No goals set' : goals.first;

    return _buildSettingCard(
      emoji: EmojiAssets.target,
      title: 'Goals',
      subtitle: goalText,
      onTap: () => _editGoals(),
    );
  }

  Widget _buildTargetDateCard() {
    final timeline = _onboardingData?['selected_timeline'] ?? 'Not set';
    final targetDateStr = _onboardingData?['target_date'];
    String subtitle = timeline;

    if (targetDateStr != null) {
      try {
        final targetDate = DateTime.parse(targetDateStr);
        final daysLeft = targetDate.difference(DateTime.now()).inDays;
        subtitle = '$timeline ($daysLeft days left)';
      } catch (e) {
        subtitle = timeline;
      }
    }

    return _buildSettingCard(
      emoji: EmojiAssets.calendar,
      title: 'Target Date',
      subtitle: subtitle,
      onTap: () => _editTargetDate(),
    );
  }

  Widget _buildPreferencesCard() {
    final currentTheme = ref.watch(themeProvider);

    return Container(
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
        children: [
          _buildSwitchTile(
            emoji: EmojiAssets.bell,
            title: 'Daily Reminders',
            value: _onboardingData?['daily_reminders'] ?? true,
            onChanged: (value) => _updatePreference('daily_reminders', value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            emoji: EmojiAssets.sparkles,
            title: 'Motivational Messages',
            value: _onboardingData?['motivational_messages'] ?? true,
            onChanged: (value) =>
                _updatePreference('motivational_messages', value),
          ),
          _buildDivider(),
          _buildSwitchTile(
            emoji: EmojiAssets.chartUp,
            title: 'Analytics',
            value: _onboardingData?['analytics_enabled'] ?? true,
            onChanged: (value) => _updatePreference('analytics_enabled', value),
          ),
          _buildDivider(),
          _buildNavigationTile(
            emoji: EmojiAssets.palette,
            title: 'Theme',
            value: _getThemeDisplayName(currentTheme),
            onTap: () => _changeTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    final currentTheme = ref.watch(themeProvider);

    return Container(
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
        children: [
          _buildNavigationTile(
            emoji: EmojiAssets.download,
            title: 'Export Data',
            value: 'Download your data',
            onTap: () => _exportData(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            emoji: EmojiAssets.shield,
            title: 'Privacy Policy',
            value: 'View policy',
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildDivider(),
          _buildNavigationTile(
            emoji: EmojiAssets.trash,
            title: 'Logout',
            value: '',
            onTap: () => _logout(),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildNavigationTile(
            emoji: EmojiAssets.logout,
            title: 'Delete Account',
            value: 'Permanently delete',
            onTap: () => _deleteAccount(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final currentTheme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Image.asset(emoji, width: 24, height: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColorsTheme.getTextSecondary(currentTheme),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String emoji,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final currentTheme = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(emoji, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String emoji,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final currentTheme = ref.watch(themeProvider);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Image.asset(emoji, width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: isDestructive
                          ? Colors.red
                          : AppColorsTheme.getTextPrimary(currentTheme),
                    ),
                  ),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColorsTheme.getTextSecondary(currentTheme),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColorsTheme.getTextSecondary(currentTheme),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final currentTheme = ref.watch(themeProvider);

    return Divider(
      height: 1,
      thickness: 1,
      color: AppColorsTheme.getBorder(currentTheme),
      indent: 52,
    );
  }

  Future<void> _openPrivacyPolicy() async {
    HapticFeedback.lightImpact();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  // Action Methods
  Future<void> _editProfile() async {
    HapticFeedback.lightImpact();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: _userProfile),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final userId = _userDb.currentUser?.id;
      if (userId != null) {
        // Update database
        await _userDb.updateUserProfile(
          userId: userId,
          fullName: result['full_name'],
        );

        // Upload profile image if changed
        if (result['profile_image'] != null) {
          // TODO: Upload image to storage and update profile
          print('📸 Profile image updated');
        }

        _invalidateCache(); // Clear cache
        await _loadUserData(); // Reload data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _editSubstances() async {
    HapticFeedback.lightImpact();

    final currentSubstances = _onboardingData?['selected_substances'] as List?;
    final substanceNames = currentSubstances?.map((s) => s.toString()).toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditSubstancesScreen(selectedSubstances: substanceNames),
      ),
    );

    if (result != null && result is List<String>) {
      final userId = _userDb.currentUser?.id;
      if (userId != null) {
        // Update database
        await _userDb.updateSubstances(userId: userId, substances: result);

        _invalidateCache(); // Clear cache
        await _loadUserData(); // Reload data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Substances updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _editGoals() async {
    HapticFeedback.lightImpact();

    final currentGoals = _onboardingData?['selected_goals'] as List?;
    final goalNames = currentGoals?.map((g) => g.toString()).toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGoalsScreen(selectedGoals: goalNames),
      ),
    );

    if (result != null && result is List<String>) {
      final userId = _userDb.currentUser?.id;
      if (userId != null) {
        // Update database
        await _userDb.updateGoals(userId: userId, goals: result);

        _invalidateCache(); // Clear cache
        await _loadUserData(); // Reload data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goals updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _editTargetDate() async {
    HapticFeedback.lightImpact();

    final currentTargetDateStr = _onboardingData?['target_date'];
    DateTime? currentTargetDate;

    if (currentTargetDateStr != null) {
      try {
        currentTargetDate = DateTime.parse(currentTargetDateStr);
      } catch (e) {
        print('❌ Error parsing target date: $e');
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTargetDateScreen(
          currentTargetDate: currentTargetDate,
          currentTimeline: _onboardingData?['selected_timeline'],
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final userId = _userDb.currentUser?.id;
      if (userId != null) {
        // Update database
        await _userDb.updateTargetDate(
          userId: userId,
          timeline: result['timeline'],
          targetDate: result['target_date'],
        );

        _invalidateCache(); // Clear cache
        await _loadUserData(); // Reload data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Target date updated successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    final userId = _userDb.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _onboardingData?[key] = value;
    });

    await _userDb.updateAppPreferences(
      userId: userId,
      dailyReminders: key == 'daily_reminders' ? value : null,
      motivationalMessages: key == 'motivational_messages' ? value : null,
      analyticsEnabled: key == 'analytics_enabled' ? value : null,
    );

    _invalidateCache(); // Invalidate cache on update
  }

  Future<void> _changeTheme() async {
    HapticFeedback.lightImpact();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemeSelectionScreen()),
    );
  }

  Future<void> _exportData() async {
    final userId = _userDb.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _userDb.exportUserData(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.amoled:
        return 'AMOLED';
    }
  }

  Future<void> _logout() async {
    final currentTheme = ref.watch(themeProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsTheme.getCard(currentTheme),
        title: Text(
          'Logout',
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColorsTheme.getTextSecondary(currentTheme),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userDb.logOut();
      _invalidateCache();
    }
  }

  Future<void> _deleteAccount() async {
    final currentTheme = ref.watch(themeProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorsTheme.getCard(currentTheme),
        title: Text(
          'Delete Account',
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(color: AppColorsTheme.getTextPrimary(currentTheme)),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be deleted witin 30 days.',
          style: TextStyle(
            color: AppColorsTheme.getTextSecondary(currentTheme),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userId = _userDb.currentUser?.id;
      if (userId != null) {
        await _userDb.deleteUserAccount(userId);
        _invalidateCache();
      }
    }
  }
}

// Circular Reveal Clipper
class CircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircularRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
