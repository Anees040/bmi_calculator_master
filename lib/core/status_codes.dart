/// HTTP status and error code definitions
library status_codes;

/// HTTP-like status codes for app operations
class StatusCodes {
  // Success codes
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;

  // Client error codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int validationError = 422;

  // Server error codes
  static const int internalError = 500;
  static const int notImplemented = 501;
  static const int serviceUnavailable = 503;

  // App-specific codes
  static const int cacheHit = 204;
  static const int storageFailed = 510;
  static const int notificationFailed = 511;
  static const int permissionDenied = 512;
}

/// Error code descriptions
class ErrorMessages {
  static const Map<int, String> messages = {
    StatusCodes.ok: 'Operation successful',
    StatusCodes.created: 'Resource created',
    StatusCodes.badRequest: 'Invalid request',
    StatusCodes.unauthorized: 'Not authorized',
    StatusCodes.forbidden: 'Access forbidden',
    StatusCodes.notFound: 'Resource not found',
    StatusCodes.conflict: 'Resource conflict',
    StatusCodes.validationError: 'Validation failed',
    StatusCodes.internalError: 'Internal error',
    StatusCodes.notImplemented: 'Not implemented',
    StatusCodes.storageFailed: 'Storage operation failed',
    StatusCodes.notificationFailed: 'Notification failed',
    StatusCodes.permissionDenied: 'Permission denied',
  };

  static String get(int code) => messages[code] ?? 'Unknown error';
}
