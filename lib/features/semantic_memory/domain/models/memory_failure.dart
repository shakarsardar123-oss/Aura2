/// memory_failure.dart
/// AURA Assistant – Step 17: Semantic Memory
///
/// Failure type for the semantic memory subsystem.
/// Follows the CentralPermissionFailure pattern:
///   - Phase enum + factory constructors + private subtypes + mixins
///   - No sealed class (Dart 3 pattern matches but project uses private constructor pattern)
/// Kurdish-first, local-first, privacy-conscious.
library;

/// Phases of the semantic memory lifecycle where a failure may occur.
enum MemoryFailurePhase {
  /// Failure during memory storage (write).
  store,

  /// Failure during memory recall / retrieval.
  recall,

  /// Failure during vector search.
  search,

  /// Failure during memory update.
  update,

  /// Failure during memory deletion / forget.
  forget,

  /// Failure during embedding computation.
  embedding,

  /// Failure during privacy policy check.
  policy,

  /// Failure during integration with agent context.
  integration,

  /// An unknown or unexpected failure.
  unknown,
}

/// Mixin for shared fields across all memory failures.
mixin _MemoryFailureFields on Object {
  MemoryFailurePhase get phase;
  String get message;
  String? get action;
  Object? get cause;
}

/// Private subtype: store failure.
class _StoreFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _StoreFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: recall failure.
class _RecallFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _RecallFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: search failure.
class _SearchFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _SearchFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: update failure.
class _UpdateFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _UpdateFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: forget failure.
class _ForgettingFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _ForgettingFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: embedding failure.
class _EmbeddingFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _EmbeddingFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: policy failure.
class _PolicyFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _PolicyFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: integration failure.
class _IntegrationFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _IntegrationFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Private subtype: unknown failure.
class _UnknownFailure
    with _MemoryFailureFields {
  @override
  final MemoryFailurePhase phase;
  @override
  final String message;
  @override
  final String? action;
  @override
  final Object? cause;

  _UnknownFailure({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });
}

/// Failure type for the semantic memory subsystem.
///
/// Follows the CentralPermissionFailure pattern: private constructor,
/// factory constructors per phase, private subtypes with shared mixin.
///
/// Usage:
/// ```dart
/// final result = memoryManager.recall(query: 'user name');
/// if (result.isError) {
///   final failure = result.error!;
///   // failure.phase == MemoryFailurePhase.recall
///   // failure.message == '...'
/// }
/// ```
class MemoryFailure {
  final MemoryFailurePhase phase;
  final String message;
  final String? action;
  final Object? cause;

  // Private constructor – only factory constructors may create instances.
  MemoryFailure._({
    required this.phase,
    required this.message,
    this.action,
    this.cause,
  });

  // ─── Factory constructors ───────────────────────────────────────────

  /// Failure during storing a memory entry.
  factory MemoryFailure.store({
    String? contentHint,
    String? action,
    Object? cause,
  }) =>
      _StoreFailure(
        phase: MemoryFailurePhase.store,
        message: contentHint != null
            ? 'Failed to store memory: $contentHint'
            : 'Failed to store memory',
        action: action ?? 'retry_store',
        cause: cause,
      );

  /// Failure during recalling memories.
  factory MemoryFailure.recall({
    String? queryHint,
    String? action,
    Object? cause,
  }) =>
      _RecallFailure(
        phase: MemoryFailurePhase.recall,
        message: queryHint != null
            ? 'Failed to recall memory for: $queryHint'
            : 'Failed to recall memory',
        action: action ?? 'retry_recall',
        cause: cause,
      );

  /// Failure during vector search.
  factory MemoryFailure.search({
    String? queryHint,
    String? action,
    Object? cause,
  }) =>
      _SearchFailure(
        phase: MemoryFailurePhase.search,
        message: queryHint != null
            ? 'Failed to search memories for: $queryHint'
            : 'Failed to search memories',
        action: action ?? 'retry_search',
        cause: cause,
      );

  /// Failure during updating a memory entry.
  factory MemoryFailure.update({
    String? idHint,
    String? action,
    Object? cause,
  }) =>
      _UpdateFailure(
        phase: MemoryFailurePhase.update,
        message: idHint != null
            ? 'Failed to update memory: $idHint'
            : 'Failed to update memory',
        action: action ?? 'retry_update',
        cause: cause,
      );

  /// Failure during forgetting / deleting a memory.
  factory MemoryFailure.forget({
    String? idHint,
    String? action,
    Object? cause,
  }) =>
      _ForgettingFailure(
        phase: MemoryFailurePhase.forget,
        message: idHint != null
            ? 'Failed to forget memory: $idHint'
            : 'Failed to forget memory',
        action: action ?? 'retry_forget',
        cause: cause,
      );

  /// Failure during embedding computation.
  factory MemoryFailure.embedding({
    String? action,
    Object? cause,
  }) =>
      _EmbeddingFailure(
        phase: MemoryFailurePhase.embedding,
        message: 'Failed to compute embedding',
        action: action ?? 'retry_embedding',
        cause: cause,
      );

  /// Failure during privacy policy check (content was rejected).
  factory MemoryFailure.policy({
    required String reason,
    String? action,
    Object? cause,
  }) =>
      _PolicyFailure(
        phase: MemoryFailurePhase.policy,
        message: 'Memory rejected by policy: $reason',
        action: action ?? 'review_content',
        cause: cause,
      );

  /// Failure during agent integration (e.g. injecting memories into context).
  factory MemoryFailure.integration({
    String? detail,
    String? action,
    Object? cause,
  }) =>
      _IntegrationFailure(
        phase: MemoryFailurePhase.integration,
        message: detail != null
            ? 'Memory integration failed: $detail'
            : 'Memory integration failed',
        action: action ?? 'retry_integration',
        cause: cause,
      );

  /// Unknown / unexpected failure.
  factory MemoryFailure.unknown({
    required String message,
    String? action,
    Object? cause,
  }) =>
      _UnknownFailure(
        phase: MemoryFailurePhase.unknown,
        message: message,
        action: action ?? 'unknown',
        cause: cause,
      );

  @override
  String toString() => 'MemoryFailure(phase: $phase, message: $message)';
}

/// Type alias for semantic memory results.
typedef MemoryResult<T> = Result<T, MemoryFailure>;
