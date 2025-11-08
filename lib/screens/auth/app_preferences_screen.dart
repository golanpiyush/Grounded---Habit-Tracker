// app_preferences_screen.dart
import 'dart:convert';

import 'package:Grounded/Services/integrated_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:Grounded/models/onboarding_data.dart';
import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/screens/home_screen.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';

class AppPreferencesScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final OnboardingData onboardingData; // ADD THIS LINE

  const AppPreferencesScreen({
    Key? key,
    required this.onComplete,
    required this.onboardingData, // ADD THIS PARAMETER
  }) : super(key: key);

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen>
    with SingleTickerProviderStateMixin {
  final UserDatabaseService _dbService = UserDatabaseService();
  static final _notifService = IntegratedNotificationService();
  String _selectedTheme = 'Light';
  bool _dailyReminders = true;
  String _reminderTime = '20:00';
  bool _analyticsEnabled = true;
  bool _motivationalMessages = true;
  String _dataSharing = 'Anonymous';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final List<String> _themeOptions = ['Light', 'Dark', 'AMOLED'];
  final List<String> _dataSharingOptions = [
    'Anonymous',
    'Private',
    'Share insights',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('app_theme') ?? 'Light';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveToDatabase() async {
    try {
      // Get the complete data as JSON
      // final jsonData = widget.onboardingData.toJson();

      // TODO: Send to your database
      // Example with Firebase:
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .set(jsonData);

      // Or with your API:
      // await http.post(
      //   Uri.parse('your-api-endpoint'),
      //   body: jsonEncode(jsonData),
      //   headers: {'Content-Type': 'application/json'},
      // );

      print('All onboarding data: ');

      // Mark onboarding as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      print('Error saving to database: $e');
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
      }
    }
  }

  static Future<void> initializeNotificationsAfterOnboarding(
    String userId,
  ) async {
    print('🔔 Initializing notifications after onboarding...');
    try {
      await _notifService.initializeAfterAuth(userId);
      print('✅ Notifications initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  Future<void> _handleComplete() async {
    print('\n=== COMPLETING ONBOARDING - NAVIGATING TO HOME ===');
    print('⚙️ APP PREFERENCES DATA:');
    print('-------------------------------------------');
    print('Selected Theme: $_selectedTheme');
    print('Daily Reminders: ${_dailyReminders ? 'Enabled' : 'Disabled'}');
    if (_dailyReminders) {
      print('Reminder Time: $_reminderTime');
    }
    print('Analytics Enabled: ${_analyticsEnabled ? 'Yes' : 'No'}');
    print('Motivational Messages: ${_motivationalMessages ? 'Yes' : 'No'}');
    print('Data Sharing: $_dataSharing');
    print('  └─ ${_getDataSharingDescription(_dataSharing)}');
    print('-------------------------------------------');

    print('\n💾 SAVING APP PREFERENCES TO SHARED PREFERENCES...');

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_theme', _selectedTheme);
    print('  ✓ Theme saved: $_selectedTheme');

    // Update theme using Provider (with error handling)
    if (mounted) {
      try {
        await Provider.of<ThemeProvider>(
          context,
          listen: false,
        ).setTheme(_selectedTheme);
        print('  ✓ Theme applied via Provider');
      } catch (e) {
        print('  ⚠ ThemeProvider not available (will apply on restart): $e');
      }
    }

    await prefs.setBool('daily_reminders', _dailyReminders);
    print('  ✓ Daily reminders saved: $_dailyReminders');

    await prefs.setString('reminder_time', _reminderTime);
    print('  ✓ Reminder time saved: $_reminderTime');

    await prefs.setBool('analytics_enabled', _analyticsEnabled);
    print('  ✓ Analytics enabled saved: $_analyticsEnabled');

    await prefs.setBool('motivational_messages', _motivationalMessages);
    print('  ✓ Motivational messages saved: $_motivationalMessages');

    await prefs.setString('data_sharing', _dataSharing);
    print('  ✓ Data sharing preference saved: $_dataSharing');

    await prefs.setBool('onboarding_complete', true);
    print('  ✓ Onboarding marked as complete');

    print('✅ ALL APP PREFERENCES SAVED SUCCESSFULLY');

    // ============================================
    // SAVE TO SUPABASE DATABASE
    // ============================================
    print('\n💾 SAVING ONBOARDING DATA TO SUPABASE DATABASE...');

    try {
      final currentUser = _dbService.currentUser;

      if (currentUser != null) {
        print('  👤 User ID: ${currentUser.id}');

        // Save app preferences to database
        await _dbService.updateAppPreferences(
          userId: currentUser.id,
          appTheme: _selectedTheme,
          dailyReminders: _dailyReminders,
          reminderTime: _reminderTime,
          analyticsEnabled: _analyticsEnabled,
          motivationalMessages: _motivationalMessages,
          dataSharing: _dataSharing,
        );
        print('  ✅ App preferences saved to database');

        // Save onboarding data
        await _dbService.saveOnboardingData(
          userId: currentUser.id,
          onboardingData: widget.onboardingData,
        );
        print('  ✅ Onboarding data saved to database');

        // Initialize notifications with the current user ID
        await initializeNotificationsAfterOnboarding(currentUser.id);
        print('  ✅ Notifications initialized for user: ${currentUser.id}');
      } else {
        print('  ⚠ No user logged in - skipping database save');
      }
    } catch (e) {
      print('  ❌ Failed to save onboarding data to Supabase: $e');
    }

    // ============================================
    // FINAL SUMMARY
    // ============================================
    print('\n' + '=' * 50);
    print('🎉 ONBOARDING COMPLETE - FINAL DATA SUMMARY');
    print('=' * 50);

    print('\n📋 SCREEN 1 - GOALS & MOTIVATION:');
    print('  Goals: ${prefs.getStringList('user_goals') ?? 'Not saved'}');
    print('  Timeline: ${prefs.getString('user_timeline') ?? 'Not saved'}');
    print(
      '  Motivation Level: ${prefs.getInt('user_motivation_level') ?? 'Not saved'}',
    );
    print(
      '  Primary Reason: ${prefs.getString('user_primary_reason') ?? 'Not saved'}',
    );

    print('\n💊 SCREEN 2 - SUBSTANCE SELECTION:');
    final substances = prefs.getStringList('user_substances') ?? [];
    print(
      '  Selected Substances: ${substances.isEmpty ? 'None' : substances.join(', ')}',
    );
    print(
      '  Previous Attempts: ${prefs.getString('user_previous_attempts') ?? 'Not saved'}',
    );
    print(
      '  Substance Durations: ${prefs.getString('user_substance_durations') ?? 'Not saved'}',
    );

    print('\n📊 SCREEN 3 - USAGE PATTERNS:');
    if (substances.isNotEmpty) {
      for (final substance in substances) {
        print('  ── $substance ──');
        print(
          '    Frequency: ${prefs.getString('${substance}_frequency') ?? 'Not set'}',
        );
        print(
          '    Context: ${prefs.getString('${substance}_context') ?? 'Not set'}',
        );
        print(
          '    Methods: ${prefs.getStringList('${substance}_consumptionMethods') ?? 'Not set'}',
        );
        print(
          '    Amounts: ${prefs.getString('${substance}_typicalAmounts') ?? 'Not set'}',
        );
        print(
          '    Cost: ${prefs.getString('${substance}_costPerUse') ?? 'Not set'}',
        );
        print(
          '    Triggers: ${prefs.getStringList('${substance}_triggers') ?? 'Not set'}',
        );
        print(
          '    Impacts: ${prefs.getStringList('${substance}_impacts') ?? 'Not set'}',
        );
        print(
          '    Time of Day: ${prefs.getString('${substance}_timeOfDay') ?? 'Not set'}',
        );
      }
    } else {
      print('  No substances tracked');
    }

    print('\n🛡️ SCREEN 4 - SAFETY SETUP:');
    print(
      '  Support System: ${prefs.getString('user_support_system') ?? 'Not saved'}',
    );
    print(
      '  Emergency Contacts: ${prefs.getString('user_emergency_contacts') ?? 'None'}',
    );
    print(
      '  Withdrawal Concern: ${prefs.getString('user_withdrawal_concern') ?? 'Not saved'}',
    );
    print(
      '  Usage Context: ${prefs.getString('user_usage_context') ?? 'Not saved'}',
    );
    print(
      '  Crisis Resources: ${prefs.getBool('user_crisis_resources_enabled') ?? false}',
    );
    print(
      '  Harm Reduction Info: ${prefs.getBool('user_harm_reduction_info') ?? false}',
    );

    print('\n⚙️ SCREEN 5 - APP PREFERENCES:');
    print('  Theme: $_selectedTheme');
    print('  Daily Reminders: $_dailyReminders');
    print('  Reminder Time: $_reminderTime');
    print('  Analytics: $_analyticsEnabled');
    print('  Motivational Messages: $_motivationalMessages');
    print('  Data Sharing: $_dataSharing');

    print('\n' + '=' * 50);
    print('🚀 LAUNCHING HOME SCREEN');
    print('=' * 50 + '\n');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  // Add this method to _AppPreferencesScreenState class
  Future<void> _saveCompleteOnboardingData(String userId) async {
    try {
      print('\n📦 SAVING COMPLETE ONBOARDING DATA...');

      // Get SharedPreferences to retrieve all stored data
      final prefs = await SharedPreferences.getInstance();

      // Convert List<String> to Set<String> for the model
      final goalsList = prefs.getStringList('user_goals') ?? [];
      final substancesList = prefs.getStringList('user_substances') ?? [];
      final reasonsList = prefs.getStringList('user_selected_reasons') ?? [];

      // Build complete onboarding data with proper type conversions
      final onboardingData = OnboardingData(
        // Goals & Motivation - Convert List to Set
        selectedGoals: Set<String>.from(goalsList),
        selectedTimeline: prefs.getString('user_timeline') ?? '30 days',
        motivationLevel: prefs.getInt('user_motivation_level') ?? 5,
        primaryReason: prefs.getString('user_primary_reason') ?? 'Health',
        selectedReasons: Set<String>.from(reasonsList),

        // Substances - Convert List to Set
        selectedSubstances: Set<String>.from(substancesList),
        substanceAttempts: _parseSubstanceAttempts(prefs),
        substanceDurations: _parseSubstanceDurations(prefs),

        // Usage Patterns
        usagePatterns: await _buildUsagePatterns(prefs),

        // Safety - Fix emergency contacts type
        supportSystem: prefs.getString('user_support_system') ?? 'alone',
        emergencyContacts: _parseEmergencyContacts(prefs),
        withdrawalConcern: prefs.getString('user_withdrawal_concern') ?? 'none',
        usageContext: prefs.getString('user_usage_context') ?? 'alone',
        crisisResourcesEnabled:
            prefs.getBool('user_crisis_resources_enabled') ?? true,
        harmReductionInfo: prefs.getBool('user_harm_reduction_info') ?? true,
      );

      // Save to database
      await _dbService.saveOnboardingData(
        userId: userId,
        onboardingData: onboardingData,
      );

      // Save individual substance patterns
      await _saveSubstancePatterns(userId, prefs);

      print('✅ COMPLETE ONBOARDING DATA SAVED SUCCESSFULLY');
    } catch (e) {
      print('❌ Error saving complete onboarding data: $e');
      rethrow;
    }
  }

  // Helper methods for parsing data
  Map<String, String> _parseSubstanceAttempts(SharedPreferences prefs) {
    final attemptsJson = prefs.getString('user_previous_attempts');
    if (attemptsJson != null) {
      try {
        return Map<String, String>.from(json.decode(attemptsJson));
      } catch (e) {
        print('Error parsing substance attempts: $e');
      }
    }
    return {};
  }

  Map<String, String> _parseSubstanceDurations(SharedPreferences prefs) {
    final durationsJson = prefs.getString('user_substance_durations');
    if (durationsJson != null) {
      try {
        return Map<String, String>.from(json.decode(durationsJson));
      } catch (e) {
        print('Error parsing substance durations: $e');
      }
    }
    return {};
  }

  List<Map<String, String>> _parseEmergencyContacts(SharedPreferences prefs) {
    final contactsJson = prefs.getString('user_emergency_contacts');
    if (contactsJson != null && contactsJson.isNotEmpty) {
      try {
        final List<dynamic> contactsList = json.decode(contactsJson);
        return contactsList
            .map((contact) {
              if (contact is Map<String, dynamic>) {
                // Convert Map<String, dynamic> to Map<String, String>
                return contact.map(
                  (key, value) => MapEntry(key, value.toString()),
                );
              }
              return <String, String>{};
            })
            .where((contact) => contact.isNotEmpty)
            .toList();
      } catch (e) {
        print('Error parsing emergency contacts: $e');
      }
    }
    return [];
  }

  Future<Map<String, dynamic>> _buildUsagePatterns(
    SharedPreferences prefs,
  ) async {
    final patterns = <String, dynamic>{};
    final substances = prefs.getStringList('user_substances') ?? [];

    for (final substance in substances) {
      patterns[substance] = {
        'frequency': prefs.getString('${substance}_frequency'),
        'context': prefs.getString('${substance}_context'),
        'consumptionMethods': prefs.getStringList(
          '${substance}_consumptionMethods',
        ),
        'typicalAmounts': prefs.getString('${substance}_typicalAmounts'),
        'costPerUse': prefs.getString('${substance}_costPerUse'),
        'triggers': prefs.getStringList('${substance}_triggers'),
        'impacts': prefs.getStringList('${substance}_impacts'),
        'timeOfDay': prefs.getString('${substance}_timeOfDay'),
      };
    }

    return patterns;
  }

  Future<void> _saveSubstancePatterns(
    String userId,
    SharedPreferences prefs,
  ) async {
    final substances = prefs.getStringList('user_substances') ?? [];

    for (final substance in substances) {
      try {
        await _dbService.saveSubstancePattern(
          userId: userId,
          substanceName: substance,
          frequency: prefs.getString('${substance}_frequency'),
          context: prefs.getString('${substance}_context'),
          consumptionMethods: prefs.getStringList(
            '${substance}_consumptionMethods',
          ),
          typicalAmounts: _parseTypicalAmounts(
            prefs.getString('${substance}_typicalAmounts'),
          ),
          costPerUse: prefs.getString('${substance}_costPerUse'),
          triggers: prefs.getStringList('${substance}_triggers'),
          impacts: prefs.getStringList('${substance}_impacts'),
          timeOfDay: prefs.getString('${substance}_timeOfDay'),
        );
        print('  ✅ Pattern saved for $substance');
      } catch (e) {
        print('  ❌ Error saving pattern for $substance: $e');
      }
    }
  }

  Map<String, String> _parseTypicalAmounts(String? amountsJson) {
    if (amountsJson != null) {
      try {
        return Map<String, String>.from(json.decode(amountsJson));
      } catch (e) {
        print('Error parsing typical amounts: $e');
      }
    }
    return {};
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2D5016)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Almost there!',
                        style: TextStyle(
                          color: Color(0xFF2D5016),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // Animated Header
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2D5016).withOpacity(0.1),
                                      const Color(0xFF4CAF50).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '⚙️',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Customize your experience',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'App\nPreferences',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Make Grounded work best for you and your journey.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Theme Selection
                      // Theme Selection
                      _buildAnimatedSection(
                        delay: 100,
                        child: _PreferenceSection(
                          icon: Icons.palette_outlined,
                          title: 'App Theme',
                          child: Wrap(
                            spacing: 12,
                            children: _themeOptions.map((theme) {
                              final isSelected = _selectedTheme == theme;
                              return _PreferenceChip(
                                text: theme,
                                isSelected: isSelected,
                                onTap: () async {
                                  setState(() => _selectedTheme = theme);
                                  // Update theme immediately (with error handling)
                                  if (mounted) {
                                    try {
                                      await Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).setTheme(theme);
                                    } catch (e) {
                                      // ThemeProvider not available, theme will be saved to prefs anyway
                                      print('ThemeProvider not available: $e');
                                    }
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Daily Reminders
                      _buildAnimatedSection(
                        delay: 200,
                        child: _PreferenceSection(
                          icon: Icons.notifications_outlined,
                          title: 'Daily Check-in Reminders',
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Enable reminders',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Switch(
                                    value: _dailyReminders,
                                    onChanged: (value) =>
                                        setState(() => _dailyReminders = value),
                                    activeColor: const Color(0xFF2D5016),
                                  ),
                                ],
                              ),
                              if (_dailyReminders) ...[
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _showTimePicker,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Reminder time',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          _reminderTime,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D5016),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Motivational Messages
                      _buildAnimatedSection(
                        delay: 300,
                        child: _PreferenceSection(
                          icon: Icons.emoji_objects_outlined,
                          title: 'Motivational Messages',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Receive encouraging messages and insights',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Switch(
                                value: _motivationalMessages,
                                onChanged: (value) => setState(
                                  () => _motivationalMessages = value,
                                ),
                                activeColor: const Color(0xFF2D5016),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Data Sharing
                      _buildAnimatedSection(
                        delay: 400,
                        child: _PreferenceSection(
                          icon: Icons.security_outlined,
                          title: 'Data Privacy',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How we use your data',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _dataSharingOptions.map((option) {
                                  final isSelected = _dataSharing == option;
                                  return _PreferenceChip(
                                    text: option,
                                    isSelected: isSelected,
                                    onTap: () =>
                                        setState(() => _dataSharing = option),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getDataSharingDescription(_dataSharing),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Privacy Note
                      _buildAnimatedSection(
                        delay: 500,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2D5016).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: const Color(0xFF2D5016),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your data is always encrypted and never shared without your explicit consent.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF2D5016),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),

            // Get Started Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CustomButton(
                  text: 'Get Started',
                  onPressed: _handleComplete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDataSharingDescription(String option) {
    switch (option) {
      case 'Anonymous':
        return 'Your data is completely anonymous and used only for app improvements';
      case 'Private':
        return 'Your data is stored privately and used for your personal insights only';
      case 'Share insights':
        return 'Anonymous insights may be used to help improve harm reduction resources';
      default:
        return '';
    }
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _PreferenceSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 230, 242, 230),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF2D5016), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PreferenceChip extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _PreferenceChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PreferenceChip> createState() => _PreferenceChipState();
}

class _PreferenceChipState extends State<_PreferenceChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isSelected ? const Color(0xFF2D5016) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF2D5016)
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isSelected ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
