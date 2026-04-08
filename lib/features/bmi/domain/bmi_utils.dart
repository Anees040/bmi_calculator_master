/// Utility functions for BMI calculation and formatting
library bmi_utils;

/// Format a BMI value with appropriate precision and color context
extension BMIFormatting on double {
  /// Returns BMI formatted to 1 decimal place
  String toBmiString() => toStringAsFixed(1);

  /// Returns weight formatted to 1 decimal place
  String toWeightString() => toStringAsFixed(1);
}

/// Determine BMI status category
String bmiStatusFromValue(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

/// Calculate weight change percentage between two values
double weightChangePercent(double oldWeight, double newWeight) {
  if (oldWeight == 0) return 0;
  return ((newWeight - oldWeight) / oldWeight) * 100;
}

/// Get human-readable time difference from now
String timeAgoText(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${(difference.inDays / 7).floor()}w ago';
  }
}
