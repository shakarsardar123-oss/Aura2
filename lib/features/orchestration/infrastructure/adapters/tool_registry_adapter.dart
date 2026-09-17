/// Step 23 — Tool Registry Adapter
///
/// Adapter implementing ToolRegistryRepository from Step 20.
///
/// Uses discover(category, userRequest) → List<DiscoveredTool>
/// and selectBest(List<DiscoveredTool>, userRequest) → DiscoveredTool?.
/// findBestMatch(String intent) removed — does NOT match interface.

import '../../domain/orchestration_domain.dart';

class ToolRegistryAdapter implements ToolRegistryRepository {
  /// Delegate to the Step 20 tool registry subsystem.

  @override
  Future<List<DiscoveredTool>> discover(
    String? category,
    String userRequest,
  ) async {
    try {
      // In production, delegates to Step 20 ToolRegistryService
      // Structural stub: return empty list (no tools discovered)
      return [];
    } catch (e) {
      // FAIL-CLOSED: error → empty list
      return [];
    }
  }

  @override
  Future<DiscoveredTool?> selectBest(
    List<DiscoveredTool> discovered,
    String userRequest,
  ) async {
    try {
      if (discovered.isEmpty) return null;
      // In production, delegates to Step 20 ranking/scoring
      // Structural stub: return first discovered tool
      return discovered.first;
    } catch (e) {
      // FAIL-CLOSED: error → null (no tool selected)
      return null;
    }
  }

  @override
  Future<DiscoveredTool?> get(String toolId) async {
    try {
      // In production, delegates to Step 20
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DiscoveredTool>> allTools() async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<DiscoveredTool>> byCategory(String category) async {
    try {
      return [];
    } catch (e) {
      return [];
    }
  }
}
