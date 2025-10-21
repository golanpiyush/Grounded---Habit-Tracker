class OnboardingData {
  // From GoalSetupScreen
  Set<String> selectedGoals;
  String? selectedTimeline;
  DateTime? targetDate; // Add this field
  int motivationLevel;
  String? primaryReason; // for single reason
  Set<String>? selectedReasons; // for multiple reason

  // From SubstanceSelectionScreen
  Set<String> selectedSubstances;
  Map<String, String> substanceDurations;
  String? previousAttempts;

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
    this.targetDate, // Add this parameter
    this.motivationLevel = 5,
    this.primaryReason,
    this.selectedReasons,
    this.selectedSubstances = const {},
    this.substanceDurations = const {},
    this.previousAttempts,
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
      'target_date': targetDate?.toIso8601String(), // Add this line
      'motivation_level': motivationLevel,
      'primary_reason': primaryReason,
      'selected_reasons': selectedReasons?.toList(),
      'substances': selectedSubstances.toList(),
      'substance_durations': substanceDurations,
      'previous_attempts': previousAttempts,
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
    DateTime? targetDate, // Add this parameter
    int? motivationLevel,
    String? primaryReason,
    Set<String>? selectedReasons,
    Set<String>? selectedSubstances,
    Map<String, String>? substanceDurations,
    String? previousAttempts,
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
      targetDate: targetDate ?? this.targetDate, // Add this line
      motivationLevel: motivationLevel ?? this.motivationLevel,
      primaryReason: primaryReason ?? this.primaryReason,
      selectedReasons: selectedReasons ?? this.selectedReasons,
      selectedSubstances: selectedSubstances ?? this.selectedSubstances,
      substanceDurations: substanceDurations ?? this.substanceDurations,
      previousAttempts: previousAttempts ?? this.previousAttempts,
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
}
