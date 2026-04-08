/// Dart/Flutter extension methods for cleaner code
library extensions;

import 'package:flutter/material.dart';

/// Extensions on DateTime for health app
extension DateTimeHealth on DateTime {
  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get day of week name
  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Format as "Mon, Jan 1"
  String get shortFormat {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '$dayName, ${months[month - 1]} $day';
  }
}

/// Extensions on BuildContext for navigation and themes
extension ContextExtensions on BuildContext {
  /// Navigate to route and return result
  Future<T?> navigateTo<T>(Widget route) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => route),
    );
  }

  /// Pop with optional result
  void popWith<T>([T? result]) => Navigator.of(this).pop(result);

  /// Check if device is in dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Show snackbar
  void showSnack(String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }
}

/// Extensions on String for validation and formatting
extension StringExtensions on String {
  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string matches email pattern
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }
}

/// Extensions on num for formatting
extension NumExtensions on num {
  /// Format as percentage with 1 decimal place
  String toPercentString() => '${(this * 100).toStringAsFixed(1)}%';

  /// Format with comma thousands separator
  String toFormattedString() => toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}
