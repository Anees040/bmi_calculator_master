/// Application configuration service
library configuration;

import 'dart:io';

/// Build flavor (environment)
enum BuildFlavor {
  development,
  staging,
  production,
}

/// App configuration
class AppConfig {
  final BuildFlavor flavor;
  final String baseUrl;
  final String apiKey;
  final bool debugLogging;
  final int requestTimeoutSeconds;
  final int cacheExpirationMinutes;
  final bool enableAnalytics;

  const AppConfig({
    required this.flavor,
    required this.baseUrl,
    required this.apiKey,
    this.debugLogging = false,
    this.requestTimeoutSeconds = 30,
    this.cacheExpirationMinutes = 60,
    this.enableAnalytics = true,
  });

  /// Check if production
  bool get isProduction => flavor == BuildFlavor.production;

  /// Check if development
  bool get isDevelopment => flavor == BuildFlavor.development;

  /// Get platform name
  static String platformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }
}

/// Configuration service
class ConfigurationService {
  static final ConfigurationService _instance = ConfigurationService._();

  AppConfig? _config;

  ConfigurationService._();

  /// Get singleton instance
  factory ConfigurationService() => _instance;

  /// Initialize with config
  void initialize(AppConfig config) => _config = config;

  /// Get current config
  AppConfig get config {
    if (_config == null) {
      throw StateError('ConfigurationService not initialized');
    }
    return _config!;
  }

  /// Reset to null (for testing)
  void reset() => _config = null;
}

/// Create development config
AppConfig createDevConfig() => AppConfig(
  flavor: BuildFlavor.development,
  baseUrl: 'http://localhost:8000',
  apiKey: 'dev-key-12345',
  debugLogging: true,
);

/// Create staging config
AppConfig createStagingConfig() => AppConfig(
  flavor: BuildFlavor.staging,
  baseUrl: 'https://staging-api.example.com',
  apiKey: 'staging-key-67890',
);

/// Create production config
AppConfig createProductionConfig() => AppConfig(
  flavor: BuildFlavor.production,
  baseUrl: 'https://api.example.com',
  apiKey: 'prod-key-xxxxx',
  debugLogging: false,
);
