/// Health metrics calculation utilities
library health_metrics;

import 'package:bmi_calculator/features/bmi/domain/bmi_models.dart';

/// Calculate BMI from height and weight
double calculateBMI(double heightCm, double weightKg) {
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

/// Calculate BMR using Mifflin-St Jeor equation
double calculateBMR({
  required double weightKg,
  required double heightCm,
  required int age,
  required Gender gender,
}) {
  final f = gender == Gender.male ? 5 : -161;
  return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + f;
}

/// Calculate TDEE based on BMR and activity level
double calculateTDEE({
  required double bmr,
  required ActivityLevel activity,
}) {
  final multiplier = switch (activity) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.light => 1.375,
    ActivityLevel.moderate => 1.55,
    ActivityLevel.active => 1.725,
    ActivityLevel.athlete => 1.9,
  };
  return bmr * multiplier;
}

/// Ideal weight range for height/BMI
({double min, double max}) getIdealWeightRange(double heightCm) {
  const idealBmiMin = 18.5;
  const idealBmiMax = 24.9;
  final heightM = heightCm / 100;
  return (
    min: idealBmiMin * heightM * heightM,
    max: idealBmiMax * heightM * heightM,
  );
}

/// Calculate weight to lose/gain to reach BMI
double weightToReachBMI(double heightCm, double targetBMI) {
  final heightM = heightCm / 100;
  return targetBMI * heightM * heightM;
}

/// Water intake recommendation in liters
double calculateWaterIntake(double weightKg) {
  return (weightKg * 35) / 1000;
}

/// Calorie surplus/deficit for weight change
double caloriesPerPound = 3500;

/// Calculate days to reach weight goal
int daysToReachGoal({
  required double currentWeight,
  required double goalWeight,
  required double dailyCalories,
}) {
  final weightDifference = (currentWeight - goalWeight).abs();
  final caloriesDifference = (dailyCalories * caloriesPerPound).abs();
  if (caloriesDifference == 0) return 0;
  return (weightDifference * caloriesPerPound / caloriesDifference).ceil();
}

/// Macro allocation: protein percentage of calories
double proteinCalories({
  required double tdee,
  double proteinPercent = 0.30,
}) {
  return tdee * proteinPercent;
}

/// Macro allocation: carb percentage of calories
double carbCalories({
  required double tdee,
  double carbPercent = 0.45,
}) {
  return tdee * carbPercent;
}

/// Macro allocation: fat percentage of calories
double fatCalories({
  required double tdee,
  double fatPercent = 0.25,
}) {
  return tdee * fatPercent;
}
