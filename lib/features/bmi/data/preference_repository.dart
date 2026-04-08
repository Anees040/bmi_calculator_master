/// Preference repository implementation using SharedPreferences adapter
library preference_repository;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'bmi_models.dart';

/// Preference repository interface
abstract class IPreferenceRepository {
  Future<AppPreferences> getPreferences();
  Future<void> savePreferences(AppPreferences prefs);
  Future<void> clearPreferences();
}

/// Preference repository implementation
class PreferenceRepository implements IPreferenceRepository {
  static const String _preferencesKey = 'app_preferences_v1';
  
  final SharedPreferences _prefs;

  PreferenceRepository(this._prefs);

  @override
  Future<AppPreferences> getPreferences() async {
    try {
      final jsonString = _prefs.getString(_preferencesKey);
      if (jsonString == null) {
        return AppPreferences.defaultPrefs();
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppPreferences.fromJson(json);
    } catch (e) {
      return AppPreferences.defaultPrefs();
    }
  }

  @override
  Future<void> savePreferences(AppPreferences prefs) async {
    try {
      final json = prefs.toJson();
      final jsonString = jsonEncode(json);
      await _prefs.setString(_preferencesKey, jsonString);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearPreferences() async {
    await _prefs.remove(_preferencesKey);
  }

  /// Update single preference field
  Future<void> updateUnitSystem(String unitSystem) async {
    final current = await getPreferences();
    final updated = current.copyWith(unitSystem: unitSystem);
    await savePreferences(updated);
  }

  /// Update notification settings
  Future<void> updateNotifications({
    required bool enabled,
    required String? time,
    required int? frequency,
  }) async {
    final current = await getPreferences();
    final updated = current.copyWith(
      notificationsEnabled: enabled,
      reminderTime: time,
      reminderFrequency: frequency,
    );
    await savePreferences(updated);
  }

  /// Update theme preference
  Future<void> updateTheme(String theme) async {
    final current = await getPreferences();
    final updated = current.copyWith(theme: theme);
    await savePreferences(updated);
  }

  /// Update language preference
  Future<void> updateLanguage(String language) async {
    final current = await getPreferences();
    final updated = current.copyWith(language: language);
    await savePreferences(updated);
  }

  /// Get preference or default
  Future<T> getOrDefault<T>(
    String key,
    T defaultValue,
    T Function(dynamic) converter,
  ) async {
    try {
      final value = _prefs.get(key);
      if (value == null) return defaultValue;
      return converter(value);
    } catch (e) {
      return defaultValue;
    }
  }
}

/// Factory for creating preference repository
Future<PreferenceRepository> createPreferenceRepository() async {
  final prefs = await SharedPreferences.getInstance();
  return PreferenceRepository(prefs);
}
