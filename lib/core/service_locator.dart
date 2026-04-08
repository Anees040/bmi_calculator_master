/// Service locator and dependency injection container
library service_locator;

/// Service factory function
typedef ServiceFactory<T> = T Function();

/// Lazy service factory with singleton pattern
typedef LazyServiceFactory<T> = T Function();

/// Dependency injection container
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, LazyServiceFactory> _factories = {};
  final Map<Type, dynamic> _lazySingletons = {};

  ServiceLocator._();

  /// Get singleton instance
  factory ServiceLocator() => _instance;

  /// Register singleton
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
    _lazySingletons.remove(T);
  }

  /// Register factory
  void registerFactory<T>(ServiceFactory<T> factory) {
    _factories[T] = factory;
  }

  /// Register lazy singleton
  void registerLazySingleton<T>(LazyServiceFactory<T> factory) {
    _factories[T] = factory;
    _lazySingletons.remove(T);
  }

  /// Get service
  T get<T>() {
    // Check singleton
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Check lazy singleton and create if needed
    if (_lazySingletons.containsKey(T)) {
      return _lazySingletons[T] as T;
    }

    // Check factory
    if (_factories.containsKey(T)) {
      final factory = _factories[T] as LazyServiceFactory;
      return factory() as T;
    }

    throw ServiceNotFoundException(
      'Service of type $T is not registered',
    );
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _singletons.containsKey(T) ||
        _factories.containsKey(T) ||
        _lazySingletons.containsKey(T);
  }

  /// Unregister service
  void unregister<T>() {
    _singletons.remove(T);
    _factories.remove(T);
    _lazySingletons.remove(T);
  }

  /// Clear all services
  void reset() {
    _singletons.clear();
    _factories.clear();
    _lazySingletons.clear();
  }

  /// Get all registered types
  Set<Type> getRegisteredTypes() {
    final types = <Type>{
      ..._singletons.keys,
      ..._factories.keys,
      ..._lazySingletons.keys,
    };
    return types;
  }
}

/// Service not found exception
class ServiceNotFoundException implements Exception {
  final String message;

  ServiceNotFoundException(this.message);

  @override
  String toString() => 'ServiceNotFoundException: $message';
}

/// Global service locator getter
T locator<T>() => ServiceLocator().get<T>();
