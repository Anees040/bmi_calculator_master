/// Save BMI record use case
library save_bmi_record_usecase;

import 'dart:math';
import '../../../core/usecase.dart';
import '../../data/bmi_history_repository.dart';

/// Input for saving BMI record
class SaveBMIRecordInput {
  final double bmi;
  final double weight;
  final double height;
  final String category;
  final DateTime? recordedAt;

  SaveBMIRecordInput({
    required this.bmi,
    required this.weight,
    required this.height,
    required this.category,
    this.recordedAt,
  });
}

/// Output of saving BMI record
class SaveBMIRecordOutput {
  final String recordId;
  final bool wasSuccessful;
  final BMIHistoryRecord savedRecord;
  final String? message;

  SaveBMIRecordOutput({
    required this.recordId,
    required this.wasSuccessful,
    required this.savedRecord,
    this.message,
  });
}

/// Save BMI record use case
class SaveBMIRecordUseCase
    extends UseCase<SaveBMIRecordOutput, SaveBMIRecordInput> {
  final BMIHistoryRepository _repository;

  SaveBMIRecordUseCase(this._repository);

  @override
  Future<SaveBMIRecordOutput> call(SaveBMIRecordInput input) async {
    try {
      // Generate unique ID
      final recordId = _generateId();

      // Create record
      final record = BMIHistoryRecord(
        id: recordId,
        bmi: input.bmi,
        weight: input.weight,
        height: input.height,
        category: input.category,
        recordedAt: input.recordedAt ?? DateTime.now(),
      );

      // Save to repository
      await _repository.addRecord(record);

      return SaveBMIRecordOutput(
        recordId: recordId,
        wasSuccessful: true,
        savedRecord: record,
        message: 'BMI record saved successfully',
      );
    } catch (e) {
      return SaveBMIRecordOutput(
        recordId: '',
        wasSuccessful: false,
        savedRecord: _createDummyRecord(input),
        message: 'Failed to save BMI record: $e',
      );
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'bmi_${timestamp}_$random';
  }

  BMIHistoryRecord _createDummyRecord(SaveBMIRecordInput input) {
    return BMIHistoryRecord(
      id: '',
      bmi: input.bmi,
      weight: input.weight,
      height: input.height,
      category: input.category,
      recordedAt: DateTime.now(),
    );
  }
}
