/// Input formatters and validators
library input_formatter;

import 'package:flutter/services.dart';

/// Height input formatter (accepts height up to 300cm)
class HeightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final double? height = double.tryParse(newValue.text);
    if (height == null || height > 300) return oldValue;

    return newValue;
  }
}

/// Weight input formatter (accepts weight up to 500kg)
class WeightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final double? weight = double.tryParse(newValue.text);
    if (weight == null || weight > 500) return oldValue;

    return newValue;
  }
}

/// Age input formatter (accepts age 1-150)
class AgeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final int? age = int.tryParse(newValue.text);
    if (age == null || age < 1 || age > 150) return oldValue;

    return newValue;
  }
}

/// Number input formatter with decimal places
class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final double maxValue;

  DecimalInputFormatter({
    this.decimalPlaces = 2,
    this.maxValue = double.maxFinite,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final double? value = double.tryParse(newValue.text);
    if (value == null || value > maxValue) return oldValue;

    // Limit decimal places
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length > 2 || parts[1].length > decimalPlaces) {
        return oldValue;
      }
    }

    return newValue;
  }
}

/// Phone number formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    // Remove all non-digits
    final digitsOnly = text.replaceAll(RegExp('[^0-9]'), '');

    // Limit to 15 digits
    if (digitsOnly.length > 15) return oldValue;

    return newValue;
  }
}

/// Email formatter
class EmailFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toLowerCase().trim();

    if (!_isValidEmailCharacter(text)) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(
        TextPosition(offset: text.length),
      ),
    );
  }

  bool _isValidEmailCharacter(String text) {
    if (text.isEmpty) return true;

    final lastChar = text[text.length - 1];
    return RegExp(r'[a-z0-9@._\-+]').hasMatch(lastChar);
  }
}
