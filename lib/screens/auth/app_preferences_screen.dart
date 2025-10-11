// app_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:grounded/Models/dashboard_Data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';

class AppPreferencesScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AppPreferencesScreen({Key? key, required this.onComplete})
    : super(key: key);

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTheme = 'System';
  bool _dailyReminders = true;
  String _reminderTime = '20:00';
  bool _analyticsEnabled = true;
  bool _motivationalMessages = true;
  String _dataSharing = 'Anonymous';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _themeOptions = ['System', 'Light', 'Dark'];
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_theme', _selectedTheme);
    await prefs.setBool('daily_reminders', _dailyReminders);
    await prefs.setString('reminder_time', _reminderTime);
    await prefs.setBool('analytics_enabled', _analyticsEnabled);
    await prefs.setBool('motivational_messages', _motivationalMessages);
    await prefs.setString('data_sharing', _dataSharing);
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      widget.onComplete();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
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
                                onTap: () =>
                                    setState(() => _selectedTheme = theme),
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
