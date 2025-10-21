// ===============================
// USER ENTRY MODEL
// ===============================
enum DayType { mindful, reduced, used }

class UserEntry {
  final DateTime timestamp;
  final String dayType; // 'mindful', 'reduced', 'used'
  final String timeOfDay; // 'morning', 'afternoon', 'evening', 'night'
  final String? substance;
  final double? amount;
  final String? unit;
  final double? cost;
  final String? context; // 'home', 'work', 'bar', 'party', 'friends'
  final String? social; // 'alone', 'friends', 'partner', 'group'
  final int? moodBefore; // 1-10
  final int? cravingLevel; // 1-10
  final List<String>? triggers;
  final String? notes;

  UserEntry({
    required this.timestamp,
    required this.dayType,
    required this.timeOfDay,
    this.substance,
    this.amount,
    this.unit,
    this.cost,
    this.context,
    this.social,
    this.moodBefore,
    this.cravingLevel,
    this.triggers,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'dayType': dayType,
    'timeOfDay': timeOfDay,
    'substance': substance,
    'amount': amount,
    'unit': unit,
    'cost': cost,
    'context': context,
    'social': social,
    'moodBefore': moodBefore,
    'cravingLevel': cravingLevel,
    'triggers': triggers,
    'notes': notes,
  };
}
