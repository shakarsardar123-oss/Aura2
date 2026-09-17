/// vision_tool.dart
/// AURA Assistant – Step 22: Tool Execution System
///
/// VisionTool — handles image/camera/vision interactions.
/// Category: vision
/// Risk: high (camera access, image processing)
/// Offline: partial (local processing, cloud OCR needs network)
/// Voice-safe: no (visual output)
library;

import '../../domain/models/tool_input.dart';
import '../../domain/models/tool_output.dart';
import '../../domain/models/tool_execution_context.dart';
import '../../domain/services/tool_interface.dart';

class VisionTool extends Tool {
  @override
  String get id => 'aura.tool.vision';

  @override
  String get name => 'Vision Assistant';

  @override
  ToolCategory get category => ToolCategory.vision;

  @override
  String get description =>
      'Image capture, camera access, OCR, visual analysis';

  @override
  String get version => '1.0.0';

  @override
  List<String> get requiredPermissions => [
        'vision.camera',
        'vision.gallery',
        'vision.ocr',
      ];

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.high;

  @override
  bool get requiresConfirmation => true; // Camera/gallery access needs confirmation

  @override
  bool get supportsOffline => true; // Local processing available

  @override
  bool get isVoiceSafe => false; // Visual output

  @override
  int get defaultTimeoutMs => 15000;

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
          errorMessage: 'Invalid vision input',
        );
      }

      final action = input.sanitizedParams['action'] as String? ?? 'analyze';

      // Camera/gallery access requires confirmation
      if (_requiresUserConfirmation(action) && context.confirmationDenied) {
        return ToolOutput.denied(
          data: {},
          errorMessage: 'Vision action requires user confirmation',
        );
      }

      switch (action) {
        case 'capture':
          return ToolOutput.success(data: {
            'action': 'capture',
            'status': 'captured',
            'toolId': id,
          });
        case 'analyze':
          return ToolOutput.success(data: {
            'action': 'analyze',
            'result': 'analysis_complete',
            'toolId': id,
          });
        case 'ocr':
          return ToolOutput.success(data: {
            'action': 'ocr',
            'text': '', // OCR result
            'toolId': id,
          });
        case 'gallery':
          return ToolOutput.success(data: {
            'action': 'gallery',
            'images': [],
            'toolId': id,
          });
        default:
          return ToolOutput.failure(
            data: {},
            errorMessage: 'Unknown vision action: $action',
          );
      }
    } on ToolExecutionCancelledException {
      return ToolOutput.cancelled(data: {});
    } catch (e) {
      return ToolOutput.failure(data: {}, errorMessage: 'Vision error');
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
  String describe() => 'ئامرازێکی بینین بۆ وێنە، کامێرا و شیکردنەوەی بینراو'; // Kurdish Sorani

  @override
  void cancel() {}

  bool _requiresUserConfirmation(String action) =>
      const ['capture', 'gallery'].contains(action);

  static const _validActions = ['capture', 'analyze', 'ocr', 'gallery'];
}
