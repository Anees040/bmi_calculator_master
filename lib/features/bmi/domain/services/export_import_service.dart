/// Data export/import service
library export_import;

import 'dart:convert';
import '../data/bmi_history_repository.dart';

/// Export format
enum ExportFormat { json, csv }

/// Export metadata
class ExportMetadata {
  final DateTime exportedAt;
  final int recordCount;
  final String appVersion;
  final String format;

  ExportMetadata({
    required this.exportedAt,
    required this.recordCount,
    required this.appVersion,
    required this.format,
  });

  Map<String, dynamic> toJson() => {
    'exportedAt': exportedAt.toIso8601String(),
    'recordCount': recordCount,
    'appVersion': appVersion,
    'format': format,
  };
}

/// Export/import service
class ExportImportService {
  static const String appVersion = '1.0.0';

  /// Export data to JSON
  Future<String> exportAsJson(
    List<BMIHistoryRecord> records,
  ) async {
    final data = {
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'recordCount': records.length,
        'appVersion': appVersion,
      },
      'records': records.map((r) => r.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  /// Export data to CSV
  Future<String> exportAsCSV(
    List<BMIHistoryRecord> records,
  ) async {
    StringBuffer csv = StringBuffer();

    // Header
    csv.writeln('ID,BMI,Weight(kg),Height(cm),Category,RecordedAt');

    // Data rows
    for (final record in records) {
      csv.writeln(
        '${record.id},'
        '${record.bmi},'
        '${record.weight},'
        '${record.height},'
        '${record.category},'
        '${record.recordedAt.toIso8601String()}',
      );
    }

    return csv.toString();
  }

  /// Import from JSON string
  Future<List<BMIHistoryRecord>> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final records = data['records'] as List?;

      if (records == null) return [];

      return records
          .map((r) => BMIHistoryRecord.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }
  }

  /// Import from CSV string
  Future<List<BMIHistoryRecord>> importFromCSV(String csvString) async {
    try {
      final lines = csvString.split('\n');
      if (lines.isEmpty || lines[0].isEmpty) return [];

      // Skip header
      final records = <BMIHistoryRecord>[];
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final parts = lines[i].split(',');
        if (parts.length < 6) continue;

        records.add(BMIHistoryRecord(
          id: parts[0],
          bmi: double.parse(parts[1]),
          weight: double.parse(parts[2]),
          height: double.parse(parts[3]),
          category: parts[4],
          recordedAt: DateTime.parse(parts[5]),
        ));
      }

      return records;
    } catch (e) {
      throw FormatException('Invalid CSV format: $e');
    }
  }

  /// Validate JSON export
  bool isValidJsonExport(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      return data is Map &&
          data.containsKey('metadata') &&
          data.containsKey('records');
    } catch (e) {
      return false;
    }
  }

  /// Get export size in bytes
  int getExportSize(String data) => utf8.encode(data).length;
}
