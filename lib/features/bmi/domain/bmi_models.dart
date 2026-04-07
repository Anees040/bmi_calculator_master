enum Gender { male, female, other }

enum HeightUnit { cm, meter, ftIn }

enum WeightUnit { kg, lb }

enum ActivityLevel { sedentary, light, moderate, active, athlete }

class BmiRecord {
  BmiRecord({
    required this.timestamp,
    required this.bmi,
    required this.status,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
  });

  final DateTime timestamp;
  final double bmi;
  final String status;
  final double heightCm;
  final double weightKg;
  final int age;
  final String gender;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'bmi': bmi,
        'status': status,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'gender': gender,
      };

  factory BmiRecord.fromJson(Map<String, dynamic> json) {
    return BmiRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      bmi: (json['bmi'] as num).toDouble(),
      status: json['status'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
    );
  }
}

class GameState {
  const GameState({
    required this.xp,
    required this.streak,
    required this.hydrationQuest,
    required this.stepsQuest,
    required this.lastCheckIn,
  });

  final int xp;
  final int streak;
  final double hydrationQuest;
  final double stepsQuest;
  final String lastCheckIn;

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'streak': streak,
        'hydrationQuest': hydrationQuest,
        'stepsQuest': stepsQuest,
        'lastCheckIn': lastCheckIn,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      hydrationQuest: ((json['hydrationQuest'] as num?)?.toDouble() ?? 0.3)
          .clamp(0, 1),
      stepsQuest: ((json['stepsQuest'] as num?)?.toDouble() ?? 0.2).clamp(0, 1),
      lastCheckIn: json['lastCheckIn'] as String? ?? '',
    );
  }

  static const empty = GameState(
    xp: 0,
    streak: 0,
    hydrationQuest: 0.3,
    stepsQuest: 0.2,
    lastCheckIn: '',
  );
}

class AppPreferences {
  const AppPreferences({
    required this.heightUnit,
    required this.weightUnit,
    required this.notificationsEnabled,
    required this.dailyReminderEnabled,
    required this.reminderHour,
  });

  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final int reminderHour;

  Map<String, dynamic> toJson() => {
        'heightUnit': heightUnit.name,
        'weightUnit': weightUnit.name,
        'notificationsEnabled': notificationsEnabled,
        'dailyReminderEnabled': dailyReminderEnabled,
        'reminderHour': reminderHour,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      heightUnit: _heightUnitFromName(json['heightUnit'] as String?),
      weightUnit: _weightUnitFromName(json['weightUnit'] as String?),
      notificationsEnabled:
          json['notificationsEnabled'] as bool? ?? AppPreferences.defaults.notificationsEnabled,
      dailyReminderEnabled:
          json['dailyReminderEnabled'] as bool? ?? AppPreferences.defaults.dailyReminderEnabled,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? AppPreferences.defaults.reminderHour,
    );
  }

  static HeightUnit _heightUnitFromName(String? name) {
    for (final value in HeightUnit.values) {
      if (value.name == name) {
        return value;
      }
    }
    return AppPreferences.defaults.heightUnit;
  }

  static WeightUnit _weightUnitFromName(String? name) {
    for (final value in WeightUnit.values) {
      if (value.name == name) {
        return value;
      }
    }
    return AppPreferences.defaults.weightUnit;
  }

  static const defaults = AppPreferences(
    heightUnit: HeightUnit.cm,
    weightUnit: WeightUnit.kg,
    notificationsEnabled: true,
    dailyReminderEnabled: true,
    reminderHour: 9,
  );
}
