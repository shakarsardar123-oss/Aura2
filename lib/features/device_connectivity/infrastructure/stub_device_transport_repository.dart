/// stub_device_transport_repository.dart
/// AURA Assistant – Step 27: Device Connectivity
///
/// FAIL-CLOSED stub: all operations return denied/unavailable.
/// Replace with real Bluetooth/USB/Wi-Fi transport adapter.
library;

import '../domain/models/device_connection_state.dart';
import '../domain/repositories/device_transport_repository.dart';

class StubDeviceTransportRepository implements DeviceTransportRepository {
  @override
  String get transportType => 'stub';

  @override
  Future<bool> isTransportAvailable() async => false;

  @override
  Future<List<DeviceConnectionState>> scanDevices() async => [];

  @override
  Future<TransportResult> establishConnection(String deviceId) async =>
      TransportResult(success: false, errorMessage: 'Stub: transport unavailable');

  @override
  Future<TransportResult> terminateConnection(String connectionId) async =>
      TransportResult(success: false, errorMessage: 'Stub: transport unavailable');

  @override
  Future<TransportResult> sendRaw(String connectionId, Map<String, dynamic> payload) async =>
      TransportResult(success: false, errorMessage: 'Stub: transport unavailable');
}
