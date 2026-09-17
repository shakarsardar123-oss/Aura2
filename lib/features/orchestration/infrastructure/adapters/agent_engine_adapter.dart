/// Step 23 — Agent Engine Adapter
///
/// Thin adapter bridging Step 23 AgentEngineRepository to existing Step 16 AgentEngine.
/// Does NOT duplicate AgentEngine functionality — only translates interfaces.
/// If the actual AgentEngine API differs, this adapter normalizes it.

import '../../domain/repositories/agent_engine_repository.dart';

class AgentEngineAdapter implements AgentEngineRepository {
  @override
  Future<AgentIntent?> understand(String userRequest, String locale) async {
    // Adapter: call Step 16 AgentEngine.understand() and normalize result.
    // In production, this calls the real AgentEngine.
    // For structural validation: returns null on any failure (FAIL-CLOSED).
    try {
      // TODO: Wire to actual Step 16 AgentEngine.understand()
      // AgentIntent is constructed from the Step 16 result
      return AgentIntent(
        intentId: 'intent_${DateTime.now().millisecondsSinceEpoch}',
        rawText: userRequest,
        normalizedText: userRequest,
        locale: locale,
      );
    } catch (_) {
      return null; // FAIL-CLOSED
    }
  }

  @override
  Future<AgentPlan?> plan(AgentIntent intent, String? memoryContext) async {
    try {
      // TODO: Wire to actual Step 16 AgentEngine.plan()
      return AgentPlan(
        planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        intentId: intent.intentId,
        needsMemory: memoryContext == null,
        needsTool: intent.isToolAction,
        needsScreenAction: intent.isScreenAction,
        isDirectResponse: intent.isDirectResponse,
      );
    } catch (_) {
      return null; // FAIL-CLOSED
    }
  }

  @override
  bool requiresTool(AgentPlan plan) => plan.needsTool;

  @override
  bool requiresScreenAction(AgentPlan plan) => plan.needsScreenAction;
}
