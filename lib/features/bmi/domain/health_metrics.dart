import 'dart:math';

import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';

class HealthMetrics {
  const HealthMetrics({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.xp,
  });

  final double heightCm;
  final double weightKg;
  final int age;
  final Gender gender;
  final ActivityLevel activityLevel;
  final int xp;

  double get bmi => weightKg / pow(heightCm / 100, 2);
  double get heightM => heightCm / 100;
  double get weightLb => weightKg * 2.2046226218;
  double get waterLiters => weightKg * 0.033;
  double get idealWeightMinKg => 18.5 * heightM * heightM;
  double get idealWeightMaxKg => 24.9 * heightM * heightM;

  double get bmr {
    if (gender == Gender.male) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    }
    if (gender == Gender.female) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    return 10 * weightKg + 6.25 * heightCm - 5 * age - 78;
  }

  double get activityFactor {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.athlete:
        return 1.9;
    }
  }

  double get maintenanceCalories => bmr * activityFactor;

  String get status {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String get advice {
    switch (status) {
      case 'Underweight':
        return 'Add nutrient-dense meals and light resistance work.';
      case 'Normal':
        return 'Excellent. Keep routines consistent and sleep well.';
      case 'Overweight':
        return 'Aim for steady progress with walking and portion control.';
      default:
        return 'Start with sustainable habits and consult a professional.';
    }
  }

  int get level => (xp ~/ 100) + 1;

  int get healthScore {
    final penalty = ((22 - bmi).abs() * 7).round();
    final bonus = min(15, xp ~/ 20);
    return (100 - penalty + bonus).clamp(0, 100);
  }

  String get heightShareText {
    final totalInches = heightCm / 2.54;
    final ft = totalInches ~/ 12;
    final inch = (totalInches - (ft * 12)).round();
    return '${heightCm.toStringAsFixed(1)} cm | ${heightM.toStringAsFixed(2)} m | ${ft}ft ${inch}in';
  }
}
