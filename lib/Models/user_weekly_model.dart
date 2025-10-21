import 'package:grounded/models/userdailyentrymodel.dart';

class WeeklyData {
  final String day;
  final DayType dayType;
  final double height;

  WeeklyData({required this.day, required this.dayType, required this.height});
}

// ===============================
// DAILY ENTRY MODEL
// ===============================
class DailyEntry {
  final DateTime date;
  final bool isCompleted;
  final String? notes;
  final DayType dayType;

  DailyEntry({
    required this.date,
    required this.isCompleted,
    this.notes,
    required this.dayType,
  });
}
