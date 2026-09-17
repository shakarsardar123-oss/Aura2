/// memory_storage_service.dart
/// AURA Assistant – Step 17: Semantic Memory
///
/// Abstract service for persisting semantic memory entries.
/// Follows the abstract service pattern from CentralPermissionService.
/// Kurdish-first, local-first, privacy-conscious.
library;

import '../models/memory_entry.dart';
import '../models/memory_failure.dart';

/// Abstract interface for semantic memory persistence.
///
/// Implementations may use SQLite, Hive, Isar, or in-memory stores.
/// The contract is CRUD + batch operations, all returning
/// [MemoryResult<T>] for consistent error handling.
abstract class MemoryStorageService {
  /// Store a new memory entry. Returns the stored entry (with server-assigned
  /// fields like id/createdAt if needed) or a [MemoryFailure].
  Future<MemoryResult<MemoryEntry>> store(MemoryEntry entry);

  /// Retrieve a memory entry by [id]. Returns null-wrapped if not found.
  Future<MemoryResult<MemoryEntry?>> getById(String id);

  /// Update an existing memory entry. Returns the updated entry or a failure.
  Future<MemoryResult<MemoryEntry>> update(MemoryEntry entry);

  /// Soft-delete (deactivate) a memory entry by [id].
  Future<MemoryResult<void>> deactivate(String id);

  /// Hard-delete a memory entry by [id].
  Future<MemoryResult<void>> delete(String id);

  /// Retrieve all active memory entries, optionally filtered by [type].
  Future<MemoryResult<List<MemoryEntry>>> getAll({MemoryType? type});

  /// Retrieve memory entries created within the given date range.
  Future<MemoryResult<List<MemoryEntry>>> getByDateRange({
    DateTime? from,
    DateTime? to,
  });

  /// Count active memory entries.
  Future<MemoryResult<int>> count({MemoryType? type});

  /// Clear all memory entries (hard delete). Use with caution.
  Future<MemoryResult<void>> clearAll();
}

// Re-export MemoryType for convenience in storage interface.
export '../models/memory_type.dart' show MemoryType;
