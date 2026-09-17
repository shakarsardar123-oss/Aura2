/// Step 23 — Security Adapter
///
/// Adapter implementing SecurityRepository from Step 19.
///
/// FAIL-CLOSED: UNKNOWN=DENY, ERROR=DENY, UNAVAILABLE=DENY.
/// SecurityVerdict.unknown does NOT exist — only allowed()/denied().

import '../../domain/orchestration_domain.dart';

class SecurityAdapter implements SecurityRepository {
  /// Delegate to the Step 19 security subsystem.
  /// In production this wraps the actual Step 19 API.
  /// For structural validation, we implement the interface contract.

  @override
  Future<SecurityVerdict> check({
    required String action,
    required String toolId,
    required String riskLevel,
  }) async {
    // FAIL-CLOSED: any exception → denied
    try {
      // In production, delegates to Step 19 SecurityService
      // Structural stub: deny by default (fail-closed)
      return SecurityVerdict.denied(reason: 'Security check not implemented');
    } catch (e) {
      // FAIL-CLOSED: error → denied
      return SecurityVerdict.denied(reason: 'Security check error: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    // Structural stub: report as available
    return true;
  }
}
