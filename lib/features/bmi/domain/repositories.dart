/// Repository pattern abstract interfaces
library repositories;

import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';

/// Abstract repository for BMI history
abstract class BMIRepository {
  /// Get all BMI records
  Future<List<BmiRecord>> getAllRecords();

  /// Get records from last N days
  Future<List<BmiRecord>> getRecentRecords(int days);

  /// Add a new record
  Future<void> addRecord(BmiRecord record);

  /// Delete a record
  Future<void> deleteRecord(String id);

  /// Clear all records
  Future<void> clearAll();

  /// Export records as JSON
  Future<String> exportAsJSON();

  /// Export records as CSV
  Future<String> exportAsCSV();
}

/// Abstract repository for user preferences
abstract class PreferenceRepository {
  /// Get current preferences
  Future<AppPreferences> getPreferences();

  /// Update preferences
  Future<void> updatePreferences(AppPreferences prefs);

  /// Reset to defaults
  Future<void> resetToDefaults();

  /// Get single preference field
  Future<T?> getSingleField<T>(String key);
}

/// Abstract repository for game state
abstract class GameStateRepository {
  /// Get current game state
  Future<GameState> getGameState();

  /// Update game state
  Future<void> updateGameState(GameState state);

  /// Add XP
  Future<void> addXP(int amount);

  /// Increment streak
  Future<void> incrementStreak();

  /// Reset streak
  Future<void> resetStreak();
}

/// Abstract repository for notifications
abstract class NotificationRepository {
  /// Schedule daily reminder
  Future<void> scheduleDailyReminder(int hour, int minute);

  /// Cancel daily reminder
  Future<void> cancelDailyReminder();

  /// Schedule weekly report
  Future<void> scheduleWeeklyReport(int dayOfWeek);

  /// Get notification history
  Future<List<NotificationLog>> getNotificationHistory();
}

/// Model for notification log
class NotificationLog {
  NotificationLog({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.sentTime,
    this.userAction,
  });

  final String id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final DateTime? sentTime;
  final String? userAction;
}
