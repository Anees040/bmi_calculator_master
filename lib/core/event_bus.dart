/// Event bus for cross-component communication
library event_bus;

/// Base event class
abstract class AppEvent {
  final DateTime timestamp;

  AppEvent() : timestamp = DateTime.now();
}

/// Event listener callback
typedef EventListener<T extends AppEvent> = void Function(T event);

/// Event bus for publish-subscribe pattern
class EventBus {
  static final EventBus _instance = EventBus._();

  final Map<Type, List<dynamic>> _listeners = {};

  EventBus._();

  /// Get singleton instance
  factory EventBus() => _instance;

  /// Subscribe to event
  void on<T extends AppEvent>(EventListener<T> listener) {
    if (!_listeners.containsKey(T)) {
      _listeners[T] = [];
    }
    _listeners[T]!.add(listener);
  }

  /// Unsubscribe from event
  void off<T extends AppEvent>(EventListener<T> listener) {
    _listeners[T]?.remove(listener);
  }

  /// Publish event
  void emit<T extends AppEvent>(T event) {
    final listeners = _listeners[T];
    if (listeners != null) {
      for (final listener in List.from(listeners)) {
        (listener as EventListener<T>)(event);
      }
    }
  }

  /// Clear all listeners
  void clearAll() => _listeners.clear();

  /// Clear listeners for type
  void clear<T extends AppEvent>() => _listeners.remove(T);

  /// Get listener count for type
  int getListenerCount<T extends AppEvent>() =>
      _listeners[T]?.length ?? 0;
}

// Domain events
class BMICalculatedEvent extends AppEvent {
  final double bmi;
  final String category;
  final DateTime calculatedAt;

  BMICalculatedEvent({
    required this.bmi,
    required this.category,
    required this.calculatedAt,
  });
}

class RepositoryUpdatedEvent extends AppEvent {
  final String entityType;
  final String operation; // 'create', 'update', 'delete'

  RepositoryUpdatedEvent({
    required this.entityType,
    required this.operation,
  });
}

class SyncRequestedEvent extends AppEvent {
  final String? specificType;

  SyncRequestedEvent({this.specificType});
}

class UserAuthenticatedEvent extends AppEvent {
  final String userId;
  final String email;

  UserAuthenticatedEvent({
    required this.userId,
    required this.email,
  });
}

class ErrorOccurredEvent extends AppEvent {
  final String message;
  final String? stackTrace;
  final String severity; // 'low', 'medium', 'high'

  ErrorOccurredEvent({
    required this.message,
    this.stackTrace,
    this.severity = 'medium',
  });
}
