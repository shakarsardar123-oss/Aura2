import 'failures.dart';
sealed class Result<T, F> {
  const Result();

  const factory Result.success(T value) = SuccessResult<T, F>;
  const factory Result.failure(F failure) = FailureResult<T, F>;
  const factory Result.error(F failure) = FailureResult<T, F>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is SuccessResult<T, F>) {
      return onSuccess((this as SuccessResult<T, F>).value);
    } else if (this is FailureResult<T, F>) {
      return onFailure((this as FailureResult<T, F>).failure);
    }
    throw StateError('Unknown Result type');
  }
}

final class SuccessResult<T, F> extends Result<T, F> {
  const SuccessResult(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessResult<T, F> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.success($value)';
}

final class FailureResult<T, F> extends Result<T, F> {
  const FailureResult(this.failure);
  final F failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T, F> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Result.failure($failure)';
}

extension ResultAccessors<T, F> on Result<T, F> {
  bool get isSuccess => this is SuccessResult<T, F>;
  bool get isFailure => this is FailureResult<T, F>;
  bool get isError => isFailure;

  T? get valueOrNull => fold(
        onSuccess: (v) => v,
        onFailure: (_) => null,
      );

  F? get failureOrNull => fold(
        onSuccess: (_) => null,
        onFailure: (f) => f,
      );

  T? get value => valueOrNull;
  F? get error => failureOrNull;
}

/// Convenience: pattern-match on a [Result] with named callbacks.
extension ResultWhen<T, F> on Result<T, F> {
  R when<R>({
    required R Function(T value) success,
    required R Function(F failure) failure,
  }) {
    return fold(onSuccess: success, onFailure: failure);
  }
}

/// Convenience: unwrap a [Result], falling back to [orElse] on failure.
extension ResultGetOrElse<T, F> on Result<T, F> {
  T getOrElse(T Function() orElse) {
    return fold(onSuccess: (v) => v, onFailure: (_) => orElse());
  }
}

/// Shorthand for constructing a successful [Result] without the
/// `Result.success(...)` prefix — inferred from the call-site context.
Result<T, F> Success<T, F>(T value) => Result<T, F>.success(value);

/// Wraps any [Failure] subtype into a failed [Result] of type [T].
extension FailureToResult<F extends Failure> on F {
  Result<T, F> asFailure<T>() => Result<T, F>.failure(this);
}
