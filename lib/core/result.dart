/// Result type for error handling without exceptions
library result;

/// Result typedef for success/failure
typedef Result<T> = ({bool isSuccess, T? data, String? error});

/// Helper to create success result
Result<T> success<T>(T data) => (isSuccess: true, data: data, error: null);

/// Helper to create failure result
Result<T> failure<T>(String error) => (isSuccess: false, data: null, error: error);

/// Extension on Result for chaining operations
extension ResultExtension<T> on Result<T> {
  /// Map success result to another type
  Result<U> map<U>(U Function(T) fn) {
    if (isSuccess && data != null) {
      try {
        return success(fn(data as T));
      } catch (e) {
        return failure('Mapping failed: $e');
      }
    }
    return failure(error ?? 'Unknown error');
  }

  /// Flatten nested results
  Result<U> flatMap<U>(Result<U> Function(T) fn) {
    if (isSuccess && data != null) {
      try {
        return fn(data as T);
      } catch (e) {
        return failure('FlatMap failed: $e');
      }
    }
    return failure(error ?? 'Unknown error');
  }

  /// Get data or default value
  T? getOrNull() => isSuccess ? data : null;

  /// Get data or throw exception
  T getOrThrow() {
    if (isSuccess && data != null) return data as T;
    throw Exception(error ?? 'Result is failure with no error message');
  }

  /// Execute side effects
  void fold(
    void Function(String) onFailure,
    void Function(T) onSuccess,
  ) {
    if (isSuccess && data != null) {
      onSuccess(data as T);
    } else {
      onFailure(error ?? 'Unknown error');
    }
  }
}
