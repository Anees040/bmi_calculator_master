/// Update preferences use case
library update_preferences_usecase;

import '../../../core/usecase.dart';
import '../domain/bmi_models.dart';
import '../../data/preference_repository.dart';

/// Input for updating preferences
class UpdatePreferencesInput {
  final String? unitSystem;
  final String? theme;
  final String? language;
  final bool? notificationsEnabled;
  final String? reminderTime;
  final int? reminderFrequency;

  UpdatePreferencesInput({
    this.unitSystem,
    this.theme,
    this.language,
    this.notificationsEnabled,
    this.reminderTime,
    this.reminderFrequency,
  });
}

/// Output of updating preferences
class UpdatePreferencesOutput {
  final bool wasSuccessful;
  final AppPreferences updatedPreferences;
  final String? errorMessage;
  final List<String> changedFields;

  UpdatePreferencesOutput({
    required this.wasSuccessful,
    required this.updatedPreferences,
    this.errorMessage,
    required this.changedFields,
  });
}

/// Update preferences use case
class UpdatePreferencesUseCase
    extends UseCase<UpdatePreferencesOutput, UpdatePreferencesInput> {
  final PreferenceRepository _repository;

  UpdatePreferencesUseCase(this._repository);

  @override
  Future<UpdatePreferencesOutput> call(UpdatePreferencesInput input) async {
    try {
      // Get current preferences
      var currentPrefs = await _repository.getPreferences();
      final changedFields = <String>[];

      // Apply changes
      if (input.unitSystem != null && input.unitSystem != currentPrefs.unitSystem) {
        currentPrefs =
            currentPrefs.copyWith(unitSystem: input.unitSystem);
        changedFields.add('unitSystem');
      }

      if (input.theme != null && input.theme != currentPrefs.theme) {
        currentPrefs = currentPrefs.copyWith(theme: input.theme);
        changedFields.add('theme');
      }

      if (input.language != null && input.language != currentPrefs.language) {
        currentPrefs = currentPrefs.copyWith(language: input.language);
        changedFields.add('language');
      }

      if (input.notificationsEnabled != null &&
          input.notificationsEnabled != currentPrefs.notificationsEnabled) {
        currentPrefs =
            currentPrefs.copyWith(notificationsEnabled: input.notificationsEnabled);
        changedFields.add('notificationsEnabled');
      }

      if (input.reminderTime != null &&
          input.reminderTime != currentPrefs.reminderTime) {
        currentPrefs =
            currentPrefs.copyWith(reminderTime: input.reminderTime);
        changedFields.add('reminderTime');
      }

      if (input.reminderFrequency != null &&
          input.reminderFrequency != currentPrefs.reminderFrequency) {
        currentPrefs =
            currentPrefs.copyWith(reminderFrequency: input.reminderFrequency);
        changedFields.add('reminderFrequency');
      }

      // Save if any changes
      if (changedFields.isNotEmpty) {
        await _repository.savePreferences(currentPrefs);
      }

      return UpdatePreferencesOutput(
        wasSuccessful: true,
        updatedPreferences: currentPrefs,
        changedFields: changedFields,
      );
    } catch (e) {
      return UpdatePreferencesOutput(
        wasSuccessful: false,
        updatedPreferences: AppPreferences.defaultPrefs(),
        errorMessage: e.toString(),
        changedFields: [],
      );
    }
  }
}
