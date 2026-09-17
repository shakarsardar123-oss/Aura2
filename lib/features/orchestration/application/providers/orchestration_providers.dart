/// Step 23 — Orchestration Providers
///
/// Dependency injection wiring for the orchestration feature.
/// Creates repository interface instances from concrete adapters,
/// wires them into the AgentOrchestrator and OrchestrationUseCase.
///
/// FAIL-CLOSED: all adapters implement their repository interface.
/// Type annotations use interfaces, not concrete classes.

import '../../domain/orchestration_domain.dart';
import '../localization_service.dart';
import '../orchestrator/agent_orchestrator.dart';
import '../usecases/orchestration_use_case.dart';
import '../../infrastructure/adapters/agent_engine_adapter.dart';
import '../../infrastructure/adapters/memory_adapter.dart';
import '../../infrastructure/adapters/tool_registry_adapter.dart';
import '../../infrastructure/adapters/security_adapter.dart';
import '../../infrastructure/adapters/permission_adapter.dart';
import '../../infrastructure/adapters/confirmation_adapter.dart';
import '../../infrastructure/adapters/tool_execution_adapter.dart';
import '../../infrastructure/adapters/recovery_adapter.dart';
import '../../infrastructure/adapters/connectivity_adapter.dart';
import '../../infrastructure/adapters/audit_adapter.dart';
import '../../infrastructure/adapters/voice_adapter.dart';
import '../../infrastructure/adapters/screen_adapter.dart';

class OrchestrationProviders {
  /// Create a fully wired AgentOrchestrator.
  ///
  /// Takes 10 repository adapters + AppLocalizationService.
  /// voice/screen adapters are NOT passed to orchestrator constructor.
  AgentOrchestrator createOrchestrator({
    required AgentEngineAdapter agentEngine,
    required MemoryAdapter memory,
    required ToolRegistryAdapter toolRegistry,
    required SecurityAdapter security,
    required PermissionAdapter permission,
    required ConfirmationAdapter confirmation,
    required ToolExecutionAdapter execution,
    required RecoveryAdapter recovery,
    required ConnectivityRepository connectivity,
    required AuditRepository audit,
    required AppLocalizationService localization,
  }) {
    return AgentOrchestrator(
      agentEngine: agentEngine,
      memory: memory,
      toolRegistry: toolRegistry,
      security: security,
      permission: permission,
      confirmation: confirmation,
      execution: execution,
      recovery: recovery,
      connectivity: connectivity,
      audit: audit,
      localization: localization,
    );
  }

  /// Create a fully wired OrchestrationUseCase.
  OrchestrationUseCase createUseCase({
    required AgentOrchestrator orchestrator,
  }) {
    return OrchestrationUseCase(orchestrator: orchestrator);
  }

  /// Convenience: create all providers at once.
  /// Returns a record with orchestrator and useCase.
  ({AgentOrchestrator orchestrator, OrchestrationUseCase useCase}) createAll({
    required AgentEngineAdapter agentEngine,
    required MemoryAdapter memory,
    required ToolRegistryAdapter toolRegistry,
    required SecurityAdapter security,
    required PermissionAdapter permission,
    required ConfirmationAdapter confirmation,
    required ToolExecutionAdapter execution,
    required RecoveryAdapter recovery,
    required ConnectivityRepository connectivity,
    required AuditRepository audit,
    required AppLocalizationService localization,
  }) {
    final orchestrator = createOrchestrator(
      agentEngine: agentEngine,
      memory: memory,
      toolRegistry: toolRegistry,
      security: security,
      permission: permission,
      confirmation: confirmation,
      execution: execution,
      recovery: recovery,
      connectivity: connectivity,
      audit: audit,
      localization: localization,
    );
    final useCase = createUseCase(orchestrator: orchestrator);
    return (orchestrator: orchestrator, useCase: useCase);
  }
}
