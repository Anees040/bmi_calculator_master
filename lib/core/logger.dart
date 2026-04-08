/// Error handling and logging utilities
library logger;

import 'package:flutter/foundation.dart';

/// Simple logging service for debugging
class AppLogger {
  static const String _prefix = '[BMI]';

  /// Log debug message
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_prefix [DEBUG] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      print('$_prefix [INFO] $message');
    }
  }

  /// Log warning message
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      print('$_prefix [WARNING] $message');
      if (error != null) print('Error: $error');
    }
  }

  /// Log error message
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      print('$_prefix [ERROR] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }

  /// Log performance timing
  static void timing(String label, Duration duration) {
    if (kDebugMode) {
      print('$_prefix [TIMING] $label took ${duration.inMilliseconds}ms');
    }
  }
}

/// Custom app exceptions
class AppException implements Exception {
  AppException({
    required this.message,
    this.code = 'UNKNOWN',
    this.originalError,
    this.stackTrace,
  });

  final String message;
  final String code;
  final Object? originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

/// Exception for preference/storage errors
class StorageException extends AppException {
  StorageException({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'STORAGE_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}

/// Exception for notification scheduling errors
class NotificationException extends AppException {
  NotificationException({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: 'NOTIFICATION_ERROR',
    originalError: error,
    stackTrace: stackTrace,
  );
}
