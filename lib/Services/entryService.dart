import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EntryService {
  static const String _entriesKey = 'user_entries';
  static const String _substancesKey = 'user_substances';

  // Save a new entry
  static Future<bool> saveEntry(Map<String, dynamic> entryData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = await getAllEntries();

      entries.add(entryData);

      // Convert to JSON strings
      final jsonList = entries.map((e) => json.encode(e)).toList();

      return await prefs.setStringList(_entriesKey, jsonList);
    } catch (e) {
      print('Error saving entry: $e');
      return false;
    }
  }

  // Get all entries
  static Future<List<Map<String, dynamic>>> getAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_entriesKey) ?? [];

      return jsonList.map((jsonStr) {
        return json.decode(jsonStr) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error getting entries: $e');
      return [];
    }
  }

  // Get entries for today
  static Future<List<Map<String, dynamic>>> getTodayEntries() async {
    final allEntries = await getAllEntries();
    final today = DateTime.now();

    return allEntries.where((entry) {
      final timestamp = DateTime.parse(entry['timestamp'] as String);
      return timestamp.year == today.year &&
          timestamp.month == today.month &&
          timestamp.day == today.day;
    }).toList();
  }

  // Get entries for a specific date range
  static Future<List<Map<String, dynamic>>> getEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEntries = await getAllEntries();

    return allEntries.where((entry) {
      final timestamp = DateTime.parse(entry['timestamp'] as String);
      return timestamp.isAfter(start) && timestamp.isBefore(end);
    }).toList();
  }

  // Get entries for last 7 days
  static Future<List<Map<String, dynamic>>> getWeeklyEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getEntriesInRange(weekAgo, now);
  }

  // Get entries for current month
  static Future<List<Map<String, dynamic>>> getMonthlyEntries() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return getEntriesInRange(firstDay, lastDay);
  }

  // Calculate current streak (mindful days)
  static Future<int> calculateCurrentStreak() async {
    final allEntries = await getAllEntries();
    if (allEntries.isEmpty) return 0;

    // Sort by date descending
    allEntries.sort((a, b) {
      final dateA = DateTime.parse(a['timestamp'] as String);
      final dateB = DateTime.parse(b['timestamp'] as String);
      return dateB.compareTo(dateA);
    });

    int streak = 0;
    DateTime? lastDate;

    for (var entry in allEntries) {
      final entryDate = DateTime.parse(entry['timestamp'] as String);
      final dayType = entry['dayType'] as String;

      // Check if it's a mindful day
      if (dayType == 'mindful') {
        if (lastDate == null) {
          streak = 1;
          lastDate = entryDate;
        } else {
          // Check if it's consecutive
          final diff = lastDate.difference(entryDate).inDays;
          if (diff <= 1) {
            streak++;
            lastDate = entryDate;
          } else {
            break;
          }
        }
      } else {
        // Streak broken
        break;
      }
    }

    return streak;
  }

  // Calculate money saved
  static Future<double> calculateMoneySaved() async {
    final allEntries = await getAllEntries();
    double total = 0.0;

    for (var entry in allEntries) {
      if (entry['dayType'] == 'mindful' || entry['dayType'] == 'reduced') {
        // Assume user would have spent their average cost
        // This is a simplified calculation
        final cost = entry['cost'];
        if (cost != null) {
          total += (cost is double
              ? cost
              : double.tryParse(cost.toString()) ?? 0.0);
        }
      }
    }

    return total;
  }

  // Calculate weekly average
  static Future<double> calculateWeeklyAverage() async {
    final weeklyEntries = await getWeeklyEntries();
    if (weeklyEntries.isEmpty) return 0.0;

    // Group by day
    final Map<String, int> dayCount = {};

    for (var entry in weeklyEntries) {
      final date = DateTime.parse(entry['timestamp'] as String);
      final key = '${date.year}-${date.month}-${date.day}';
      dayCount[key] = (dayCount[key] ?? 0) + 1;
    }

    final totalDays = dayCount.length;
    final totalEntries = weeklyEntries.length;

    return totalDays > 0 ? totalEntries / totalDays : 0.0;
  }

  // Get user substances
  static Future<List<String>> getUserSubstances() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_substancesKey) ?? [];
  }

  // Set user substances
  static Future<bool> setUserSubstances(List<String> substances) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(_substancesKey, substances);
  }

  // Add a substance
  static Future<bool> addSubstance(String substance) async {
    final substances = await getUserSubstances();
    if (!substances.contains(substance)) {
      substances.add(substance);
      return await setUserSubstances(substances);
    }
    return true;
  }

  // Remove a substance
  static Future<bool> removeSubstance(String substance) async {
    final substances = await getUserSubstances();
    substances.remove(substance);
    return await setUserSubstances(substances);
  }

  // Delete an entry
  static Future<bool> deleteEntry(String timestamp) async {
    try {
      final allEntries = await getAllEntries();
      allEntries.removeWhere((entry) => entry['timestamp'] == timestamp);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = allEntries.map((e) => json.encode(e)).toList();

      return await prefs.setStringList(_entriesKey, jsonList);
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    }
  }

  // Update an entry
  static Future<bool> updateEntry(
    String timestamp,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final allEntries = await getAllEntries();
      final index = allEntries.indexWhere((e) => e['timestamp'] == timestamp);

      if (index != -1) {
        allEntries[index] = updatedData;

        final prefs = await SharedPreferences.getInstance();
        final jsonList = allEntries.map((e) => json.encode(e)).toList();

        return await prefs.setStringList(_entriesKey, jsonList);
      }
      return false;
    } catch (e) {
      print('Error updating entry: $e');
      return false;
    }
  }

  // Get statistics for dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final currentStreak = await calculateCurrentStreak();
    final monthlyEntries = await getMonthlyEntries();
    final weeklyAvg = await calculateWeeklyAverage();
    final moneySaved = await calculateMoneySaved();
    final todayEntries = await getTodayEntries();

    // Calculate mindful days this month
    final mindfulDays = monthlyEntries
        .where((e) => e['dayType'] == 'mindful')
        .length;

    // Get today's summary
    String todayType = 'Not logged';
    if (todayEntries.isNotEmpty) {
      final lastEntry = todayEntries.last;
      todayType = lastEntry['dayType'] as String;
    }

    return {
      'currentStreak': currentStreak,
      'thisMonth': mindfulDays,
      'weeklyAverage': weeklyAvg,
      'moneySaved': moneySaved,
      'todayType': todayType,
      'todayEntries': todayEntries.length,
    };
  }

  // Get pattern insights (for ML model input)
  static Future<Map<String, dynamic>> getPatternData() async {
    final allEntries = await getAllEntries();

    if (allEntries.isEmpty) {
      return {
        'totalEntries': 0,
        'timeOfDayPattern': {},
        'contextPattern': {},
        'socialPattern': {},
        'triggerPattern': {},
        'averageMood': 0.0,
        'averageCraving': 0.0,
      };
    }

    // Analyze patterns
    final Map<String, int> timeOfDayPattern = {};
    final Map<String, int> contextPattern = {};
    final Map<String, int> socialPattern = {};
    final Map<String, int> triggerPattern = {};
    double totalMood = 0;
    double totalCraving = 0;
    int moodCount = 0;
    int cravingCount = 0;

    for (var entry in allEntries) {
      // Time of day
      final timeOfDay = entry['timeOfDay'] as String?;
      if (timeOfDay != null) {
        timeOfDayPattern[timeOfDay] = (timeOfDayPattern[timeOfDay] ?? 0) + 1;
      }

      // Context
      final context = entry['context'] as String?;
      if (context != null) {
        contextPattern[context] = (contextPattern[context] ?? 0) + 1;
      }

      // Social
      final social = entry['social'] as String?;
      if (social != null) {
        socialPattern[social] = (socialPattern[social] ?? 0) + 1;
      }

      // Triggers
      final triggers = entry['triggers'] as List?;
      if (triggers != null) {
        for (var trigger in triggers) {
          triggerPattern[trigger.toString()] =
              (triggerPattern[trigger.toString()] ?? 0) + 1;
        }
      }

      // Mood
      final mood = entry['moodBefore'];
      if (mood != null) {
        totalMood += (mood is int ? mood.toDouble() : mood as double);
        moodCount++;
      }

      // Craving
      final craving = entry['cravingLevel'];
      if (craving != null) {
        totalCraving += (craving is int
            ? craving.toDouble()
            : craving as double);
        cravingCount++;
      }
    }

    return {
      'totalEntries': allEntries.length,
      'timeOfDayPattern': timeOfDayPattern,
      'contextPattern': contextPattern,
      'socialPattern': socialPattern,
      'triggerPattern': triggerPattern,
      'averageMood': moodCount > 0 ? totalMood / moodCount : 0.0,
      'averageCraving': cravingCount > 0 ? totalCraving / cravingCount : 0.0,
    };
  }

  // Clear all data (for testing or user request)
  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_entriesKey);
      await prefs.remove(_substancesKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
