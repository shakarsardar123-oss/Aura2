/// media_tool.dart
/// AURA Assistant – Step 22: Tool Execution System
///
/// MediaTool — handles media playback/recording interactions.
/// Category: media
/// Risk: medium (microphone/recording access)
/// Offline: yes (local playback)
/// Voice-safe: partial (playback yes, recording needs confirmation)
library;

import '../../domain/models/tool_input.dart';
import '../../domain/models/tool_output.dart';
import '../../domain/models/tool_execution_context.dart';
import '../../domain/services/tool_interface.dart';

class MediaTool extends Tool {
  @override
  String get id => 'aura.tool.media';

  @override
  String get name => 'Media Control';

  @override
  ToolCategory get category => ToolCategory.media;

  @override
  String get description =>
      'Audio/video playback, recording, media library access';

  @override
  String get version => '1.0.0';

  @override
  List<String> get requiredPermissions => [
        'media.audio.play',
        'media.audio.record',
        'media.video.play',
      ];

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.medium;

  @override
  bool get requiresConfirmation => true; // Recording needs confirmation

  @override
  bool get supportsOffline => true;

  @override
  bool get isVoiceSafe => false; // Visual output for video

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
        return ToolOutput.failure(data: {}, errorMessage: 'Invalid media input');
      }

      final action = input.sanitizedParams['action'] as String? ?? 'play';

      if (_isRecordingAction(action) && context.confirmationDenied) {
        return ToolOutput.denied(
          data: {},
          errorMessage: 'Media recording requires confirmation',
        );
      }

      switch (action) {
        case 'play':
        case 'pause':
        case 'stop':
        case 'seek':
          return ToolOutput.success(data: {
            'action': action,
            'status': 'ok',
            'toolId': id,
          });
        case 'record':
          return ToolOutput.success(data: {
            'action': 'record',
            'status': 'recording',
            'toolId': id,
          });
        case 'library':
          return ToolOutput.success(data: {
            'action': 'library',
            'items': [],
            'toolId': id,
          });
        default:
          return ToolOutput.failure(
            data: {},
            errorMessage: 'Unknown media action: $action',
          );
      }
    } on ToolExecutionCancelledException {
      return ToolOutput.cancelled(data: {});
    } catch (e) {
      return ToolOutput.failure(data: {}, errorMessage: 'Media error');
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
  String describe() => 'ئامرازێکی میدیایی بۆ لێدان، تۆمارکردن و گەشتکردن بە میدیاکان'; // Kurdish Sorani

  @override
  void cancel() {}

  bool _isRecordingAction(String action) =>
      const ['record', 'record_video'].contains(action);

  static const _validActions = [
    'play', 'pause', 'stop', 'seek', 'record', 'library'
  ];
}
