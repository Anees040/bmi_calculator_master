/// Get BMI history use case
library get_bmi_history_usecase;

import '../../../core/usecase.dart';
import '../../../core/date_utils.dart';
import '../../data/bmi_history_repository.dart';

/// Input for history retrieval
class GetBMIHistoryInput {
  final String? period; // 'week', 'month', 'year', 'all'
  final int? limit; // Maximum records to return
  final DateTime? from;
  final DateTime? to;

  GetBMIHistoryInput({
    this.period = 'month',
    this.limit = 100,
    this.from,
    this.to,
  });
}

/// Output of history retrieval
class GetBMIHistoryOutput {
  final List<BMIHistoryRecord> records;
  final BMIStatistics statistics;
  final DateTime? earliestRecord;
  final DateTime? latestRecord;

  GetBMIHistoryOutput({
    required this.records,
    required this.statistics,
    required this.earliestRecord,
    required this.latestRecord,
  });

  /// Get trend (improving, declining, stable)
  String getTrend() {
    if (records.length < 2) return 'No trend data';

    final first = records.first.bmi;
    final last = records.last.bmi;
    final difference = last - first;

    if (difference.abs() < 0.5) return 'Stable';
    if (difference > 0) return 'Declining';
    return 'Improving';
  }

  /// Get average change per week
  double getWeeklyChange() {
    if (records.length < 2) return 0;

    final first = records.first;
    final last = records.last;
    final daysDiff = last.recordedAt.difference(first.recordedAt).inDays;
    if (daysDiff == 0) return 0;

    final weeksDiff = daysDiff / 7;
    return (last.bmi - first.bmi) / weeksDiff;
  }
}

/// Get BMI history use case
class GetBMIHistoryUseCase
    extends UseCase<GetBMIHistoryOutput, GetBMIHistoryInput> {
  final BMIHistoryRepository _repository;

  GetBMIHistoryUseCase(this._repository);

  @override
  Future<GetBMIHistoryOutput> call(GetBMIHistoryInput input) async {
    List<BMIHistoryRecord> records = [];

    // Determine date range
    DateTime from = input.from ?? _getFromDate(input.period);
    DateTime to = input.to ?? DateTime.now();

    // Get records in range
    records = await _repository.getRecordsInRange(from, to);

    // Limit results if specified
    if (input.limit != null && records.length > input.limit!) {
      records = records.sublist(records.length - input.limit!);
    }

    // Get statistics
    
    final stats = await _repository.getStatistics();

    return GetBMIHistoryOutput(
      records: records,
      statistics: stats,
      earliestRecord: records.isNotEmpty ? records.first.recordedAt : null,
      latestRecord: records.isNotEmpty ? records.last.recordedAt : null,
    );
  }

  DateTime _getFromDate(String? period) {
    final now = DateTime.now();
    switch (period) {
      case 'week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'month':
        return DateTime(now.year, now.month, 1);
      case 'year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(2000); // Beginning of time
    }
  }
}
