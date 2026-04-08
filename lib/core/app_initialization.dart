/// App initialization and setup utilities
library app_initialization;

import 'configuration.dart';
import 'service_locator.dart';
import 'logger.dart';
import 'analytics.dart';

/// App initialization configuration
class AppInitConfig {
  final BuildFlavor flavor;
  final bool enableLogging;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  AppInitConfig({
    required this.flavor,
    this.enableLogging = true,
    this.enableAnalytics = true,
    this.enableCrashReporting = false,
  });
}

/// App initializer
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._();
  
  bool _isInitialized = false;

  AppInitializer._();

  factory AppInitializer() => _instance;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialize app
  Future<void> initialize(AppInitConfig config) async {
    if (_isInitialized) return;

    try {
      // 1. Setup configuration
      _setupConfiguration(config.flavor);

      // 2. Setup service locator
      _setupServiceLocator();

      // 3. Setup logging
      if (config.enableLogging) {
        _setupLogging();
      }

      // 4. Setup analytics
      if (config.enableAnalytics) {
        _setupAnalytics();
      }

      // 5. Setup crash reporting
      if (config.enableCrashReporting) {
        _setupCrashReporting();
      }

      _isInitialized = true;

      final logger = ServiceLocator().get<AppLogger>();
      logger.info('App initialization completed', {
        'flavor': config.flavor.toString(),
        'logging': config.enableLogging,
        'analytics': config.enableAnalytics,
      });
    } catch (e) {
      throw AppInitializationException('Failed to initialize app: $e');
    }
  }

  void _setupConfiguration(BuildFlavor flavor) {
    late AppConfig config;

    switch (flavor) {
      case BuildFlavor.development:
        config = createDevConfig();
        break;
      case BuildFlavor.staging:
        config = createStagingConfig();
        break;
      case BuildFlavor.production:
        config = createProductionConfig();
        break;
    }

    ConfigurationService().initialize(config);
  }

  void _setupServiceLocator() {
    final locator = ServiceLocator();

    // Register singletons
    locator.registerSingleton<AppLogger>(AppLogger());
    locator.registerSingleton<AnalyticsService>(AnalyticsService());
  }

  void _setupLogging() {
    final logger = ServiceLocator().get<AppLogger>();
    logger.info('Logging initialized', {});
  }

  void _setupAnalytics() {
    final analytics = ServiceLocator().get<AnalyticsService>();
    analytics.logEvent(AnalyticsEvent(name: 'app_started'));
  }

  void _setupCrashReporting() {
    // Placeholder for crash reporting setup
  }

  /// Reset app (for testing)
  Future<void> reset() async {
    ServiceLocator().reset();
    _isInitialized = false;
  }
}

/// App initialization exception
class AppInitializationException implements Exception {
  final String message;

  AppInitializationException(this.message);

  @override
  String toString() => 'AppInitializationException: $message';
}

/// Initialization guard
class InitializationGuard {
  static void requireInitialized() {
    if (!AppInitializer().isInitialized) {
      throw StateError('App not initialized. Call AppInitializer.initialize() first.');
    }
  }

  static void checkServiceAvailable<T>() {
    requireInitialized();
    final locator = ServiceLocator();
    if (!locator.isRegistered<T>()) {
      throw ServiceNotFoundException('Service $T not registered');
    }
  }
}

/// Extension for safe app initialization
extension AppInitExtension on AppInitializer {
  /// Initialize with default config
  Future<void> initializeDefault([BuildFlavor flavor = BuildFlavor.production]) async {
    await initialize(
      AppInitConfig(
        flavor: flavor,
        enableLogging: flavor != BuildFlavor.production,
        enableAnalytics: true,
      ),
    );
  }
}
