/// memory_failure.dart
/// AURA Assistant – Semantic Memory domain failure types.
library;

import 'package:aura_assistant/core/errors/failures.dart';
import 'package:aura_assistant/core/errors/result.dart';

/// Result alias for semantic-memory operations.
typedef MemoryResult<T> = Result<T, MemoryFailure>;

/// The stage of a memory operation where a failure occurred.
enum MemoryFailurePhase {
  store,
  recall,
  search,
  update,
  forget,
  embedding,
  policy,
  integration,
  unknown,
}

/// Failure type for the semantic-memory subsystem.
sealed class MemoryFailure extends Failure {
  const MemoryFailure._({
    required super.message,
    super.code,
    this.cause,
    this.idHint,
    this.action,
  });

  final Object? cause;
  final String? idHint;
  final String? action;

  factory MemoryFailure.store({String? message, Object? cause, String? idHint, String? action}) =>
      _StoreFailure(message: message ?? 'Failed to store memory entry', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.recall({String? message, Object? cause, String? idHint, String? action}) =>
      _RecallFailure(message: message ?? 'Failed to recall memory entry', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.search({String? message, Object? cause, String? idHint, String? action}) =>
      _SearchFailure(message: message ?? 'Failed to search memory', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.update({String? message, Object? cause, String? idHint, String? action}) =>
      _UpdateFailure(message: message ?? 'Failed to update memory entry', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.forget({String? message, Object? cause, String? idHint, String? action}) =>
      _ForgetFailure(message: message ?? 'Failed to forget memory entry', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.embedding({String? message, Object? cause, String? idHint, String? action}) =>
      _EmbeddingFailure(message: message ?? 'Failed to compute memory embedding', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.policy({String? message, Object? cause, String? idHint, String? action}) =>
      _PolicyFailure(message: message ?? 'Memory policy violation', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.integration({String? message, Object? cause, String? idHint, String? action}) =>
      _IntegrationFailure(message: message ?? 'Memory integration failure', cause: cause, idHint: idHint, action: action);

  factory MemoryFailure.unknown({String? message, Object? cause, String? idHint, String? action}) =>
      _UnknownFailure(message: message ?? 'Unknown memory subsystem failure', cause: cause, idHint: idHint, action: action);
}

final class _StoreFailure extends MemoryFailure {
  const _StoreFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _RecallFailure extends MemoryFailure {
  const _RecallFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _SearchFailure extends MemoryFailure {
  const _SearchFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _UpdateFailure extends MemoryFailure {
  const _UpdateFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _ForgetFailure extends MemoryFailure {
  const _ForgetFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _EmbeddingFailure extends MemoryFailure {
  const _EmbeddingFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _PolicyFailure extends MemoryFailure {
  const _PolicyFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _IntegrationFailure extends MemoryFailure {
  const _IntegrationFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}

final class _UnknownFailure extends MemoryFailure {
  const _UnknownFailure({required String message, Object? cause, String? idHint, String? action})
      : super._(message: message, cause: cause, idHint: idHint, action: action);
}
