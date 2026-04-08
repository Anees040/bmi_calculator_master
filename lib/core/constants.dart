/// App-wide constants and configuration
library constants;

/// BMI status thresholds
class BMIThresholds {
  static const double underweight = 18.5;
  static const double normal = 25.0;
  static const double overweight = 30.0;
  // obese is 30+
}

/// Height unit conversion factors
class HeightConversions {
  static const double cmPerMeter = 100.0;
  static const double cmPerInch = 2.54;
  static const double inchesPerFoot = 12.0;
}

/// Weight unit conversion factors
class WeightConversions {
  static const double kgPerPound = 0.453592;
  static const double poundsPerKg = 2.20462;
}

/// Activity level multipliers for TDEE calculation
class ActivityMultipliers {
  static const double sedentary = 1.2;
  static const double light = 1.375;
  static const double moderate = 1.55;
  static const double active = 1.725;
  static const double athlete = 1.9;
}

/// Notification timing constants
class NotificationTimings {
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;
  static const int weeklyReportDayOfWeek = 7; // Sunday
  static const int weeklyReportHour = 10;
}

/// Storage keys for SharedPreferences
class StorageKeys {
  static const String bmiHistory = 'bmi_history_v1';
  static const String gameState = 'bmi_game_state_v1';
  static const String onboardingSeen = 'bmi_onboarding_seen_v1';
  static const String preferences = 'bmi_preferences_v1';
}

/// App version information
class AppVersion {
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String channel = 'stable';
}
