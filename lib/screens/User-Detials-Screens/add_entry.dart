// Add Entry Screen
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart'; // Add to pubspec.yaml: shimmer: ^3.0.0
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Grounded/providers/userDB.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Map<String, List<String>> _consumptionMethodsCache = {};
  bool _isLoadingFromDb = true;
  int _currentStep = 0;
  List<String> _userSubstances = [];
  bool _isLoading = true;
  int _moodAfter = 5;
  List<String> _additionalSubstancesToday =
      []; // Track additional substances used today

  // Form data
  String? _selectedDayType;
  String _timeOfDay = '';
  String? _selectedSubstance;
  final TextEditingController _amountController = TextEditingController();
  String _selectedUnit = 'drinks';
  final TextEditingController _costController = TextEditingController();
  String? _selectedContext;
  String? _selectedSocial;
  int _moodBefore = 5;
  int _cravingLevel = 5;
  List<String> _selectedTriggers = [];
  final TextEditingController _notesController = TextEditingController();

  // Smart preset data from database
  Map<String, bool> _expandedSections = {};

  Map<String, dynamic> _presetData = {};
  bool _useLastCost = false;
  bool _useCommonTriggers = false;
  bool _useTypicalContext = false;
  List<String> _suggestedTriggers = [];
  String? _suggestedContext;
  String? _suggestedSocial;
  double? _lastCost;
  int? _averageMood;
  int? _averageCraving;

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
    _detectTimeOfDay();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _amountController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSmartPresets(String userId) async {
    print('🧠 Loading smart presets from database...');

    final userDb = UserDatabaseService();

    try {
      // Get last 30 days of logs
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final logs = await userDb.getLogsForRange(userId, startDate, endDate);

      if (logs.isNotEmpty) {
        // Analyze patterns
        _analyzePatterns(logs);

        // Get substance-specific patterns
        if (_selectedSubstance != null) {
          await _loadSubstanceSpecificPresets(userId, _selectedSubstance!);
        }
      }
    } catch (e) {
      print('Error loading smart presets: $e');
    }
  }

  Future<void> _loadSubstanceSpecificPresets(
    String userId,
    String substance,
  ) async {
    final userDb = UserDatabaseService();
    final patterns = await userDb.getSubstancePatterns(userId);

    final substancePattern = patterns.firstWhere(
      (p) => p['substance_name'] == substance,
      orElse: () => {},
    );

    if (substancePattern.isNotEmpty) {
      setState(() {
        _suggestedContext = substancePattern['context'] as String?;
        // FIX: Use social_context field properly
        _suggestedSocial = substancePattern['social_context'] as String?;

        final typicalAmounts = substancePattern['typical_amounts'] as Map?;
        if (typicalAmounts != null && typicalAmounts.isNotEmpty) {
          final firstAmount = typicalAmounts.values.first;
          _amountController.text = firstAmount.toString();
        }

        final costPerUse = substancePattern['cost_per_use'];
        if (costPerUse != null) {
          _lastCost = (costPerUse is int
              ? costPerUse.toDouble()
              : costPerUse as double);
          if (_useLastCost) {
            _costController.text = _lastCost!.toStringAsFixed(2);
          }
        }
      });
    }
  }

  // Analyze user patterns from logs
  void _analyzePatterns(List<Map<String, dynamic>> logs) {
    Map<String, int> triggerFrequency = {};
    Map<String, int> contextFrequency = {};
    Map<String, int> socialFrequency = {};
    List<double> costs = [];
    List<int> moods = [];
    List<int> cravings = [];

    for (final log in logs) {
      // Count triggers
      final triggers = log['triggers_experienced'] as List?;
      if (triggers != null) {
        for (final trigger in triggers) {
          triggerFrequency[trigger.toString()] =
              (triggerFrequency[trigger.toString()] ?? 0) + 1;
        }
      }

      // Track cost
      final cost = log['cost_spent'];
      if (cost != null) {
        costs.add((cost is int ? cost.toDouble() : cost as double));
      }

      // Track mood
      final mood = log['mood_rating'];
      if (mood != null) {
        moods.add(mood as int);
      }

      // Note: We'd need to add these fields to daily_logs table
      // For now, using placeholder logic
    }

    // Find most common triggers (top 3)
    final sortedTriggers = triggerFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _suggestedTriggers = sortedTriggers.take(3).map((e) => e.key).toList();

      // Calculate averages
      if (costs.isNotEmpty) {
        _lastCost = costs.last;
      }

      if (moods.isNotEmpty) {
        _averageMood = (moods.reduce((a, b) => a + b) / moods.length).round();
      }

      if (cravings.isNotEmpty) {
        _averageCraving = (cravings.reduce((a, b) => a + b) / cravings.length)
            .round();
      }
    });

    print('✅ Smart presets loaded:');
    print('  - Suggested triggers: $_suggestedTriggers');
    print('  - Last cost: \$$_lastCost');
    print('  - Average mood: $_averageMood/10');
  }

  Future<void> _loadOnboardingData() async {
    setState(() {
      _isLoadingFromDb = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        // Load from database
        await _loadFromDatabase(userId);

        // Load smart presets
        await _loadSmartPresets(userId);
      } else {
        // Fallback to SharedPreferences
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      print('Error loading data: $e');
      await _loadFromSharedPreferences();
    } finally {
      setState(() {
        _isLoadingFromDb = false;
        _isLoading = false;
      });
    }
  }

  Widget _buildShimmerLoading(AppThemeMode themeMode) {
    final cardColor = AppColors.getCardColor(themeMode);

    return Shimmer.fromColors(
      baseColor: AppColors.getBorderColor(themeMode).withOpacity(0.3),
      highlightColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              3,
              (index) => Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromDatabase(String userId) async {
    print('📥 Loading substances from database...');

    final userDb = UserDatabaseService();

    // Get onboarding data
    final onboardingData = await userDb.getOnboardingData(userId);

    if (onboardingData != null) {
      // Extract substances from onboarding data
      final substances = List<String>.from(
        onboardingData['selected_substances'] ?? [],
      );

      // Get substance patterns with consumption methods
      final patterns = await userDb.getSubstancePatterns(userId);

      setState(() {
        _userSubstances = substances;

        // Cache consumption methods for each substance
        for (final pattern in patterns) {
          final substanceName = pattern['substance_name'] as String;
          final methods = List<String>.from(
            pattern['consumption_methods'] ?? [],
          );
          if (methods.isNotEmpty) {
            _consumptionMethodsCache[substanceName] = methods;
          }
        }

        // Auto-select first substance
        if (_userSubstances.isNotEmpty) {
          _selectedSubstance = _userSubstances.first;
          _loadConsumptionMethodsFromCache(_selectedSubstance!);
        }

        // Set intelligent defaults based on goals
        final goals = List<String>.from(onboardingData['selected_goals'] ?? []);
        if (goals.contains('Complete abstinence')) {
          _selectedDayType = 'mindful';
        }
      });

      print('✅ Loaded ${_userSubstances.length} substances from database');
    } else {
      // No database data, try SharedPreferences
      await _loadFromSharedPreferences();
    }
  }

  // Fallback: Load from SharedPreferences
  Future<void> _loadFromSharedPreferences() async {
    print('📥 Loading substances from SharedPreferences...');

    final prefs = await SharedPreferences.getInstance();

    // Try user_substances first
    final substances = prefs.getStringList('user_substances') ?? [];

    if (substances.isEmpty) {
      // Fallback to onboarding_data
      final substancesJson = prefs.getString('onboarding_data');
      if (substancesJson != null) {
        final data = json.decode(substancesJson);
        final onboardingSubstances = List<String>.from(
          data['substances'] ?? [],
        );

        setState(() {
          _userSubstances = List.from(onboardingSubstances);
        });
      } else {
        // Final fallback
        setState(() {
          _userSubstances = ['Alcohol'];
        });
      }
    } else {
      setState(() {
        _userSubstances = substances;
      });
    }

    // Load consumption methods from SharedPreferences
    for (final substance in _userSubstances) {
      final methods = prefs.getStringList('${substance}_consumptionMethods');
      if (methods != null && methods.isNotEmpty) {
        _consumptionMethodsCache[substance] = methods;
      }
    }

    // Auto-select first substance
    if (_userSubstances.isNotEmpty) {
      _selectedSubstance = _userSubstances.first;
      _loadConsumptionMethodsFromCache(_selectedSubstance!);
    }

    print(
      '✅ Loaded ${_userSubstances.length} substances from SharedPreferences',
    );
  }

  // Load consumption methods from cache
  void _loadConsumptionMethodsFromCache(String substance) {
    if (_consumptionMethodsCache.containsKey(substance)) {
      final methods = _consumptionMethodsCache[substance]!;
      final unitOptions = _getUnitOptions();

      // Try to match saved method with available options
      for (final method in methods) {
        final methodLower = method.toLowerCase();
        if (unitOptions.containsKey(methodLower)) {
          setState(() {
            _selectedUnit = methodLower;
          });
          return;
        }
      }
    }

    // Default to first option
    final unitOptions = _getUnitOptions();
    setState(() {
      _selectedUnit = unitOptions.keys.first;
    });
  }

  void _detectTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      _timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      _timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      _timeOfDay = 'evening';
    } else {
      _timeOfDay = 'night';
    }
  }

  String _getTimeOfDayEmoji() {
    switch (_timeOfDay) {
      case 'morning':
        return EmojiAssets.sunrise;
      case 'afternoon':
        return EmojiAssets.day;
      case 'evening':
        return EmojiAssets.evening;
      case 'night':
        return EmojiAssets.night;
      default:
        return '🕐';
    }
  }

  Map<String, String> _getUnitOptions() {
    if (_selectedSubstance == null) return {'units': 'units'};

    final substance = _selectedSubstance!.toLowerCase();

    if (substance.contains('alcohol')) {
      return {
        'drinks': 'drinks',
        'shots': 'shots',
        'beers': 'beers',
        'glasses': 'glasses',
        'bottles': 'bottles',
      };
    } else if (substance.contains('cannabis') ||
        substance.contains('marijuana')) {
      return {
        'joints': 'joints',
        'grams': 'grams',
        'bowls': 'bowls',
        'hits': 'hits',
        'mg': 'mg',
      };
    } else if (substance.contains('tobacco') ||
        substance.contains('cigarette')) {
      return {'cigarettes': 'cigs', 'packs': 'packs'};
    } else if (substance.contains('vaping') || substance.contains('vape')) {
      return {'puffs': 'puffs', 'ml': 'ml', 'sessions': 'sessions'};
    } else if (substance.contains('caffeine') || substance.contains('coffee')) {
      return {'cups': 'cups', 'shots': 'shots', 'cans': 'cans', 'mg': 'mg'};
    } else if (substance.contains('cocaine') ||
        substance.contains('stimulant')) {
      return {'lines': 'lines', 'grams': 'grams', 'mg': 'mg'};
    } else if (substance.contains('pill') ||
        substance.contains('prescription') ||
        substance.contains('medication')) {
      return {'pills': 'pills', 'tablets': 'tablets', 'mg': 'mg'};
    } else {
      return {'units': 'units', 'doses': 'doses', 'grams': 'grams', 'mg': 'mg'};
    }
  }

  Future<void> _saveEntry() async {
    // Only validate essential fields
    if (_selectedDayType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select day type')));
      return;
    }

    // Only require substance if NOT mindful
    if (_selectedDayType != 'mindful' && _selectedSubstance == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select substance')));
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to save entries')),
        );
        return;
      }

      // Prepare entry data
      // In _saveEntry method, update the entryData map:
      final entryData = {
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'day_type': _selectedDayType,
        'time_of_day': _timeOfDay,
        'substance_name': _selectedSubstance,
        'amount': _amountController.text.isNotEmpty
            ? double.tryParse(_amountController.text)
            : null,
        'unit': _amountController.text.isNotEmpty ? _selectedUnit : null,
        'cost_spent': _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null,
        'context': _selectedContext,
        'social_context': _selectedSocial,
        'mood_rating': _moodBefore,
        'mood_after': _selectedDayType == 'used'
            ? _moodAfter
            : null, // Add this
        'craving_level': _cravingLevel,
        'triggers_experienced':
            _selectedDayType == 'used' && _selectedTriggers.isNotEmpty
            ? _selectedTriggers
            : null,
        'notes': _selectedDayType == 'used' && _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      };

      // Save primary entry to database
      await Supabase.instance.client.from('daily_logs').insert(entryData);

      // Save additional substances if any
      if (_additionalSubstancesToday.isNotEmpty) {
        for (final addSubstance in _additionalSubstancesToday) {
          final additionalEntry = {
            'user_id': userId,
            'timestamp': DateTime.now().toIso8601String(),
            'day_type': _selectedDayType,
            'time_of_day': _timeOfDay,
            'substance_name': addSubstance,
            'amount': null,
            'unit': null,
            'cost_spent': null,
            'context': _selectedContext,
            'social_context': _selectedSocial,
            'mood_rating': _moodBefore,
            'craving_level': _cravingLevel,
            'triggers_experienced': _selectedTriggers.isEmpty
                ? null
                : _selectedTriggers,
            'notes': 'Additional substance',
          };

          await Supabase.instance.client
              .from('daily_logs')
              .insert(additionalEntry);
        }
      }

      if (mounted) {
        HapticFeedback.mediumImpact();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _selectedDayType == 'mindful'
                      ? '✨ Mindful day logged!'
                      : '✅ Entry saved successfully!',
                ),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving entry: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save entry: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      // Changed from 2 to 1
      HapticFeedback.lightImpact();
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final bgColor = AppColors.getBackgroundColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);

    if (_isLoadingFromDb) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(themeMode),
                    _buildProgressIndicator(themeMode),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _buildShimmerLoading(themeMode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildEntrySheet(themeMode),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntrySheet(AppThemeMode themeMode) {
    final bgColor = AppColors.getBackgroundColor(themeMode); // Add this line

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(themeMode),
          _buildProgressIndicator(themeMode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(themeMode),
            ),
          ),
          _buildActionButtons(themeMode),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getTimeOfDayEmoji(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Entry',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: textColor),
                ),
                Text(
                  '${_timeOfDay.substring(0, 1).toUpperCase()}${_timeOfDay.substring(1)} • ${_getFormattedTime()}',
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AppThemeMode themeMode) {
    final borderColor = AppColors.getBorderColor(themeMode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(2, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isCurrent
                    ? AppColors.primaryGreen
                    : borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
  // Widget _buildCurrentStep() {
  //   switch (_currentStep) {
  //     case 0:
  //       return _buildStep1Essential();
  //     case 1:
  //       return _buildStep2Details();
  //     case 2:
  //       return _buildStep3Context();
  //     default:
  //       return Container();
  //   }
  // }

  Widget _buildQuickCheckIn(AppThemeMode themeMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick check-in', style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: 8),
        Text(
          'Just the essentials',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.getTextSecondaryColor(themeMode)),
        ),
        const SizedBox(height: 24),
        Text(
          'How did it go today?',
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildDayTypeSelector(themeMode),
        if (_selectedDayType != 'mindful') ...[
          const SizedBox(height: 24),
          _buildPrimarySubstanceDisplay(themeMode),
          const SizedBox(height: 24),
          _buildQuickAmountInput(themeMode),
          const SizedBox(height: 32),
          _buildTodaysAddition(themeMode),
        ],
      ],
    );
  }

  Widget _buildPrimarySubstanceDisplay(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode); // Add this

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary substance',
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeMode == AppThemeMode.amoled
                ? cardColor
                : AppColors.primaryGreen.withOpacity(0.1), // Update this
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getSubstanceEmoji(_selectedSubstance ?? ''),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedSubstance ?? 'Not set',
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (_consumptionMethodsCache.containsKey(
                          _selectedSubstance,
                        ) &&
                        _consumptionMethodsCache[_selectedSubstance]!
                            .isNotEmpty)
                      Text(
                        'Methods: ${_consumptionMethodsCache[_selectedSubstance]!.take(2).join(', ')}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.primaryGreen.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. _buildQuickAmountInput
  Widget _buildQuickAmountInput(AppThemeMode themeMode) {
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    final unitOptions = _getUnitOptions();
    if (!unitOptions.containsKey(_selectedUnit)) {
      _selectedUnit = unitOptions.keys.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Amount',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDayType == 'reduced'
                  ? '(slide to reduce from typical)'
                  : '(optional)',
              style: AppTextStyles.caption(
                context,
              ).copyWith(color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show slider for "reduced" if typical amount exists
        if (_selectedDayType == 'reduced' && _amountController.text.isNotEmpty)
          _buildReducedAmountSlider(themeMode)
        else
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., 2',
                    hintStyle: TextStyle(color: textSecondary),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _getUnitOptions().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodySmall(
                          context,
                        ).copyWith(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedUnit = value);
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReducedAmountSlider(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    final typicalAmount = double.tryParse(_amountController.text) ?? 5.0;
    final currentAmount =
        double.tryParse(_amountController.text) ?? typicalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Typical: ${typicalAmount.toStringAsFixed(0)} $_selectedUnit',
              style: AppTextStyles.caption(
                context,
              ).copyWith(color: textSecondary),
            ),
            Text(
              'Today: ${currentAmount.toStringAsFixed(1)} $_selectedUnit',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: currentAmount,
          min: 0,
          max: typicalAmount,
          divisions: (typicalAmount * 2).toInt(),
          activeColor: AppColors.accentOrange,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() {
              _amountController.text = value.toStringAsFixed(1);
            });
          },
        ),
        Text(
          currentAmount < typicalAmount
              ? '📉 ${((1 - currentAmount / typicalAmount) * 100).toStringAsFixed(0)}% reduction from typical'
              : '✅ At typical amount',
          style: AppTextStyles.caption(context).copyWith(
            color: currentAmount < typicalAmount
                ? AppColors.successGreen
                : textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartPresetsCard(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.secondaryGreen.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Suggestions',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on your recent entries',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: textSecondary),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_lastCost != null)
                _buildPresetChip(
                  themeMode,
                  icon: Icons.attach_money,
                  label: 'Same cost (\$${_lastCost!.toStringAsFixed(2)})',
                  isActive: _useLastCost,
                  onTap: () {
                    setState(() {
                      _useLastCost = !_useLastCost;
                      if (_useLastCost) {
                        _costController.text = _lastCost!.toStringAsFixed(2);
                      } else {
                        _costController.clear();
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                ),

              if (_suggestedTriggers.isNotEmpty)
                _buildPresetChip(
                  themeMode,
                  icon: Icons.psychology,
                  label: 'Common triggers (${_suggestedTriggers.length})',
                  isActive: _useCommonTriggers,
                  onTap: () {
                    setState(() {
                      _useCommonTriggers = !_useCommonTriggers;
                      if (_useCommonTriggers) {
                        _selectedTriggers = List.from(_suggestedTriggers);
                      } else {
                        _selectedTriggers.clear();
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                ),

              if (_suggestedContext != null)
                _buildPresetChip(
                  themeMode,
                  icon: Icons.location_on,
                  label: 'Typical place',
                  isActive: _useTypicalContext,
                  onTap: () {
                    setState(() {
                      _useTypicalContext = !_useTypicalContext;
                      _selectedContext = _useTypicalContext
                          ? _suggestedContext
                          : null;
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    AppThemeMode themeMode, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : cardColor,
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : borderColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: isActive ? Colors.white : textColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  // Smart Mood Slider with Average Indicator
  Widget _buildSmartMoodSlider(
    AppThemeMode themeMode, {
    String label = 'Mood before',
    bool isMoodAfter = false,
  }) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final currentMood = isMoodAfter ? _moodAfter : _moodBefore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, color: textColor),
                ),
                if (_averageMood != null && !isMoodAfter) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 10,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Avg: $_averageMood',
                          style: AppTextStyles.caption(context).copyWith(
                            fontSize: 10,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '$currentMood/10',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Slider(
              value: currentMood.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.primaryGreen,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isMoodAfter) {
                    _moodAfter = value.toInt();
                  } else {
                    _moodBefore = value.toInt();
                  }
                });
              },
            ),
            if (_averageMood != null && !isMoodAfter)
              Positioned(
                left:
                    ((_averageMood! - 1) / 9) *
                    (MediaQuery.of(context).size.width - 80),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
          ],
        ),
        if (_averageMood != null && !isMoodAfter)
          Text(
            'Your average mood: $_averageMood/10',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: textSecondary),
          ),
      ],
    );
  }

  // Smart Context Selector with Suggestions
  Widget _buildSmartContextSelector(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    final contexts = [
      'Home',
      'Work',
      'Bar',
      'Party',
      "Friend's place",
      'Other',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Where?',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: textColor),
            ),
            if (_suggestedContext != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 10,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Usually: $_suggestedContext',
                      style: AppTextStyles.caption(
                        context,
                      ).copyWith(fontSize: 10, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: contexts.map((locationContext) {
            final isSelected = _selectedContext == locationContext;
            final isSuggested = _suggestedContext == locationContext;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedContext = locationContext);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : isSuggested
                      ? AppColors.primaryGreen.withOpacity(0.05)
                      : cardColor,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : isSuggested
                        ? AppColors.primaryGreen.withOpacity(0.3)
                        : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSuggested && !isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    Text(
                      locationContext,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : isSuggested
                            ? AppColors.primaryGreen.withOpacity(0.8)
                            : textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Smart Triggers Selector
  Widget _buildSmartTriggersSelector(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    final allTriggers = [
      'Stress',
      'Celebration',
      'Boredom',
      'Social pressure',
      'Habit',
      'Anxiety',
      'Tired',
      'Happy',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Triggers?',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: textColor),
            ),
            if (_suggestedTriggers.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_suggestedTriggers.length} common',
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: 10, color: AppColors.accentOrange),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTriggers.map((trigger) {
            final isSelected = _selectedTriggers.contains(trigger);
            final isSuggested = _suggestedTriggers.contains(trigger);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedTriggers.remove(trigger);
                  } else {
                    _selectedTriggers.add(trigger);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentOrange.withOpacity(0.1)
                      : isSuggested
                      ? AppColors.accentOrange.withOpacity(0.05)
                      : cardColor,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentOrange
                        : isSuggested
                        ? AppColors.accentOrange.withOpacity(0.3)
                        : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSuggested && !isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    Text(
                      trigger,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isSelected
                            ? AppColors.accentOrange
                            : isSuggested
                            ? AppColors.accentOrange.withOpacity(0.8)
                            : textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Smart Cost Input
  Widget _buildSmartCostInput(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cost (optional)',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: textColor),
            ),
            if (_lastCost != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Last: \$${_lastCost!.toStringAsFixed(2)}',
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(fontSize: 10, color: AppColors.primaryGreen),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _costController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: _lastCost != null
                ? '\$${_lastCost!.toStringAsFixed(2)}'
                : '\$0.00',
            hintStyle: TextStyle(color: textSecondary),
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: textColor),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            suffixIcon: _lastCost != null
                ? IconButton(
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    onPressed: () {
                      _costController.text = _lastCost!.toStringAsFixed(2);
                      HapticFeedback.lightImpact();
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // Smart Social Selector
  Widget _buildSmartSocialSelector(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    final socials = ['Alone', 'Friends', 'Partner', 'Group'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who with?',
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: socials.map((social) {
            final isSelected = _selectedSocial == social;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedSocial = social);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : cardColor,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : borderColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  social,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: isSelected ? AppColors.primaryGreen : textColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // NEW: Expandable section widget
  Widget _buildExpandableSection(
    AppThemeMode themeMode, {
    required String title,
    required Widget child,
    bool hasSmartData = false,
  }) {
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    final isExpanded = _expandedSections[title] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(
          color: hasSmartData
              ? AppColors.primaryGreen.withOpacity(0.3)
              : borderColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (hasSmartData) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildDayTypeSelector(AppThemeMode themeMode) {
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    final types = [
      {
        'id': 'mindful',
        'label': 'Mindful',
        'emoji': '✨',
        'color': AppColors.successGreen,
      },
      {
        'id': 'reduced',
        'label': 'Reduced',
        'emoji': '📉',
        'color': AppColors.accentOrange,
      },
      {
        'id': 'used',
        'label': 'Used',
        'emoji': '📊',
        'color': AppColors.secondaryGreen,
      },
    ];

    return Column(
      children: types.map((type) {
        final isSelected = _selectedDayType == type['id'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDayType = type['id'] as String);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (type['color'] as Color).withOpacity(0.1)
                    : cardColor,
                border: Border.all(
                  color: isSelected ? (type['color'] as Color) : borderColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    type['emoji'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    type['label'] as String,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodaysAddition(AppThemeMode themeMode) {
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    final additionalFromOnboarding = _userSubstances.length > 1
        ? _userSubstances.sublist(1)
        : <String>[];

    final primaryLower = _selectedSubstance?.toLowerCase() ?? '';
    List<String> smartSuggestions = [];

    if (primaryLower.contains('alcohol')) {
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('cigarette'),
      )) {
        smartSuggestions.add('Cigarettes');
      }
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('cannabis'),
      )) {
        smartSuggestions.add('Cannabis');
      }
    } else if (primaryLower.contains('cannabis')) {
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('cigarette'),
      )) {
        smartSuggestions.add('Cigarettes');
      }
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('alcohol'),
      )) {
        smartSuggestions.add('Alcohol');
      }
    } else if (primaryLower.contains('cigarette') ||
        primaryLower.contains('tobacco')) {
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('alcohol'),
      )) {
        smartSuggestions.add('Alcohol');
      }
      if (!additionalFromOnboarding.any(
        (s) => s.toLowerCase().contains('cannabis'),
      )) {
        smartSuggestions.add('Cannabis');
      }
    }

    final allAdditional = [
      ...additionalFromOnboarding,
      ...smartSuggestions,
    ].toSet().toList();

    if (allAdditional.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's addition",
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(width: 8),
            Text(
              '(if any)',
              style: AppTextStyles.caption(
                context,
              ).copyWith(color: textSecondary.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Did you also use any of these today?',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: textSecondary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allAdditional.map((substance) {
            final isSelected = _additionalSubstancesToday.contains(substance);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _additionalSubstancesToday.remove(substance);
                  } else {
                    _additionalSubstancesToday.add(substance);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentOrange.withOpacity(0.1)
                      : cardColor.withOpacity(0.5),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentOrange
                        : borderColor.withOpacity(0.5),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSubstanceEmoji(substance),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      substance,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.accentOrange
                            : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // AI-powered pattern insights widget
  Widget _buildPatternInsights(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);

    if (_suggestedTriggers.isEmpty &&
        _lastCost == null &&
        _averageMood == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentOrange.withOpacity(0.1),
            AppColors.accentOrange.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.accentOrange,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pattern Insights',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_suggestedTriggers.isNotEmpty) ...[
            _buildInsightRow(
              themeMode,
              icon: Icons.psychology,
              text:
                  'Your most common triggers: ${_suggestedTriggers.take(2).join(", ")}',
            ),
            const SizedBox(height: 8),
          ],

          if (_lastCost != null) ...[
            _buildInsightRow(
              themeMode,
              icon: Icons.trending_up,
              text:
                  'Your average spend: \$${_lastCost!.toStringAsFixed(2)} per session',
            ),
            const SizedBox(height: 8),
          ],

          if (_averageMood != null)
            _buildInsightRow(
              themeMode,
              icon: Icons.emoji_emotions,
              text: 'Your typical mood before use: $_averageMood/10',
            ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    AppThemeMode themeMode, {
    required IconData icon,
    required String text,
  }) {
    final textColor = AppColors.getTextPrimaryColor(
      themeMode,
    ); // Update this line

    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accentOrange.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: textColor), // Use textColor
          ),
        ),
      ],
    );
  }

  // Quick fill all button
  Widget _buildQuickFillButton(AppThemeMode themeMode) {
    if (_suggestedTriggers.isEmpty && _lastCost == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            if (_lastCost != null) {
              _costController.text = _lastCost!.toStringAsFixed(2);
              _useLastCost = true;
            }

            if (_suggestedTriggers.isNotEmpty) {
              _selectedTriggers = List.from(_suggestedTriggers);
              _useCommonTriggers = true;
            }

            if (_suggestedContext != null) {
              _selectedContext = _suggestedContext;
              _useTypicalContext = true;
            }

            if (_averageMood != null) {
              _moodBefore = _averageMood!;
            }

            if (_averageCraving != null) {
              _cravingLevel = _averageCraving!;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Smart fields filled!'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.auto_fix_high, size: 18),
        label: const Text('Quick Fill with Smart Data'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartCravingSlider(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Craving level',
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, color: textColor),
                ),
                if (_averageCraving != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 10,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Avg: $_averageCraving',
                          style: AppTextStyles.caption(context).copyWith(
                            fontSize: 10,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '$_cravingLevel/10',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Slider(
              value: _cravingLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.accentOrange,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _cravingLevel = value.toInt());
              },
            ),
            if (_averageCraving != null)
              Positioned(
                left:
                    ((_averageCraving! - 1) / 9) *
                    (MediaQuery.of(context).size.width - 80),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: AppColors.accentOrange.withOpacity(0.3),
                ),
              ),
          ],
        ),
        if (_averageCraving != null)
          Text(
            'Your average craving: $_averageCraving/10',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: textSecondary),
          ),
      ],
    );
  }

  // Updated Optional Details with insights
  Widget _buildOptionalDetailsWithInsights(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Add more details',
              style: AppTextStyles.headlineSmall(
                context,
              ).copyWith(color: textColor),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'OPTIONAL',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'These help track patterns over time',
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: textSecondary),
        ),
        const SizedBox(height: 16),

        _buildPatternInsights(themeMode),
        _buildQuickFillButton(themeMode),

        if (_suggestedTriggers.isNotEmpty || _lastCost != null)
          _buildSmartPresetsCard(themeMode),

        const SizedBox(height: 24),

        // Mood & Cravings - Show for both "used" and "reduced"
        _buildExpandableSection(
          themeMode,
          title: _selectedDayType == 'used'
              ? 'Mood & Cravings (Before & After)'
              : 'Mood & Cravings',
          hasSmartData: _averageMood != null || _averageCraving != null,
          child: Column(
            children: [
              _buildSmartMoodSlider(themeMode, label: 'Mood before'),
              const SizedBox(height: 16),
              _buildSmartCravingSlider(themeMode),
              // Add "Mood after" for "used" day type
              if (_selectedDayType == 'used') ...[
                const SizedBox(height: 16),
                _buildSmartMoodSlider(
                  themeMode,
                  label: 'Mood after',
                  isMoodAfter: true,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildExpandableSection(
          themeMode,
          title: 'Context',
          hasSmartData: _suggestedContext != null,
          child: Column(
            children: [
              _buildSmartContextSelector(themeMode),
              const SizedBox(height: 16),
              _buildSmartSocialSelector(themeMode),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Only show Triggers & Notes for "used" day type
        if (_selectedDayType == 'used')
          _buildExpandableSection(
            themeMode,
            title: 'Triggers & Notes',
            hasSmartData: _suggestedTriggers.isNotEmpty,
            child: Column(
              children: [
                _buildSmartTriggersSelector(themeMode),
                const SizedBox(height: 16),
                _buildNotesInput(themeMode),
              ],
            ),
          ),

        if (_selectedDayType == 'used') const SizedBox(height: 16),

        if (_selectedDayType != 'mindful')
          _buildExpandableSection(
            themeMode,
            title: 'Cost',
            hasSmartData: _lastCost != null,
            child: _buildSmartCostInput(themeMode),
          ),
      ],
    );
  }

  // Update the _buildCurrentStep to use new insights version
  Widget _buildCurrentStep(AppThemeMode themeMode) {
    switch (_currentStep) {
      case 0:
        return _buildQuickCheckIn(themeMode);
      case 1:
        // Skip optional details for mindful days
        if (_selectedDayType == 'mindful') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✨ Mindful Day',
                style: AppTextStyles.headlineSmall(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Great choice! No additional details needed for mindful days.',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: AppColors.getTextSecondaryColor(themeMode)),
              ),
            ],
          );
        }
        return _buildOptionalDetailsWithInsights(themeMode);
      default:
        return Container();
    }
  }

  // Enhanced notes input with AI suggestions
  Widget _buildNotesInput(AppThemeMode themeMode) {
    final textColor = AppColors.getTextPrimaryColor(themeMode);
    final textSecondary = AppColors.getTextSecondaryColor(themeMode);
    final cardColor = AppColors.getCardColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);

    final commonNotes = [
      'Felt stressed',
      'Had a good day',
      'Social event',
      'Celebrating',
      'Needed to relax',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Quick templates:',
          style: AppTextStyles.caption(context).copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: commonNotes.map((note) {
            return GestureDetector(
              onTap: () {
                _notesController.text = note;
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  note,
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(color: textColor),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'How are you feeling? Any thoughts?',
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  // Stats preview at bottom (optional - shows impact of current entry)

  Widget _buildActionButtons(AppThemeMode themeMode) {
    final bgColor = AppColors.getBackgroundColor(themeMode);
    final borderColor = AppColors.getBorderColor(themeMode);
    final textColor = AppColors.getTextPrimaryColor(themeMode);

    final canSkip = _currentStep == 1;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: borderColor),
                ),
                child: Text(
                  'Back',
                  style: AppTextStyles.buttonMedium(
                    context,
                  ).copyWith(color: textColor),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          if (canSkip)
            Expanded(
              child: OutlinedButton(
                onPressed: _saveEntry,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primaryGreen),
                ),
                child: Text(
                  'Skip',
                  style: AppTextStyles.buttonMedium(
                    context,
                  ).copyWith(color: AppColors.primaryGreen),
                ),
              ),
            ),
          if (canSkip) const SizedBox(width: 12),
          Expanded(
            flex: canSkip ? 1 : 2,
            child: ElevatedButton(
              onPressed: _currentStep < 1 ? _nextStep : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < 1 ? 'Continue' : 'Save Entry',
                style: AppTextStyles.buttonMedium(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubstanceEmoji(String substance) {
    final lower = substance.toLowerCase();
    if (lower.contains('alcohol')) return '🍺';
    if (lower.contains('cannabis') || lower.contains('marijuana')) return '🌿';
    if (lower.contains('cigarette') || lower.contains('tobacco')) return '🚬';
    if (lower.contains('vaping') || lower.contains('vape')) return '💨';
    if (lower.contains('caffeine') || lower.contains('coffee')) return '☕';
    if (lower.contains('cocaine')) return '❄️';
    if (lower.contains('pill') || lower.contains('prescription')) return '💊';
    return '📦';
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${now.minute.toString().padLeft(2, '0')} $period';
  }
}
