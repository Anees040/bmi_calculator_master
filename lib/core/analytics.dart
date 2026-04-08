/// Analytics event tracking service
library analytics;

/// Trackable event
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    this.parameters = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'AnalyticsEvent($name, $parameters)';
}

/// Analytics service interface
abstract class IAnalyticsService {
  Future<void> logEvent(AnalyticsEvent event);
  Future<void> logError(String code, String message);
  Future<void> logNavigation(String screenName);
  Future<void> logException(Exception exception);
}

/// Default analytics implementation (local logging)
class AnalyticsService implements IAnalyticsService {
  final List<AnalyticsEvent> _events = [];

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    _events.add(event);
  }

  @override
  Future<void> logError(String code, String message) async {
    await logEvent(AnalyticsEvent(
      name: 'error',
      parameters: {'code': code, 'message': message},
    ));
  }

  @override
  Future<void> logNavigation(String screenName) async {
    await logEvent(AnalyticsEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
    ));
  }

  @override
  Future<void> logException(Exception exception) async {
    await logEvent(AnalyticsEvent(
      name: 'exception',
      parameters: {'message': exception.toString()},
    ));
  }

  /// Get logged events
  List<AnalyticsEvent> getEvents() => List.unmodifiable(_events);

  /// Clear event history
  void clearEvents() => _events.clear();
}
