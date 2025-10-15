import '../errors/failures.dart';

/// Result type for handling success and failure cases
/// Inspired by functional programming patterns
sealed class Result<T> {
  const Result();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is ResultFailure<T>;

  /// Get value if success, throw if failure
  T get value {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    throw Exception('Cannot get value from Failure');
  }

  /// Get failure if failure, throw if success
  Failure get failure {
    if (this is ResultFailure<T>) {
      return (this as ResultFailure<T>).failure;
    }
    throw Exception('Cannot get failure from Success');
  }

  /// Fold pattern matching
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as ResultFailure<T>).failure);
    }
  }

  /// Map transformation
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).data));
    } else {
      return ResultFailure((this as ResultFailure<T>).failure);
    }
  }

  /// FlatMap for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>).data);
    } else {
      return ResultFailure((this as ResultFailure<T>).failure);
    }
  }
}

/// Success case
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

/// Failure case
class ResultFailure<T> extends Result<T> {
  @override
  final Failure failure;

  const ResultFailure(this.failure);
}
