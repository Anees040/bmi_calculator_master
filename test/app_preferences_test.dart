import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppPreferences', () {
    test('defaults are stable and expected', () {
      const prefs = AppPreferences.defaults;

      expect(prefs.heightUnit, HeightUnit.cm);
      expect(prefs.weightUnit, WeightUnit.kg);
      expect(prefs.notificationsEnabled, isTrue);
      expect(prefs.dailyReminderEnabled, isTrue);
      expect(prefs.reminderHour, 9);
    });

    test('fromJson falls back safely and clamps reminder hour', () {
      final decoded = AppPreferences.fromJson(<String, dynamic>{
        'heightUnit': 'invalidHeight',
        'weightUnit': 'invalidWeight',
        'notificationsEnabled': false,
        'dailyReminderEnabled': false,
        'reminderHour': 99,
      });

      expect(decoded.heightUnit, AppPreferences.defaults.heightUnit);
      expect(decoded.weightUnit, AppPreferences.defaults.weightUnit);
      expect(decoded.notificationsEnabled, isFalse);
      expect(decoded.dailyReminderEnabled, isFalse);
      expect(decoded.reminderHour, 23);
    });

    test('copyWith updates only provided fields', () {
      const base = AppPreferences.defaults;
      final updated = base.copyWith(
        weightUnit: WeightUnit.lb,
        reminderHour: 6,
      );

      expect(updated.heightUnit, base.heightUnit);
      expect(updated.weightUnit, WeightUnit.lb);
      expect(updated.notificationsEnabled, base.notificationsEnabled);
      expect(updated.dailyReminderEnabled, base.dailyReminderEnabled);
      expect(updated.reminderHour, 6);
    });
  });
}
