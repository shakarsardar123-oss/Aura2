/// A lightweight [Either]-style result type.
///
/// [Result] makes error handling explicit by forcing callers to
/// handle both success ([Success]) and failure ([Failure]) paths.
///
/// Usage:
/// ```dart
/// Result<User, StorageFailure> result = repository.getUser(id);
/// result.when(
///   success: (user) => print(user.name),
///   failure: (failure) => print(failure.message),
/// );
/// ```
sealed class Result<S, F> {
  const Result();

  /// Convenience factory for the success branch.
  const factory Result.success(S value) = Success<S, F>;

  /// Convenience factory for the failure branch.
  const factory Result.failure(F failure) = FailureResult<S, F>;

  /// Whether this result represents a successful outcome.
  bool get isSuccess;

  /// Whether this result represents a failure.
  bool get isFailure;

  /// Maps the success value to a new type.
  Result<T, F> map<T>(T Function(S value) mapper);

  /// Maps the failure value to a new type.
  Result<S, E> mapFailure<E>(E Function(F failure) mapper);

  /// Folds the result into a single value of type [T].
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  });

  /// Convenience method for pattern-matching style usage.
  T when<T>({
    required T Function(S value) success,
    required T Function(F failure) failure,
  });

  /// Returns the success value, or throws if this is a failure.
  S getOrElse(S Function() orElse);
}

final class Success<S, F> extends Result<S, F> {
  const Success(this.value);
  final S value;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  Result<T, F> map<T>(T Function(S value) mapper) => Result.success(mapper(value));

  @override
  Result<S, E> mapFailure<E>(E Function(F failure) mapper) => Result.success(value);

  @override
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) =>
      onSuccess(value);

  @override
  T when<T>({
    required T Function(S value) success,
    required T Function(F failure) failure,
  }) =>
      success(value);

  @override
  S getOrElse(S Function() orElse) => value;

  @override
  String toString() => 'Success($value)';
}

final class FailureResult<S, F> extends Result<S, F> {
  const FailureResult(this.failure);
  final F failure;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  Result<T, F> map<T>(T Function(S value) mapper) => Result.failure(failure);

  @override
  Result<S, E> mapFailure<E>(E Function(F failure) mapper) =>
      Result.failure(mapper(failure));

  @override
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) =>
      onFailure(failure);

  @override
  T when<T>({
    required T Function(S value) success,
    required T Function(F failure) failure,
  }) =>
      failure(this.failure);

  @override
  S getOrElse(S Function() orElse) => orElse();

  @override
  String toString() => 'Failure($failure)';
}

/// Additive convenience accessors on [Result] that the existing codebase
/// relies on but which are not part of the sealed class declaration above.
///
/// Adding them as an extension preserves every existing member and behavior
/// of `Result`, `Success`, and `FailureResult` without modification.
extension ResultAccessors<S, F> on Result<S, F> {
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
}
