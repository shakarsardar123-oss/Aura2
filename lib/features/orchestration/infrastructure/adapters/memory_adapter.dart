/// Step 23 — Memory Adapter
///
/// Thin adapter bridging Step 23 MemoryRepository to existing Step 17 Semantic Memory.
/// memoryContext is String? not Map (per Step 17 contract).
/// Memory failure → null (safe degradation, does NOT block orchestration).

import '../../domain/repositories/memory_repository.dart';

class MemoryAdapter implements MemoryRepository {
  @override
  Future<String?> lookup(String userRequest, String locale) async {
    try {
      // TODO: Wire to actual Step 17 Semantic Memory lookup
      // Returns String? per Step 17 contract
      return null; // Default: no memory context (safe degradation)
    } catch (_) {
      return null; // FAIL-CLOSED: memory failure → null
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // TODO: Wire to actual Step 17 availability check
      return true;
    } catch (_) {
      return false; // FAIL-CLOSED
    }
  }
}
