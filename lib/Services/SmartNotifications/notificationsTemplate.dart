import 'package:Grounded/Services/SmartNotifications/notifications_context_based.dart';

/// Helper class for structured notification content
class NotificationTemplate {
  final String title;
  final String body;
  final String? actionText;
  final String? actionKey;
  final int layer; // 1-7 for insight model layers
  final String category; // emotional, predictive, supportive, etc.
  final Map<String, dynamic>? variables; // For string interpolation

  const NotificationTemplate({
    required this.title,
    required this.body,
    this.actionText,
    this.actionKey,
    required this.layer,
    required this.category,
    this.variables,
  });

  /// Replace variables in template with actual values
  String getBody(Map<String, dynamic> data) {
    String result = body;
    data.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }

  String getTitle(Map<String, dynamic> data) {
    String result = title;
    data.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}

/// Message selector based on onboarding data and context
class NotificationSelector {
  /// Get appropriate message based on trigger and time
  static String getMessage({
    required String category,
    required String subcategory,
    Map<String, dynamic>? variables,
    int? index,
  }) {
    final messages = _getMessageList(category, subcategory);
    if (messages.isEmpty) return '';

    // ✅ FIX: Create a mutable copy before shuffling
    final String message;
    if (index != null) {
      // Use specific index
      message = messages[index % messages.length];
    } else {
      // Random selection - create mutable copy first
      final mutableMessages = List<String>.from(messages);
      mutableMessages.shuffle();
      message = mutableMessages.first;
    }

    // Replace variables if provided
    if (variables != null) {
      return _replaceVariables(message, variables);
    }

    return message;
  }

  static List<String> _getMessageList(String category, String subcategory) {
    switch (category) {
      case 'descriptive':
        return NotificationMessages.descriptive[subcategory] ?? [];
      case 'contextual':
        return NotificationMessages.contextual[subcategory] ?? [];
      case 'emotional':
        return NotificationMessages.emotional[subcategory] ?? [];
      case 'interpretive':
        return NotificationMessages.interpretive[subcategory] ?? [];
      case 'predictive':
        return NotificationMessages.predictive[subcategory] ?? [];
      case 'supportive':
        return NotificationMessages.supportive[subcategory] ?? [];
      case 'reflective':
        return NotificationMessages.reflective[subcategory] ?? [];
      case 'positive':
        return NotificationMessages.positiveReinforcement[subcategory] ?? [];
      case 'goal':
        return NotificationMessages.goalBased[subcategory] ?? [];
      case 'time':
        return NotificationMessages.timeContextual[subcategory] ?? [];
      case 'data':
        return NotificationMessages.dataDriven[subcategory] ?? [];
      case 'educational':
        return NotificationMessages.educational[subcategory] ?? [];
      case 'celebration':
        return NotificationMessages.celebrations[subcategory] ?? [];
      case 'crisis':
        return NotificationMessages.crisis[subcategory] ?? [];
      default:
        return [];
    }
  }

  static String _replaceVariables(
    String message,
    Map<String, dynamic> variables,
  ) {
    String result = message;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
