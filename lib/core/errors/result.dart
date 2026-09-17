/// A minimal Result/Either type used across the domain layer to represent
/// an operation that either succeeds with a value of type [S] or fails
/// with a failure of type [F].
sealed class Result<S, F> {
  const Result();

  /// Creates a successful [Result] wrapping [value].
  const factory Result.success(S value) = SuccessResult<S, F>;

  /// Creates a failed [Result] wrapping [failure].
  const factory Result.failure(F failure) = FailureResult<S, F>;

  /// Alias for [Result.failure], used throughout the existing codebase.
  const factory Result.error(F failure) = FailureResult<S, F>;

  /// Applies [onSuccess] if this is a success, or [onFailure] if this is a failure.
  R fold<R>({
    required R Function(S value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is SuccessResult<S, F>) {
      return onSuccess((this as SuccessResult<S, F>).value);
    } else if (this is FailureResult<S, F>) {
      return onFailure((this as FailureResult<S, F>).failure);
    }
    throw StateError('Unknown Result type');
  }
}

/// Success branch implementation.
final class SuccessResult<S, F> extends Result<S, F> {
  const SuccessResult(this.value);
  final S value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessResult<S, F> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.success($value)';
}

/// Failure branch implementation.
final class FailureResult<S, F> extends Result<S, F> {
  const FailureResult(this.failure);
  final F failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<S, F> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Result.failure($failure)';
}

/// Convenience accessors so callers don't need to pattern-match directly.
extension ResultAccessors<S, F> on Result<S, F> {
  /// True if this [Result] represents a successful outcome.
  bool get isSuccess => this is SuccessResult<S, F>;

  /// True if this [Result] represents a failed outcome.
  bool get isFailure => this is FailureResult<S, F>;

  /// Alias for [isFailure], used throughout the existing codebase.
  bool get isError => isFailure;

  /// The success value, or `null` if this is a failure.
  S? get valueOrNull => fold(
        onSuccess: (v) => v,
        onFailure: (_) => null,
      );

  /// The failure value, or `null` if this is a success.
  F? get failureOrNull => fold(
        onSuccess: (_) => null,
        onFailure: (f) => f,
      );

  /// Alias for [valueOrNull], used throughout the existing codebase.
  S? get value => valueOrNull;

  /// Alias for [failureOrNull], used throughout the existing codebase.
  F? get error => failureOrNull;
}
