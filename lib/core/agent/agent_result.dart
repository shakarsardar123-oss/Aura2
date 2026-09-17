/// The final result of an agent execution cycle.
class AgentResult {
  const AgentResult.success({
    required this.response,
    this.stepsCompleted = 0,
    this.toolsUsed = const [],
    this.executionTimeMs = 0,
  })  : errorMessage = null,
        isSuccess = true;

  const AgentResult.failure({
    required this.errorMessage,
    this.stepsCompleted = 0,
    this.toolsUsed = const [],
    this.executionTimeMs = 0,
  })  : response = null,
        isSuccess = false;

  final String? response;
  final String? errorMessage;
  final bool isSuccess;
  final int stepsCompleted;
  final List<String> toolsUsed;
  final int executionTimeMs;

  @override
  String toString() {
    if (isSuccess) {
      return 'AgentResult.success(response: ${response?.substring(0, (response?.length ?? 0).clamp(0, 100))}, steps: $stepsCompleted, tools: $toolsUsed)';
    }
    return 'AgentResult.failure($errorMessage)';
  }
}
