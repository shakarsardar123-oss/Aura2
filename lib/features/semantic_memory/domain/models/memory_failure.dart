import 'package:aura_assistant/core/errors/failure.dart';

sealed class MemoryFailure extends Failure {
  const MemoryFailure._(super.message, [super.cause]);

  const factory MemoryFailure.store(String message, [Object? cause]) =
      _StoreFailure;
  const factory MemoryFailure.recall(String message, [Object? cause]) =
      _RecallFailure;
  const factory MemoryFailure.search(String message, [Object? cause]) =
      _SearchFailure;
  const factory MemoryFailure.update(String message, [Object? cause]) =
      _UpdateFailure;
  const factory MemoryFailure.forgetting(String message, [Object? cause]) =
      _ForgettingFailure;
  const factory MemoryFailure.embedding(String message, [Object? cause]) =
      _EmbeddingFailure;
  const factory MemoryFailure.policy(String message, [Object? cause]) =
      _PolicyFailure;
  const factory MemoryFailure.integration(String message, [Object? cause]) =
      _IntegrationFailure;
  const factory MemoryFailure.unknown(String message, [Object? cause]) =
      _UnknownFailure;
}

final class _StoreFailure extends MemoryFailure {
  const _StoreFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _RecallFailure extends MemoryFailure {
  const _RecallFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _SearchFailure extends MemoryFailure {
  const _SearchFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _UpdateFailure extends MemoryFailure {
  const _UpdateFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _ForgettingFailure extends MemoryFailure {
  const _ForgettingFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _EmbeddingFailure extends MemoryFailure {
  const _EmbeddingFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _PolicyFailure extends MemoryFailure {
  const _PolicyFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _IntegrationFailure extends MemoryFailure {
  const _IntegrationFailure(String message, [Object? cause]) : super._(message, cause);
}

final class _UnknownFailure extends MemoryFailure {
  const _UnknownFailure(String message, [Object? cause]) : super._(message, cause);
}
