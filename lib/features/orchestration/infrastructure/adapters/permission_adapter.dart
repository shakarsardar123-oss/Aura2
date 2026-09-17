/// Step 23 — Permission Adapter
///
/// Adapter implementing PermissionRepository from Step 16.
///
/// FAIL-CLOSED: UNKNOWN=DENY, ERROR=DENY, UNAVAILABLE=DENY.
/// PermissionVerdict.unknown does NOT exist — only granted()/denied().

import '../../domain/orchestration_domain.dart';

class PermissionAdapter implements PermissionRepository {
  /// Delegate to the Step 16 permission subsystem.
  /// In production this wraps the actual Step 16 API.
  /// For structural validation, we implement the interface contract.

  @override
  Future<PermissionVerdict> check({
    required String permission,
    required String toolId,
  }) async {
    // FAIL-CLOSED: any exception → denied
    try {
      // In production, delegates to Step 16 PermissionService
      // Structural stub: deny by default (fail-closed)
      return PermissionVerdict.denied(reason: 'Permission not granted');
    } catch (e) {
      return PermissionVerdict.denied(reason: 'Permission check error: $e');
    }
  }

  @override
  Future<PermissionVerdict> request({
    required String permission,
    required String toolId,
  }) async {
    // FAIL-CLOSED: any exception → denied
    try {
      // In production, delegates to Step 16 permission request flow
      // Structural stub: deny by default
      return PermissionVerdict.denied(reason: 'Permission request not implemented');
    } catch (e) {
      return PermissionVerdict.denied(reason: 'Permission request error: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    // Structural stub: report as available
    return true;
  }
}
