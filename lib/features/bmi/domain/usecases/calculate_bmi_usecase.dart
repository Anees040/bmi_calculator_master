/// Calculate BMI use case
library calculate_bmi_usecase;

import '../../../core/usecase.dart';
import '../../../core/health_metrics.dart';
import '../domain/bmi_utils.dart';
import '../domain/validation.dart';

/// Input for BMI calculation
class CalculateBMIInput {
  final double height; // in cm
  final double weight; // in kg
  final String? unit; // 'metric' or 'imperial'

  CalculateBMIInput({
    required this.height,
    required this.weight,
    this.unit = 'metric',
  });
}

/// Output of BMI calculation
class BMICalculationOutput {
  final double bmi;
  final String category;
  final String interpretation;
  final double minHealthyWeight;
  final double maxHealthyWeight;
  final DateTime calculatedAt;

  BMICalculationOutput({
    required this.bmi,
    required this.category,
    required this.interpretation,
    required this.minHealthyWeight,
    required this.maxHealthyWeight,
  }) : calculatedAt = DateTime.now();
}

/// Calculate BMI use case
class CalculateBMIUseCase extends UseCase<BMICalculationOutput, CalculateBMIInput> {
  @override
  Future<BMICalculationOutput> call(CalculateBMIInput input) async {
    // Validate input
    final heightValidation = validateHeight(input.height);
    if (!heightValidation.isValid) {
      throw ArgumentError(heightValidation.errorMessage);
    }

    final weightValidation = validateWeight(input.weight);
    if (!weightValidation.isValid) {
      throw ArgumentError(weightValidation.errorMessage);
    }

    // Convert to metric if needed
    double height = input.height;
    double weight = input.weight;

    if (input.unit == 'imperial') {
      height = input.height * 2.54; // inches to cm
      weight = input.weight * 0.453592; // lbs to kg
    }

    // Calculate BMI
    final bmi = HealthMetrics.calculateBMI(weight, height);
    final category = _getBMICategory(bmi);
    final interpretation = _getInterpretation(bmi);

    // Calculate healthy weight range
    const healthyBMIMin = 18.5;
    const healthyBMIMax = 24.9;
    final minHealthyWeight = (healthyBMIMin * height * height) / 10000;
    final maxHealthyWeight = (healthyBMIMax * height * height) / 10000;

    return BMICalculationOutput(
      bmi: bmi,
      category: category,
      interpretation: interpretation,
      minHealthyWeight: minHealthyWeight,
      maxHealthyWeight: maxHealthyWeight,
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _getInterpretation(double bmi) {
    if (bmi < 18.5) {
      return 'You may need to gain weight or consult a healthcare provider';
    } else if (bmi < 25) {
      return 'You have a healthy weight. Keep up the good work!';
    } else if (bmi < 30) {
      return 'You may want to consider weight management strategies';
    } else {
      return 'Please consult a healthcare provider for weight management advice';
    }
  }
}
