sealed class Result<S, F> {
  const Result();

  const factory Result.success(S value) = SuccessResult<S, F>;
  const factory Result.failure(F failure) = FailureResult<S, F>;
  const factory Result.error(F failure) = FailureResult<S, F>;

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

extension ResultAccessors<S, F> on Result<S, F> {
  bool get isSuccess => this is SuccessResult<S, F>;
  bool get isFailure => this is FailureResult<S, F>;
  bool get isError => isFailure;

  S? get valueOrNull => fold(
        onSuccess: (v) => v,
        onFailure: (_) => null,
      );

  F? get failureOrNull => fold(
        onSuccess: (_) => null,
        onFailure: (f) => f,
      );

  S? get value => valueOrNull;
  F? get error => failureOrNull;
}
