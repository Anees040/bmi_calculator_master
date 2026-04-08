/// Use case base classes following clean architecture
library usecase;

/// Base use case with input/output
abstract class UseCase<Output, Input> {
  /// Execute the use case
  Future<Output> call(Input input);
}

/// Use case with no input
abstract class UseCaseNoInput<Output> {
  /// Execute the use case
  Future<Output> call();
}

/// Use case with no output
abstract class UseCaseNoOutput<Input> {
  /// Execute the use case
  Future<void> call(Input input);
}

/// Synchronous use case
abstract class SyncUseCase<Output, Input> {
  /// Execute the use case
  Output call(Input input);
}

/// Use case result wrapper
class UseCaseResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final DateTime timestamp;

  UseCaseResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  }) : timestamp = DateTime.now();

  /// Create success result
  factory UseCaseResult.success(T data) => UseCaseResult(
    isSuccess: true,
    data: data,
  );

  /// Create failure result
  factory UseCaseResult.failure(String message) => UseCaseResult(
    isSuccess: false,
    errorMessage: message,
  );

  /// Map data if successful
  UseCaseResult<U> map<U>(U Function(T) mapper) {
    if (isSuccess && data != null) {
      return UseCaseResult<U>.success(mapper(data as T));
    }
    return UseCaseResult<U>.failure(errorMessage ?? 'Unknown error');
  }

  /// Handle both success and error
  R fold<R>(
    R Function(String) onError,
    R Function(T) onSuccess,
  ) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onError(errorMessage ?? 'Unknown error');
  }
}
