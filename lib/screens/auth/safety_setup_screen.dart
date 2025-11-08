// safety_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:Grounded/models/onboarding_data.dart';
import 'package:Grounded/screens/auth/app_preferences_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';

class SafetySetupScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final OnboardingData onboardingData;

  const SafetySetupScreen({
    Key? key,
    required this.onContinue,
    required this.onboardingData,
  }) : super(key: key);

  @override
  State<SafetySetupScreen> createState() => _SafetySetupScreenState();
}

class _SafetySetupScreenState extends State<SafetySetupScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final int _maxContacts = 3;
  List<Map<String, String>> _emergencyContacts = [];
  String? _supportSystem;
  String? _withdrawalConcern;
  String? _usageContext;
  bool _crisisResourcesEnabled = true;
  bool _harmReductionInfo = false;
  int _currentPage = 0;

  late AnimationController _animationController;

  final List<String> _supportOptions = [
    'Yes, they know my goals',
    'Yes, but they don\'t know yet',
    'I prefer to do this alone',
    'I\'d like to find support',
  ];

  final List<String> _withdrawalOptions = [
    'Yes, under medical supervision',
    'No, but I should be',
    'Not needed for my situation',
    'I don\'t know',
  ];

  final List<String> _usageContextOptions = [
    'Mostly alone',
    'Mostly with others',
    'Both equally',
  ];

  final List<Map<String, String>> _crisisResources = [
    {'name': 'Substance Abuse Helpline', 'number': '1-800-662-4357'},
    {'name': 'Crisis Text Line', 'number': 'Text HOME to 741741'},
    {'name': 'SAMHSA National Helpline', 'number': '1-800-487-4889'},
    {'name': '988 Suicide & Crisis Lifeline', 'number': '988'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    // PRINT ALL SAFETY SETUP DATA BEFORE SAVING AND NAVIGATION
    print('\n=== NAVIGATING TO APP PREFERENCES SCREEN ===');
    print('🛡️ SAFETY SETUP DATA:');
    print('-------------------------------------------');

    // Support System
    print('Support System: ${_supportSystem ?? 'Not selected'}');

    // Emergency Contacts
    print(
      '\n📞 Emergency Contacts (${_emergencyContacts.length}/$_maxContacts):',
    );
    if (_emergencyContacts.isEmpty) {
      print('  No emergency contacts added');
    } else {
      for (int i = 0; i < _emergencyContacts.length; i++) {
        final contact = _emergencyContacts[i];
        print('  ${i + 1}. ${contact['name']} - ${contact['number']}');
      }
    }

    // Crisis Resources
    print('\n🆘 Crisis Resources:');
    print('  Enabled: ${_crisisResourcesEnabled ? 'Yes' : 'No'}');
    if (_crisisResourcesEnabled) {
      print('  Available resources:');
      for (final resource in _crisisResources) {
        print('    - ${resource['name']}: ${resource['number']}');
      }
    }

    // Withdrawal Concerns
    print('\n💊 Withdrawal Concerns:');
    print('  Medical Supervision: ${_withdrawalConcern ?? 'Not selected'}');

    // Harm Reduction
    print('\n⚠️ Harm Reduction:');
    print('  Usage Context: ${_usageContext ?? 'Not selected'}');
    print(
      '  Harm Reduction Info Enabled: ${_harmReductionInfo ? 'Yes' : 'No'}',
    );

    print('-------------------------------------------');

    // Update onboardingData with safety setup data
    final finalData = widget.onboardingData.copyWith(
      emergencyContacts: _emergencyContacts,
      supportSystem: _supportSystem,
      withdrawalConcern: _withdrawalConcern,
      usageContext: _usageContext,
      crisisResourcesEnabled: _crisisResourcesEnabled,
      harmReductionInfo: _harmReductionInfo,
    );

    print('\n💾 SAVING SAFETY DATA TO SHARED PREFERENCES...');

    // Save to SharedPreferences for backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safety_setup_complete', true);
    await prefs.setString('support_system', _supportSystem ?? '');

    final contactsJson = _emergencyContacts
        .map((c) => '${c['name']}|${c['number']}')
        .join(',');
    await prefs.setString('emergency_contacts', contactsJson);

    print('  Emergency contacts JSON: $contactsJson');

    await prefs.setBool('crisis_resources_enabled', _crisisResourcesEnabled);
    await prefs.setString('withdrawal_concern', _withdrawalConcern ?? '');
    await prefs.setString('usage_context', _usageContext ?? '');
    await prefs.setBool('harm_reduction_info', _harmReductionInfo);

    print('✅ SAFETY DATA SAVED SUCCESSFULLY');

    // Print complete onboarding data summary
    print('\n📋 COMPLETE ONBOARDING DATA SUMMARY:');
    print('==========================================');
    print('🎯 GOALS & MOTIVATION (Screen 1):');
    print('  Selected Goals: ${finalData.selectedGoals}');
    print('  Timeline: ${finalData.selectedTimeline ?? 'Not set'}');
    print('  Motivation Level: ${finalData.motivationLevel}');
    print('  Primary Reason: ${finalData.primaryReason ?? 'Not set'}');

    print('\n💊 SUBSTANCES (Screen 2):');
    print('  Selected Substances: ${finalData.selectedSubstances}');
    print('  Previous Attempts: ${finalData.substanceAttempts}');

    print('\n📊 USAGE PATTERNS (Screen 3):');
    print('  (Data saved in SharedPreferences per substance)');

    print('\n🛡️ SAFETY SETUP (Screen 4):');
    print('  Support System: ${finalData.supportSystem ?? 'Not set'}');
    print('  Emergency Contacts Count: ${_emergencyContacts.length}');
    if (_emergencyContacts.isNotEmpty) {
      print('  Emergency Contacts List:');
      for (int i = 0; i < _emergencyContacts.length; i++) {
        print(
          '    ${i + 1}. ${_emergencyContacts[i]['name']} - ${_emergencyContacts[i]['number']}',
        );
      }
    }
    print('  Withdrawal Concern: ${finalData.withdrawalConcern ?? 'Not set'}');
    print('  Usage Context: ${finalData.usageContext ?? 'Not set'}');
    print('  Crisis Resources: ${finalData.crisisResourcesEnabled ?? false}');
    print('  Harm Reduction Info: ${finalData.harmReductionInfo ?? false}');
    print('==========================================\n');

    if (mounted) {
      // Navigate to AppPreferencesScreen and pass final data
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AppPreferencesScreen(
            onboardingData: finalData,
            onComplete: widget.onContinue,
          ),
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _handleContinue();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
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
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Safety First',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
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

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFD32F2F)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSupportSystemPage(),
                  _buildEmergencyContactsPage(),
                  _buildCrisisResourcesPage(),
                  _buildWithdrawalConcernsPage(),
                  _buildHarmReductionPage(),
                ],
              ),
            ),

            // Navigation Buttons
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
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: _currentPage == 4 ? 'Complete' : 'Next',
                        onPressed: _nextPage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSystemPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support System',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Do you have someone who supports your goals?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ..._supportOptions.map((option) {
            return _RadioOption(
              value: option,
              groupValue: _supportSystem,
              onChanged: (value) {
                setState(() => _supportSystem = value);
              },
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add up to ${_maxContacts} trusted contacts for tough moments',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Manual Entry Fields
          TextField(
            controller: _contactNameController,
            decoration: InputDecoration(
              labelText: 'Contact name',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.contacts, color: Colors.blue[700]),
                onPressed: _pickContact,
                tooltip: 'Choose from contacts',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactNumberController,
            decoration: InputDecoration(
              labelText: 'Phone number',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Add Contact Button
          if (_emergencyContacts.length < _maxContacts)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addEmergencyContact,
                icon: const Icon(Icons.add),
                label: const Text('Add Contact'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Saved Contacts List
          if (_emergencyContacts.isNotEmpty) ...[
            Text(
              'Saved Contacts (${_emergencyContacts.length}/$_maxContacts)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            ..._emergencyContacts.asMap().entries.map((entry) {
              return _SavedContactItem(
                name: entry.value['name']!,
                number: entry.value['number']!,
                onDelete: () => _removeEmergencyContact(entry.key),
              );
            }).toList(),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'They won\'t be notified. Just quick access when you need support.',
                    style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCrisisResourcesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crisis Resources',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pre-save crisis resources for quick access',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick access from app',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Switch(
                value: _crisisResourcesEnabled,
                onChanged: (value) {
                  setState(() => _crisisResourcesEnabled = value);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_crisisResourcesEnabled)
            ..._crisisResources.map((resource) {
              return _ResourceItem(
                name: resource['name']!,
                number: resource['number']!,
              );
            }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWithdrawalConcernsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Concerns',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you working with a healthcare provider?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ..._withdrawalOptions.map((option) {
            return _RadioOption(
              value: option,
              groupValue: _withdrawalConcern,
              onChanged: (value) {
                setState(() => _withdrawalConcern = value);
              },
            );
          }).toList(),
          if (_withdrawalConcern == 'No, but I should be')
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange[800],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sudden stopping of substances can be dangerous. We recommend consulting a healthcare provider.',
                      style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHarmReductionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Harm Reduction',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Do you use with others or alone?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ..._usageContextOptions.map((option) {
            return _RadioOption(
              value: option,
              groupValue: _usageContext,
              onChanged: (value) {
                setState(() => _usageContext = value);
              },
            );
          }).toList(),
          if (_usageContext == 'Mostly alone') ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Learn about harm reduction practices?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _HarmReductionOption(
              title: 'Naloxone/Narcan info',
              subtitle: 'Learn about overdose reversal',
              value: _harmReductionInfo,
              onChanged: (value) {
                setState(() => _harmReductionInfo = value);
              },
            ),
            const SizedBox(height: 12),
            _HarmReductionOption(
              title: 'Never use alone hotline',
              subtitle: 'Support while using',
              value: _harmReductionInfo,
              onChanged: (value) {
                setState(() => _harmReductionInfo = value);
              },
            ),
            const SizedBox(height: 12),
            _HarmReductionOption(
              title: 'Safer use practices',
              subtitle: 'Reduce risks',
              value: _harmReductionInfo,
              onChanged: (value) {
                setState(() => _harmReductionInfo = value);
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();

    if (status.isGranted) {
      try {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          // Fetch full contact details
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null) {
            setState(() {
              _contactNameController.text = fullContact.displayName;
              if (fullContact.phones.isNotEmpty) {
                _contactNumberController.text = fullContact.phones.first.number;
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to pick contact')),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact permission denied')),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Permission Required'),
        content: const Text(
          'Please enable contact permission in settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _addEmergencyContact() {
    print('\n=== ATTEMPTING TO ADD EMERGENCY CONTACT ===');
    print('Contact Name: "${_contactNameController.text}"');
    print('Contact Number: "${_contactNumberController.text}"');
    print('Current contacts count: ${_emergencyContacts.length}');
    print('Max contacts: $_maxContacts');

    if (_contactNameController.text.trim().isEmpty) {
      print('❌ FAILED: Contact name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name')),
      );
      return;
    }

    if (_emergencyContacts.length >= _maxContacts) {
      print('❌ FAILED: Max contacts reached');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $_maxContacts contacts allowed')),
      );
      return;
    }

    setState(() {
      _emergencyContacts.add({
        'name': _contactNameController.text.trim(),
        'number': _contactNumberController.text.trim(),
      });
      print('✅ SUCCESS: Contact added');
      print('New contacts count: ${_emergencyContacts.length}');
      print('Emergency contacts list: $_emergencyContacts');

      _contactNameController.clear();
      _contactNumberController.clear();
    });

    print('==========================================\n');
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }
}

class _RadioOption extends StatelessWidget {
  final String value;
  final String? groupValue;
  final Function(String?) onChanged;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[300]! : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue[800] : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedContactItem extends StatelessWidget {
  final String name;
  final String number;
  final VoidCallback onDelete;

  const _SavedContactItem({
    required this.name,
    required this.number,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person, color: Colors.green[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (number.isNotEmpty)
                  Text(
                    number,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: Colors.red[400]),
            onPressed: onDelete,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final String name;
  final String number;

  const _ResourceItem({required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, size: 20),
            onPressed: () {
              // Handle phone call
            },
          ),
        ],
      ),
    );
  }
}

class _HarmReductionOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _HarmReductionOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? Colors.green[300]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value ? Colors.green : Colors.grey[400]!,
                  width: 2,
                ),
                color: value ? Colors.green : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: value ? Colors.green[800] : Colors.grey[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: value ? Colors.green[600] : Colors.grey[600],
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
}
