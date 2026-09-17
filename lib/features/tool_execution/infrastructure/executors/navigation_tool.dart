/// navigation_tool.dart
/// AURA Assistant – Step 22: Tool Execution System
///
/// NavigationTool — handles navigation/routing interactions.
/// Category: navigation
/// Risk: medium (location access, route changes)
/// Offline: partial (cached maps, navigation needs network)
/// Voice-safe: yes (natural for voice navigation)
library;

import '../../domain/models/tool_input.dart';
import '../../domain/models/tool_output.dart';
import '../../domain/models/tool_execution_context.dart';
import '../../domain/services/tool_interface.dart';

class NavigationTool extends Tool {
  @override
  String get id => 'aura.tool.navigation';

  @override
  String get name => 'Navigation';

  @override
  ToolCategory get category => ToolCategory.navigation;

  @override
  String get description =>
      'Navigate routes, get directions, access location services';

  @override
  String get version => '1.0.0';

  @override
  List<String> get requiredPermissions => [
        'navigation.location',
        'navigation.maps',
      ];

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.medium;

  @override
  bool get requiresConfirmation => true; // Location sharing needs confirmation

  @override
  bool get supportsOffline => true; // Cached maps available

  @override
  bool get isVoiceSafe => true; // Voice navigation is primary use case

  @override
  int get defaultTimeoutMs => 10000;

  bool _isExecuting = false;

  @override
  bool get isExecuting => _isExecuting;

  @override
  Future<ToolOutput> execute(ToolInput input, ToolExecutionContext context) async {
    _isExecuting = true;
    try {
      context.throwIfCancelled();
      if (!input.isValid) {
        return ToolOutput.failure(
          data: {},
          errorMessage: 'Invalid navigation input',
        );
      }

      final action = input.sanitizedParams['action'] as String? ?? 'status';

      switch (action) {
        case 'navigate':
          final destination = input.sanitizedParams['destination'] as String?;
          if (destination == null) {
            return ToolOutput.failure(
              data: {},
              errorMessage: 'Destination required for navigation',
            );
          }
          return ToolOutput.success(data: {
            'action': 'navigate',
            'destination': destination,
            'status': 'navigating',
            'toolId': id,
          });

        case 'location':
          return ToolOutput.success(data: {
            'action': 'location',
            'latitude': 0.0,
            'longitude': 0.0,
            'toolId': id,
          });

        case 'route':
          return ToolOutput.success(data: {
            'action': 'route',
            'steps': [],
            'toolId': id,
          });

        case 'nearby':
          return ToolOutput.success(data: {
            'action': 'nearby',
            'places': [],
            'toolId': id,
          });

        default:
          return ToolOutput.failure(
            data: {},
            errorMessage: 'Unknown navigation action: $action',
          );
      }
    } on ToolExecutionCancelledException {
      return ToolOutput.cancelled(data: {});
    } catch (e) {
      return ToolOutput.failure(data: {}, errorMessage: 'Navigation error');
    } finally {
      _isExecuting = false;
    }
  }

  @override
  ToolInput validate(Map<String, dynamic> params) {
    final action = params['action'] as String?;
    if (action == null || !_validActions.contains(action)) {
      return ToolInput.invalid(
        rawParams: params,
        issues: [ToolInputValidationIssue(
          field: 'action',
          message: 'Valid actions: ${_validActions.join(", ")}',
          severity: ValidationIssueSeverity.error,
        )],
      );
    }
    return ToolInput.valid(
      rawParams: params,
      sanitizedParams: Map<String, dynamic>.from(params),
    );
  }

  @override
  String describe() => 'ئامرازێکی ڕێنمایی بۆ ڕێنمایی، ئاراستە و شوێن'; // Kurdish Sorani

  @override
  void cancel() {}

  static const _validActions = ['navigate', 'location', 'route', 'nearby'];
}
