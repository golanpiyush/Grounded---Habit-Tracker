// usage_patterns_screen.dart
import 'package:flutter/material.dart';
import 'package:Grounded/models/onboarding_data.dart';
import 'package:Grounded/screens/auth/safety_setup_screen.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_button.dart';

class UsagePatternsScreen extends StatefulWidget {
  final List<String> selectedSubstances;
  final VoidCallback onContinue;
  final OnboardingData onboardingData;

  const UsagePatternsScreen({
    Key? key,
    required this.selectedSubstances,
    required this.onContinue,
    required this.onboardingData,
  }) : super(key: key);

  @override
  State<UsagePatternsScreen> createState() => _UsagePatternsScreenState();
}

class _UsagePatternsScreenState extends State<UsagePatternsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Map<String, Map<String, dynamic>> _substancePatterns = {};
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final Map<String, GlobalKey<_AnimatedMethodInputState>> _methodInputKeys = {};
  late AnimationController _animationController;

  int _currentSubstanceIndex = 0;

  final Map<String, List<String>> _frequencyOptions = {
    'Alcohol': [
      'Daily',
      '3-4 times/week',
      'Weekends',
      'Social occasions',
      'Rarely',
    ],
    'Cannabis': [
      'Daily',
      'Multiple times/day',
      'Evenings',
      'Weekends',
      'Occasionally',
    ],
    'Tobacco': [
      'Daily',
      'Multiple packs/day',
      'Social smoking',
      'With coffee',
      'When stressed',
    ],
    'Caffeine': [
      'Daily',
      'Multiple cups/day',
      'Mornings only',
      'Throughout day',
      'As needed',
    ],
    'Vaping': [
      'Daily',
      'Constantly',
      'Social situations',
      'When bored',
      'Occasionally',
    ],
    'Prescription': [
      'As prescribed',
      'More than prescribed',
      'As needed',
      'Daily',
      'Occasionally',
    ],
    'Other': ['Daily', 'Weekly', 'Monthly', 'Socially', 'Rarely'],
  };

  final Map<String, List<String>> _consumptionMethods = {
    'Alcohol': [
      'Beers',
      'Whiskey',
      'Glasses of wine',
      'Shots',
      'Cocktails',
      'Bottles',
      'Pints',
      'Cans',
      'Liters',
      'Sips',
    ],
    'Cannabis': [
      'Joints',
      'Bong hits',
      'Edibles',
      'Vape sessions',
      'Dabs',
      'Grams',
      'Bowls',
      'Blunts',
      'Pipes',
      'Drops (tincture)',
      'Capsules',
    ],
    'Tobacco': [
      'Cigarettes',
      'Cigars',
      'Packs',
      'Rolling tobacco',
      'Pipe bowls',
      'Pouches',
      'Snuff (nasal)',
      'Chewing tobacco',
    ],
    'Caffeine': [
      'Cups of coffee',
      'Energy drinks',
      'Sodas',
      'Tea cups',
      'Espresso shots',
      'Cans',
      'Cold brews',
      'Preworkout scoops',
    ],
    'Vaping': [
      'Puffs',
      'Sessions',
      'Pods',
      'Cartridges',
      'mL of liquid',
      'Hits',
      'Disposable vapes',
      'Refill bottles',
    ],
    'Prescription': [
      'Pills',
      'Tablets',
      'Capsules',
      'mL',
      'Doses',
      'Patches (transdermal)',
      'Injections',
      'Drops (liquid)',
      'Nasal sprays',
    ],
    'Cocaine': [
      'Lines',
      'Grams',
      'Bumps',
      'Sessions',
      'Hits',
      'Rocks (crack)',
      'Injections',
    ],
    'Heroin': [
      'Bags',
      'Grams',
      'Injections',
      'Hits',
      'Sessions',
      'Lines (snorted)',
      'Smoked hits',
    ],
    'Fentanyl': [
      'Patches (skin)',
      'Pills',
      'Micrograms',
      'Doses',
      'Hits',
      'Lollipops (oral)',
      'Nasal sprays',
    ],
    'Meth': [
      'Hits',
      'Grams',
      'Bowls',
      'Lines',
      'Sessions',
      'Pipes',
      'Injections',
    ],
    'MDMA': [
      'Pills',
      'Points (0.1g)',
      'Grams',
      'Caps',
      'Doses',
      'Crystals',
      'Powder (oral)',
      'Liquids',
    ],
    'LSD': [
      'Tabs (blotters)',
      'Hits',
      'Drops (sublingual)',
      'Micrograms',
      'Doses',
      'Gel tabs',
      'Sugar cubes',
      'Mouth patches (films)',
      'Microdots',
    ],
    'Psilocybin': [
      'Grams (dried)',
      'Caps',
      'Chocolates',
      'Doses',
      'Mushrooms (whole)',
      'Tea (brewed)',
      'Lemon tek (liquid)',
    ],
    'Ketamine': [
      'Lines',
      'Bumps',
      'Grams',
      'mg',
      'Sessions',
      'Injections (IM/IV)',
      'Nasal sprays',
      'Lozenges',
    ],
    'Benzos': [
      'Pills',
      'Tablets',
      'mg',
      'Doses',
      'Bars',
      'Capsules',
      'Drops (liquid)',
    ],
    'Opioids': [
      'Pills',
      'Tablets',
      'mg',
      'Patches',
      'Doses',
      'Syrups',
      'Injections',
      'Lozenges',
    ],
    'Amphetamines': [
      'Pills',
      'Capsules',
      'mg',
      'Lines',
      'Doses',
      'Powder',
      'Injections',
    ],
    'Sugar': [
      'Desserts',
      'Candies',
      'Sodas',
      'Cookies',
      'Pieces',
      'Servings',
      'Cups',
      'Teaspoons',
    ],
    'Other': [
      'Units',
      'Doses',
      'Sessions',
      'Times',
      'Grams',
      'mg',
      'Applications',
    ],
  };

  final Map<String, List<String>> _contextOptions = {
    'Alcohol': [
      'Alone at home',
      'Social events',
      'After work',
      'With meals',
      'To sleep',
    ],
    'Cannabis': [
      'Alone relaxing',
      'Socially',
      'For creativity',
      'For pain',
      'Before bed',
    ],
    'Tobacco': [
      'With coffee',
      'After meals',
      'When stressed',
      'Socially',
      'On breaks',
    ],
    'Caffeine': [
      'Morning wake-up',
      'Work focus',
      'Afternoon slump',
      'Socially',
      'Pre-workout',
    ],
    'Other': ['When stressed', 'Socially', 'For fun', 'To relax', 'When bored'],
  };

  final List<String> _triggerOptions = [
    'Stress/anxiety',
    'Social situations',
    'Boredom',
    'After work',
    'Celebrations',
    'Loneliness',
    'Physical pain',
    'Habit/routine',
    'Emotional pain',
    'Peer pressure',
  ];

  final List<String> _impactOptions = [
    'Sleep problems',
    'Financial strain',
    'Relationship issues',
    'Work performance',
    'Physical health',
    'Mental health',
    'Motivation/energy',
    'No major issues yet',
  ];

  final List<String> _timeOfDayOptions = [
    'Morning (6am-12pm)',
    'Afternoon (12pm-6pm)',
    'Evening (6pm-10pm)',
    'Night (10pm-6am)',
    'Throughout the day',
    'Varies',
  ];

  String _selectedCurrency = '\$'; // Defaults to USD

  final Map<String, String> _currencySymbols = {
    '\$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₹': 'INR',
    '₦': 'NGN',
    '₩': 'KRW',
    '₪': 'ILS',
    '₱': 'PHP',
    '₿': 'BTC',
    // Add more currencies as needed
  };

  @override
  void initState() {
    super.initState();
    _initializePatterns();

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

  void _initializePatterns() {
    for (final substance in widget.selectedSubstances) {
      _substancePatterns[substance] = {
        'frequency': '',
        'context': '',
        'consumptionMethod': <String>[], // Changed to list
        'typicalAmount':
            <String, String>{}, // Changed to map for multiple amounts
        'costPerUse': '',
        'triggers': <String>[],
        'impacts': <String>[],
        'timeOfDay': '',
      };
    }
  }

  void _updateMethodAmount(String substance, String method, String amount) {
    setState(() {
      final Map<String, String> amounts = Map<String, String>.from(
        _substancePatterns[substance]!['typicalAmount'] ?? {},
      );
      amounts[method] = amount;
      _substancePatterns[substance]!['typicalAmount'] = amounts;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _amountController.dispose();
    _costController.dispose();
    super.dispose();
  }

  List<String> _getFrequencyOptions(String substance) {
    return _frequencyOptions[substance] ?? _frequencyOptions['Other']!;
  }

  List<String> _getContextOptions(String substance) {
    return _contextOptions[substance] ?? _contextOptions['Other']!;
  }

  void _updatePattern(String substance, String key, dynamic value) {
    setState(() {
      _substancePatterns[substance]![key] = value;
    });
  }

  void _toggleMultiSelect(String substance, String key, String value) {
    setState(() {
      final List<String> currentList = List<String>.from(
        _substancePatterns[substance]![key] ?? [],
      );
      if (currentList.contains(value)) {
        currentList.remove(value);
      } else {
        currentList.add(value);
      }
      _substancePatterns[substance]![key] = currentList;
    });
  }

  void _nextPage() {
    // Validate current page before allowing navigation
    if (!_isPageValid(_currentPage)) {
      // Show snackbar with specific message based on current page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getValidationMessage(_currentPage),
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.primaryButtonColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
          duration: const Duration(seconds: 3),
        ),
      );
      return; // Don't proceed if current page is invalid
    }

    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(
          milliseconds: 400,
        ), // Increased duration for smoother animation
        curve: Curves.easeInOutCubic, // Better curve for smoother feel
      );
    } else {
      _nextSubstance();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _nextSubstance() {
    if (_currentSubstanceIndex < widget.selectedSubstances.length - 1) {
      setState(() {
        _currentSubstanceIndex++;
        _currentPage = 0;
        _costController.text = _currentPatterns['costPerUse'] ?? '';
        _pageController.jumpToPage(0);
      });
    } else {
      _handleContinue();
    }
  }

  // Update _previousSubstance similarly
  void _previousSubstance() {
    if (_currentSubstanceIndex > 0) {
      setState(() {
        _currentSubstanceIndex--;
        _currentPage = 0;
        _costController.text = _currentPatterns['costPerUse'] ?? '';
        _pageController.jumpToPage(0);
      });
    }
  }

  Future<void> _handleContinue() async {
    // PRINT ALL SUBSTANCE DATA BEFORE SAVING AND NAVIGATION
    print('=== NAVIGATING TO SAFETY SETUP SCREEN ===');
    print('Total Substances: ${widget.selectedSubstances.length}');
    print('==========================================\n');

    for (final entry in _substancePatterns.entries) {
      final substance = entry.key;
      final patterns = entry.value;

      print('📊 SUBSTANCE: $substance');
      print('-------------------------------------------');
      print('Frequency: ${patterns['frequency'] ?? 'Not set'}');
      print('Context: ${patterns['context'] ?? 'Not set'}');

      // Consumption Methods
      final methods = List<String>.from(patterns['consumptionMethod'] ?? []);
      print(
        'Consumption Methods: ${methods.isEmpty ? 'None selected' : methods.join(', ')}',
      );

      // Typical Amounts
      final amounts = Map<String, String>.from(patterns['typicalAmount'] ?? {});
      if (amounts.isEmpty) {
        print('Typical Amounts: None entered');
      } else {
        print('Typical Amounts:');
        amounts.forEach((method, amount) {
          print('  - $method: $amount');
        });
      }

      print(
        'Cost Per Use: ${patterns['costPerUse']?.isEmpty ?? true ? 'Not entered' : '$_selectedCurrency${patterns['costPerUse']}'}',
      );

      // Triggers
      final triggers = List<String>.from(patterns['triggers'] ?? []);
      print(
        'Triggers: ${triggers.isEmpty ? 'None selected' : triggers.join(', ')}',
      );

      // Impacts
      final impacts = List<String>.from(patterns['impacts'] ?? []);
      print(
        'Life Impacts: ${impacts.isEmpty ? 'None selected' : impacts.join(', ')}',
      );

      print('Time of Day: ${patterns['timeOfDay'] ?? 'Not set'}');
      print('-------------------------------------------\n');
    }

    print('💾 SAVING DATA TO SHARED PREFERENCES...');
    final prefs = await SharedPreferences.getInstance();

    for (final entry in _substancePatterns.entries) {
      final substance = entry.key;
      final patterns = entry.value;

      await prefs.setString(
        '${substance}_frequency',
        patterns['frequency'] ?? '',
      );
      await prefs.setString('${substance}_context', patterns['context'] ?? '');
      await prefs.setStringList(
        '${substance}_consumptionMethods',
        List<String>.from(patterns['consumptionMethod'] ?? []),
      );

      // Save amounts as JSON string
      final amounts = Map<String, String>.from(patterns['typicalAmount'] ?? {});
      final amountsJson = amounts.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|');
      await prefs.setString('${substance}_typicalAmounts', amountsJson);

      await prefs.setString(
        '${substance}_costPerUse',
        patterns['costPerUse'] ?? '',
      );
      await prefs.setStringList(
        '${substance}_triggers',
        List<String>.from(patterns['triggers'] ?? []),
      );
      await prefs.setStringList(
        '${substance}_impacts',
        List<String>.from(patterns['impacts'] ?? []),
      );
      await prefs.setString(
        '${substance}_timeOfDay',
        patterns['timeOfDay'] ?? '',
      );
    }

    print('✅ DATA SAVED SUCCESSFULLY');
    print('\n📋 ONBOARDING DATA SUMMARY:');
    print('Selected Goals: ${widget.onboardingData.selectedGoals}');
    print('Timeline: ${widget.onboardingData.selectedTimeline}');
    print('Motivation Level: ${widget.onboardingData.motivationLevel}');
    print('Primary Reason: ${widget.onboardingData.primaryReason}');
    print('Selected Substances: ${widget.onboardingData.selectedSubstances}');
    print('Previous Attempts: ${widget.onboardingData.previousAttempts}');
    print('==========================================\n');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SafetySetupScreen(
            onboardingData: widget.onboardingData,
            onContinue: widget.onContinue,
          ),
        ),
      );
    }
  }

  String get _currentSubstance =>
      widget.selectedSubstances[_currentSubstanceIndex];
  Map<String, dynamic> get _currentPatterns =>
      _substancePatterns[_currentSubstance]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Progress Header
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Substance ${_currentSubstanceIndex + 1} of ${widget.selectedSubstances.length}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D5016),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentSubstance,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPageTitle(_currentPage),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value:
                          (_currentSubstanceIndex + 1) /
                          widget.selectedSubstances.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  // Changed from 6 to 4
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Changed to prevent manual swiping
                children: [
                  _buildFrequencyPage(),
                  _buildAmountPage(),
                  _buildTriggersPage(),
                  _buildImpactAndTimePage(),
                ],
              ),
            ),

            // Navigation Buttons
            // Replace the Navigation Buttons section in your build method
            // Starting from line ~520 (the Container with navigation buttons)

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
                    if (_currentPage > 0 || _currentSubstanceIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentPage > 0
                              ? _previousPage
                              : _previousSubstance,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentPage > 0 ? 'Back' : 'Previous Substance',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    if (_currentPage > 0 || _currentSubstanceIndex > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: _currentPage == 3
                            ? (_currentSubstanceIndex ==
                                      widget.selectedSubstances.length - 1
                                  ? 'Complete'
                                  : 'Next Substance')
                            : 'Next',
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

  Widget _buildFrequencyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How often?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your typical frequency',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getFrequencyOptions(_currentSubstance).map((option) {
              final isSelected = _currentPatterns['frequency'] == option;
              return _PatternChip(
                text: option,
                isSelected: isSelected,
                onTap: () =>
                    _updatePattern(_currentSubstance, 'frequency', option),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'AND',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'When do you typically use?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the most common context',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getContextOptions(_currentSubstance).map((option) {
              final isSelected = _currentPatterns['context'] == option;
              return _PatternChip(
                text: option,
                isSelected: isSelected,
                onTap: () =>
                    _updatePattern(_currentSubstance, 'context', option),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<String> _getConsumptionMethods(String substance) {
    return _consumptionMethods[substance] ?? _consumptionMethods['Other']!;
  }

  Widget _buildAmountPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Typical amount?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How do you consume it? (Select all that apply)',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Consumption method selection - now multi-select
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getConsumptionMethods(_currentSubstance).map((method) {
              final isSelected = List<String>.from(
                _currentPatterns['consumptionMethod'] ?? [],
              ).contains(method);
              return _MultiSelectChip(
                text: method,
                isSelected: isSelected,
                onTap: () => _toggleMultiSelect(
                  _currentSubstance,
                  'consumptionMethod',
                  method,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Amount inputs - show for each selected method with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                List<String>.from(
                  _currentPatterns['consumptionMethod'] ?? [],
                ).isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How many of each?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Animated list of input fields
                      ...List<String>.from(
                        _currentPatterns['consumptionMethod'] ?? [],
                      ).map((method) {
                        final Map<String, String> amounts =
                            Map<String, String>.from(
                              _currentPatterns['typicalAmount'] ?? {},
                            );
                        final currentAmount = amounts[method] ?? '';

                        // Create a unique key for each method input
                        final keyString = '${_currentSubstance}_$method';
                        if (!_methodInputKeys.containsKey(keyString)) {
                          _methodInputKeys[keyString] =
                              GlobalKey<_AnimatedMethodInputState>();
                        }

                        return _AnimatedMethodInput(
                          key: _methodInputKeys[keyString],
                          method: method,
                          currentAmount: currentAmount,
                          onChanged: (value) => _updateMethodAmount(
                            _currentSubstance,
                            method,
                            value,
                          ),
                          getPluralizedMethod: _getPluralizedMethod,
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'AND',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Cost per use?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Helps track money saved (Optional)',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tappable currency icon
                GestureDetector(
                  onTap: _showCurrencyPicker,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _selectedCurrency, // <-- show actual currency symbol here
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _costController,
                    onChanged: (value) =>
                        _updatePattern(_currentSubstance, 'costPerUse', value),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      prefixText: '$_selectedCurrency ',
                      prefixStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We\'ll calculate your savings as you track progress',
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

  // Add this method to show currency picker
  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Divider(color: Colors.grey[300], height: 1),
              SizedBox(
                height: 300,
                child: ListView(
                  children: _currencySymbols.entries.map((entry) {
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedCurrency == entry.key
                              ? Colors.green[50]
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _selectedCurrency == entry.key
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      subtitle: Text(
                        'Currency: ${entry.key}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      trailing: _selectedCurrency == entry.key
                          ? Icon(Icons.check_circle, color: Colors.green[500])
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCurrency = entry.key;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTriggersPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What triggers your use?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _triggerOptions.map((option) {
              final isSelected = List<String>.from(
                _currentPatterns['triggers'] ?? [],
              ).contains(option);
              return _MultiSelectChip(
                text: option,
                isSelected: isSelected,
                onTap: () =>
                    _toggleMultiSelect(_currentSubstance, 'triggers', option),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImpactAndTimePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impact & Timing',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How does it affect you?',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Text(
            'Life impacts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _impactOptions.map((option) {
              final isSelected = List<String>.from(
                _currentPatterns['impacts'] ?? [],
              ).contains(option);
              return _MultiSelectChip(
                text: option,
                isSelected: isSelected,
                onTap: () =>
                    _toggleMultiSelect(_currentSubstance, 'impacts', option),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'Time of day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _timeOfDayOptions.map((option) {
              final isSelected = _currentPatterns['timeOfDay'] == option;
              return _PatternChip(
                text: option,
                isSelected: isSelected,
                onTap: () =>
                    _updatePattern(_currentSubstance, 'timeOfDay', option),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Update _getPageTitle method:
  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'Frequency & Context';
      case 1:
        return 'Amount & Cost';
      case 2:
        return 'Triggers';
      case 3:
        return 'Impact & Time';
      default:
        return '';
    }
  }

  String _getValidationMessage(int page) {
    switch (page) {
      case 0:
        if (_currentPatterns['frequency'].toString().isEmpty) {
          return 'Please select how often you use $_currentSubstance';
        }
        return 'Please select when you typically use $_currentSubstance';
      case 1:
        if (List<String>.from(
          _currentPatterns['consumptionMethod'] ?? [],
        ).isEmpty) {
          return 'Please select at least one consumption method';
        }
        return 'Please enter amounts for all selected methods';
      case 2:
        return 'Please select at least one trigger';
      case 3:
        if (List<String>.from(_currentPatterns['impacts'] ?? []).isEmpty) {
          return 'Please select at least one life impact';
        }
        return 'Please select what time of day you typically use';
      default:
        return 'Please complete all required fields';
    }
  }

  bool _isPageValid(int page) {
    switch (page) {
      case 0: // Frequency & Context
        return _currentPatterns['frequency'].toString().isNotEmpty &&
            _currentPatterns['context'].toString().isNotEmpty;
      case 1: // Amount & Cost
        final methods = List<String>.from(
          _currentPatterns['consumptionMethod'] ?? [],
        );
        if (methods.isEmpty) return false;

        // Check if all selected methods have amounts entered
        final amounts = Map<String, String>.from(
          _currentPatterns['typicalAmount'] ?? {},
        );
        for (final method in methods) {
          if (amounts[method]?.isEmpty ?? true) {
            return false;
          }
        }
        return true;
      case 2: // Triggers
        return List<String>.from(_currentPatterns['triggers'] ?? []).isNotEmpty;
      case 3: // Impact & Time
        return List<String>.from(
              _currentPatterns['impacts'] ?? [],
            ).isNotEmpty &&
            _currentPatterns['timeOfDay'].toString().isNotEmpty;
      default:
        return false;
    }
  }

  String _getPluralizedMethod(String method, String amount) {
    if (amount.isEmpty) {
      return method;
    }

    // Parse the amount to check if it's 1
    final numAmount = double.tryParse(amount) ?? 0;

    // If amount is 1, return singular form
    if (numAmount == 1 || numAmount == 1.0) {
      // Define singular forms for methods that need them
      final singularRules = {
        'Beers': 'Beer',
        'Glasses of wine': 'Glass of wine',
        'Shots': 'Shot',
        'Cocktails': 'Cocktail',
        'Bottles': 'Bottle',
        'Pints': 'Pint',
        'Cans': 'Can',
        'Joints': 'Joint',
        'Bong hits': 'Bong hit',
        'Edibles': 'Edible',
        'Vape sessions': 'Vape session',
        'Dabs': 'Dab',
        'Grams': 'Gram',
        'Bowls': 'Bowl',
        'Cigarettes': 'Cigarette',
        'Cigars': 'Cigar',
        'Packs': 'Pack',
        'Pipe bowls': 'Pipe bowl',
        'Pouches': 'Pouch',
        'Cups of coffee': 'Cup of coffee',
        'Energy drinks': 'Energy drink',
        'Sodas': 'Soda',
        'Tea cups': 'Tea cup',
        'Espresso shots': 'Espresso shot',
        'Puffs': 'Puff',
        'Sessions': 'Session',
        'Pods': 'Pod',
        'Cartridges': 'Cartridge',
        'Hits': 'Hit',
        'Pills': 'Pill',
        'Tablets': 'Tablet',
        'Capsules': 'Capsule',
        'Doses': 'Dose',
        'Patches': 'Patch',
        'Lines': 'Line',
        'Bumps': 'Bump',
        'Injections': 'Injection',
        'Bags': 'Bag',
        'Micrograms': 'Microgram',
        'Points (0.1g)': 'Point (0.1g)',
        'Caps': 'Cap',
        'Tabs': 'Tab',
        'Drops': 'Drop',
        'Mushrooms': 'Mushroom',
        'Bars': 'Bar',
        'Desserts': 'Dessert',
        'Candies': 'Candy',
        'Cookies': 'Cookie',
        'Pieces': 'Piece',
        'Servings': 'Serving',
        'Units': 'Unit',
        'Times': 'Time',
      };

      return singularRules[method] ?? method;
    }

    // For amounts greater than 1, return the plural form (which is already the default)
    return method;
  }
}

// Add this new widget class at the bottom of the file, after _MultiSelectChipState
class _AnimatedMethodInput extends StatefulWidget {
  final String method;
  final String currentAmount;
  final ValueChanged<String> onChanged;
  final String Function(String, String) getPluralizedMethod;

  const _AnimatedMethodInput({
    Key? key,
    required this.method,
    required this.currentAmount,
    required this.onChanged,
    required this.getPluralizedMethod,
  }) : super(key: key);

  @override
  State<_AnimatedMethodInput> createState() => _AnimatedMethodInputState();
}

class _AnimatedMethodInputState extends State<_AnimatedMethodInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: widget.currentAmount)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: widget.currentAmount.length),
                          ),
                    onChanged: widget.onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.getPluralizedMethod(
                      widget.method,
                      widget.currentAmount,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternChip extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatternChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PatternChip> createState() => _PatternChipState();
}

class _PatternChipState extends State<_PatternChip> {
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
          color: widget.isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF4CAF50)
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

class _MultiSelectChip extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _MultiSelectChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MultiSelectChip> createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<_MultiSelectChip> {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color(0xFF4CAF50)
              : Colors.white, // Changed to green
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF4CAF50) // Changed to green
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.isSelected ? Colors.white : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Color(0xFF4CAF50),
                    ) // Changed to green
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
