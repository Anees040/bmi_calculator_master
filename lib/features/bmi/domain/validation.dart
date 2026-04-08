/// Input validation utilities for BMI app
library validation;

/// Validates height in centimeters
bool isValidHeightCm(double cm) => cm >= 100 && cm <= 230;

/// Validates weight in kilograms
bool isValidWeightKg(double kg) => kg >= 30 && kg <= 250;

/// Validates age in years
bool isValidAge(int age) => age >= 10 && age <= 120;

/// Validates reminder hour (0-23)
bool isValidReminderHour(int hour) => hour >= 0 && hour <= 23;

/// Get friendly error message for invalid height
String? validateHeight(double? value) {
  if (value == null) return 'Height is required';
  if (!isValidHeightCm(value)) return 'Height must be between 100 and 230 cm';
  return null;
}

/// Get friendly error message for invalid weight
String? validateWeight(double? value) {
  if (value == null) return 'Weight is required';
  if (!isValidWeightKg(value)) return 'Weight must be between 30 and 250 kg';
  return null;
}

/// Get friendly error message for invalid age
String? validateAge(int? value) {
  if (value == null) return 'Age is required';
  if (!isValidAge(value)) return 'Age must be between 10 and 120';
  return null;
}
