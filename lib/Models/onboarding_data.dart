import 'dart:convert';

class OnboardingData {
  // From GoalSetupScreen
  Set<String> selectedGoals;
  String? selectedTimeline;
  DateTime? targetDate;
  int motivationLevel;
  String? primaryReason;
  Set<String>? selectedReasons;

  // From SubstanceSelectionScreen
  Set<String> selectedSubstances;
  Map<String, String> substanceDurations;
  Map<String, String> substanceAttempts; // ADD THIS FIELD

  // From UsagePatternsScreen
  Map<String, dynamic>? usagePatterns;

  // From SafetySetupScreen
  List<Map<String, String>> emergencyContacts;
  String? supportSystem;
  String? withdrawalConcern;
  String? usageContext;
  bool crisisResourcesEnabled;
  bool harmReductionInfo;

  OnboardingData({
    this.selectedGoals = const {},
    this.selectedTimeline,
    this.targetDate,
    this.motivationLevel = 5,
    this.primaryReason,
    this.selectedReasons,
    this.selectedSubstances = const {},
    this.substanceDurations = const {},
    this.substanceAttempts = const {}, // ADD THIS PARAMETER
    this.usagePatterns,
    this.emergencyContacts = const [],
    this.supportSystem,
    this.withdrawalConcern,
    this.usageContext,
    this.crisisResourcesEnabled = true,
    this.harmReductionInfo = false,
  });

  // Convert to JSON for database
  Map<String, dynamic> toJson() {
    return {
      'goals': selectedGoals.toList(),
      'timeline': selectedTimeline,
      'target_date': targetDate?.toIso8601String(),
      'motivation_level': motivationLevel,
      'primary_reason': primaryReason,
      'selected_reasons': selectedReasons?.toList(),
      'substances': selectedSubstances.toList(),
      'substance_durations': substanceDurations,
      'substance_attempts': substanceAttempts, // ADD THIS LINE
      'usage_patterns': usagePatterns,
      'emergency_contacts': emergencyContacts,
      'support_system': supportSystem,
      'withdrawal_concern': withdrawalConcern,
      'usage_context': usageContext,
      'crisis_resources_enabled': crisisResourcesEnabled,
      'harm_reduction_info': harmReductionInfo,
      'completed_at': DateTime.now().toIso8601String(),
    };
  }

  // Copy with method for updating
  OnboardingData copyWith({
    Set<String>? selectedGoals,
    String? selectedTimeline,
    DateTime? targetDate,
    int? motivationLevel,
    String? primaryReason,
    Set<String>? selectedReasons,
    Set<String>? selectedSubstances,
    Map<String, String>? substanceDurations,
    Map<String, String>? substanceAttempts, // ADD THIS PARAMETER
    Map<String, dynamic>? usagePatterns,
    List<Map<String, String>>? emergencyContacts,
    String? supportSystem,
    String? withdrawalConcern,
    String? usageContext,
    bool? crisisResourcesEnabled,
    bool? harmReductionInfo,
  }) {
    return OnboardingData(
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedTimeline: selectedTimeline ?? this.selectedTimeline,
      targetDate: targetDate ?? this.targetDate,
      motivationLevel: motivationLevel ?? this.motivationLevel,
      primaryReason: primaryReason ?? this.primaryReason,
      selectedReasons: selectedReasons ?? this.selectedReasons,
      selectedSubstances: selectedSubstances ?? this.selectedSubstances,
      substanceDurations: substanceDurations ?? this.substanceDurations,
      substanceAttempts:
          substanceAttempts ?? this.substanceAttempts, // ADD THIS LINE
      usagePatterns: usagePatterns ?? this.usagePatterns,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      supportSystem: supportSystem ?? this.supportSystem,
      withdrawalConcern: withdrawalConcern ?? this.withdrawalConcern,
      usageContext: usageContext ?? this.usageContext,
      crisisResourcesEnabled:
          crisisResourcesEnabled ?? this.crisisResourcesEnabled,
      harmReductionInfo: harmReductionInfo ?? this.harmReductionInfo,
    );
  }

  factory OnboardingData.fromJson(Map<String, dynamic> map) {
    return OnboardingData(
      selectedGoals: Set<String>.from(map['goals'] ?? []),
      selectedTimeline: map['timeline'],
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      motivationLevel: map['motivation_level'] ?? 5,
      primaryReason: map['primary_reason'],
      selectedReasons: map['selected_reasons'] != null
          ? Set<String>.from(map['selected_reasons'])
          : null,
      selectedSubstances: Set<String>.from(map['substances'] ?? []),
      substanceDurations: Map<String, String>.from(
        map['substance_durations'] ?? {},
      ),
      substanceAttempts: _parseSubstanceAttempts(map), // Use helper function
      usagePatterns: map['usage_patterns'],
      emergencyContacts: List<Map<String, String>>.from(
        map['emergency_contacts'] ?? [],
      ),
      supportSystem: map['support_system'],
      withdrawalConcern: map['withdrawal_concern'],
      usageContext: map['usage_context'],
      crisisResourcesEnabled: map['crisis_resources_enabled'] ?? true,
      harmReductionInfo: map['harm_reduction_info'] ?? false,
    );
  }

  // Helper function to parse substance attempts
  static Map<String, String> _parseSubstanceAttempts(Map<String, dynamic> map) {
    // Try to get from new field first
    if (map['substance_attempts'] != null) {
      return Map<String, String>.from(map['substance_attempts']);
    }
    // Fallback to old field for backward compatibility
    if (map['previous_attempts'] != null) {
      // If it's a string, try to parse it as JSON, otherwise return empty map
      if (map['previous_attempts'] is String) {
        try {
          return Map<String, String>.from(jsonDecode(map['previous_attempts']));
        } catch (e) {
          return {};
        }
      }
    }
    return {};
  }
}
