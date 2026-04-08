/// BMI history repository for tracking historical records
library bmi_history_repository;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/bmi_models.dart';

/// BMI history record
class BMIHistoryRecord {
  final String id;
  final double bmi;
  final double weight;
  final double height;
  final String category;
  final DateTime recordedAt;

  BMIHistoryRecord({
    required this.id,
    required this.bmi,
    required this.weight,
    required this.height,
    required this.category,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bmi': bmi,
    'weight': weight,
    'height': height,
    'category': category,
    'recordedAt': recordedAt.toIso8601String(),
  };

  factory BMIHistoryRecord.fromJson(Map<String, dynamic> json) {
    return BMIHistoryRecord(
      id: json['id'] as String,
      bmi: (json['bmi'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      category: json['category'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}

/// BMI history repository
class BMIHistoryRepository {
  static const String _historyKey = 'bmi_history_v1';
  static const int _maxRecords = 1000;

  final SharedPreferences _prefs;

  BMIHistoryRepository(this._prefs);

  /// Add BMI record
  Future<void> addRecord(BMIHistoryRecord record) async {
    try {
      final records = await getAllRecords();
      records.add(record);

      // Keep only latest _maxRecords
      if (records.length > _maxRecords) {
        records.removeRange(0, records.length - _maxRecords);
      }

      await _saveRecords(records);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all records
  Future<List<BMIHistoryRecord>> getAllRecords() async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((e) => BMIHistoryRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get records in date range
  Future<List<BMIHistoryRecord>> getRecordsInRange(
    DateTime from,
    DateTime to,
  ) async {
    final records = await getAllRecords();
    return records
        .where((r) => r.recordedAt.isAfter(from) && r.recordedAt.isBefore(to))
        .toList();
  }

  /// Get latest N records
  Future<List<BMIHistoryRecord>> getLatest(int count) async {
    final records = await getAllRecords();
    final lastIndex = records.length;
    final startIndex = (lastIndex - count).clamp(0, lastIndex);
    return records.sublist(startIndex);
  }

  /// Delete record
  Future<void> deleteRecord(String id) async {
    final records = await getAllRecords();
    records.removeWhere((r) => r.id == id);
    await _saveRecords(records);
  }

  /// Clear all records
  Future<void> clearAll() async {
    await _prefs.remove(_historyKey);
  }

  /// Get statistics
  Future<BMIStatistics> getStatistics() async {
    final records = await getAllRecords();
    if (records.isEmpty) {
      return BMIStatistics.empty();
    }

    final bmis = records.map((r) => r.bmi).toList();
    bmis.sort();

    return BMIStatistics(
      count: records.length,
      average: bmis.reduce((a, b) => a + b) / bmis.length,
      min: bmis.first,
      max: bmis.last,
      median: bmis[bmis.length ~/ 2],
      lastRecorded: records.last.recordedAt,
    );
  }

  Future<void> _saveRecords(List<BMIHistoryRecord> records) async {
    final jsonList = records.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs.setString(_historyKey, jsonString);
  }
}

/// BMI statistics
class BMIStatistics {
  final int count;
  final double average;
  final double min;
  final double max;
  final double median;
  final DateTime? lastRecorded;

  BMIStatistics({
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.median,
    required this.lastRecorded,
  });

  factory BMIStatistics.empty() => BMIStatistics(
    count: 0,
    average: 0,
    min: 0,
    max: 0,
    median: 0,
    lastRecorded: null,
  );
}
