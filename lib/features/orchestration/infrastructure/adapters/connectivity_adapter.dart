/// Step 23 — Connectivity Adapter
///
/// Adapter implementing ConnectivityRepository.
///
/// ConnectivityRepository: isOnline()→Future<bool>,
///   onConnectivityChanged→Stream<bool>.
/// NO isAvailable() — not in ConnectivityRepository interface.
/// Must implement onConnectivityChanged stream.

import '../../domain/orchestration_domain.dart';

class ConnectivityAdapter implements ConnectivityRepository {
  /// Stream controller for connectivity changes.
  final Stream<bool> _connectivityStream;

  /// Create with an optional connectivity change stream.
  ConnectivityAdapter({Stream<bool>? connectivityStream})
      : _connectivityStream = connectivityStream ?? const Stream.empty();

  @override
  Future<bool> isOnline() async {
    // In production, delegates to device connectivity API
    // Structural stub: assume online
    return true;
  }

  @override
  Stream<bool> get onConnectivityChanged => _connectivityStream;
}
