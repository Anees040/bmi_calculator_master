/// Retry policy and circuit breaker pattern
library retry_policy;

import 'dart:async';

/// Retry policy configuration
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool randomizeDelay;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 100),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.randomizeDelay = true,
  });

  /// Execute function with retry logic
  Future<T> execute<T>(Future<T> Function() fn) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;

        final jitter =
            randomizeDelay ? Duration(milliseconds: (delay.inMilliseconds * 0.1).toInt()) : Duration.zero;
        final nextDelay = delay + jitter;
        final cappedDelay =
            nextDelay > maxDelay ? maxDelay : nextDelay;

        await Future.delayed(cappedDelay);
        delay = nextDelay;
      }
    }
    throw TimeoutException('Exceeded max retry attempts');
  }

  /// Get calculated delay for attempt
  Duration getDelayForAttempt(int attempt) {
    var delay = initialDelay;
    for (int i = 0; i < attempt; i++) {
      delay = Duration(
        milliseconds: (delay.inMilliseconds * backoffMultiplier).toInt(),
      );
    }
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// Circuit breaker states
enum CircuitBreakerState { closed, open, halfOpen }

/// Circuit breaker for failing operations
class CircuitBreaker<T> {
  final int failureThreshold;
  final Duration resetTimeout;
  
  late CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 60),
  });

  /// Get current state
  CircuitBreakerState get state => _state;

  /// Execute with circuit breaker protection
  Future<T> execute(Future<T> Function() fn) async {
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitBreakerState.halfOpen;
      } else {
        throw Exception('Circuit breaker is OPEN');
      }
    }

    try {
      final result = await fn();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;
    return DateTime.now().difference(_lastFailureTime!) >= resetTimeout;
  }

  /// Reset circuit breaker
  void reset() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _lastFailureTime = null;
  }
}
