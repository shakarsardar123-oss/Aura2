/// Step 23 — Audit Adapter
///
/// Adapter implementing AuditRepository.
///
/// AuditRepository: record({required action, required description,
///   required timestamp, details?})→Future<void>,
///   forRequest(String requestId)→Future<List<AuditLogEntry>>.
/// NO isAvailable() — not in AuditRepository interface.
/// Uses record() with named params (not positional log()).

import '../../domain/orchestration_domain.dart';

class AuditAdapter implements AuditRepository {
  /// In-memory audit log for structural validation.
  final List<AuditLogEntry> _entries = [];

  @override
  Future<void> record({
    required String action,
    required String description,
    required DateTime timestamp,
    Map<String, dynamic>? details,
  }) async {
    _entries.add(AuditLogEntry(
      action: action,
      description: description,
      timestamp: timestamp,
      details: details,
    ));
  }

  @override
  Future<List<AuditLogEntry>> forRequest(String requestId) async {
    return _entries
        .where((e) => e.details?['requestId'] == requestId)
        .toList();
  }
}
