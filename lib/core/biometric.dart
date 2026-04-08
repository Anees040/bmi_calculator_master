/// Biometric authentication service
library biometric;

/// Biometric auth result
class BiometricAuthResult {
  final bool isAuthenticated;
  final String? errorMessage;
  final BiometricType? authenticatedWith;

  const BiometricAuthResult({
    required this.isAuthenticated,
    this.errorMessage,
    this.authenticatedWith,
  });

  factory BiometricAuthResult.success(BiometricType type) =>
      BiometricAuthResult(
        isAuthenticated: true,
        authenticatedWith: type,
      );

  factory BiometricAuthResult.failure(String message) => BiometricAuthResult(
    isAuthenticated: false,
    errorMessage: message,
  );

  factory BiometricAuthResult.cancelled() => BiometricAuthResult(
    isAuthenticated: false,
    errorMessage: 'Authentication cancelled by user',
  );
}

/// Supported biometric types
enum BiometricType {
  fingerprint,
  face,
  iris,
}

/// Biometric service interface
abstract class IBiometricService {
  Future<bool> canAuthenticate();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<BiometricAuthResult> authenticate(String reason);
}

/// Stub implementation
class BiometricService implements IBiometricService {
  @override
  Future<bool> canAuthenticate() async => false;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [];

  @override
  Future<BiometricAuthResult> authenticate(String reason) async =>
      BiometricAuthResult.failure('Not implemented on this platform');
}
