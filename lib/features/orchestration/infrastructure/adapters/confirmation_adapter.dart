/// Step 23 — Confirmation Adapter
///
/// Adapter implementing ConfirmationRepository from Step 20.
///
/// FAIL-CLOSED: UNKNOWN=DENY, ERROR=DENY, UNAVAILABLE=DENY.
/// Uses checkAndObtain() → ConfirmationVerdict (not getMode/requestConfirmation → bool).

import '../../domain/orchestration_domain.dart';

class ConfirmationAdapter implements ConfirmationRepository {
  /// Delegate to the Step 20 confirmation subsystem.

  @override
  Future<ConfirmationVerdict> checkAndObtain({
    required String toolId,
    required String riskLevel,
    required String userRequest,
  }) async {
    // FAIL-CLOSED: any exception → denied
    try {
      // In production, delegates to Step 20 ConfirmationService
      // Structural stub: based on risk level
      if (riskLevel == 'low') {
        return ConfirmationVerdict.granted(
    // AUTO_APPROVE_WARNING: Auto-approve bypasses user confirmation. Dev/test only. Production MUST require explicit approval.
          mode: ConfirmationMode.autoApprove,
        );
      }
      // medium/high risk → deny by default (fail-closed)
      return ConfirmationVerdict.denied(
        reason: 'Confirmation required but not obtained',
        mode: ConfirmationMode.requireConfirmation,
      );
    } catch (e) {
      return ConfirmationVerdict.denied(
        reason: 'Confirmation check error: $e',
        mode: ConfirmationMode.denyAll,
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    // Structural stub: report as available
    return true;
  }
}
