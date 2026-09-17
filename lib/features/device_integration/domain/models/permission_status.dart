/// permission_status.dart
///
/// Permission vocabulary and the abstract permission-manager contract for the
/// `device_integration` feature.
///
/// RECOVERED in P1-RECOVERY step R2 from the behaviour pinned by
/// `test/features/device_integration/permission_manager_test.dart`.
library;

import '../../../../core/errors/result.dart';
import 'device_integration_failure.dart';

/// Lifecycle state of a single permission.
enum PermissionStatus {
  /// The permission has never been asked for.
  notRequested,

  /// The user granted the permission.
  granted,

  /// The user refused, but may be asked again.
  denied,

  /// The user refused permanently; only the system settings screen can change
  /// this.
  permanentlyDenied,
}

/// The device capabilities the feature needs in order to observe and drive the
/// screen.
enum DevicePermission {
  /// Accessibility service — required to dispatch input events.
  accessibility,

  /// "Draw over other apps" — required for the floating overlay.
  overlay,

  /// Screen capture / media projection — required to read the screen.
  screenCapture,
}

/// The outcome of checking or requesting a set of permissions.
class PermissionResult {
  const PermissionResult({required this.statuses});

  /// Status per requested permission.
  final Map<DevicePermission, PermissionStatus> statuses;

  /// True only when every requested permission is [PermissionStatus.granted].
  bool get allGranted =>
      statuses.isNotEmpty &&
      statuses.values.every((s) => s == PermissionStatus.granted);

  /// Permissions the user actively refused.
  ///
  /// [PermissionStatus.notRequested] is intentionally *not* counted as denied:
  /// nothing has been refused yet, it simply has not been asked.
  List<DevicePermission> get denied => statuses.entries
      .where((e) =>
          e.value == PermissionStatus.denied ||
          e.value == PermissionStatus.permanentlyDenied,)
      .map((e) => e.key)
      .toList(growable: false);

  /// Whether at least one permission is permanently denied, meaning the user
  /// must be sent to the system settings screen.
  bool get hasPermanentlyDenied =>
      statuses.values.any((s) => s == PermissionStatus.permanentlyDenied);

  @override
  String toString() => 'PermissionResult($statuses)';
}

/// Contract for querying and requesting device permissions.
///
/// Implementations must be fail-closed: when the real platform state cannot be
/// determined they report a non-granted status rather than assuming success.
abstract class PermissionManager {
  /// Current status of a single permission.
  Future<PermissionStatus> checkStatus(DevicePermission permission);

  /// Prompts the user for [permissions] and reports the resulting statuses.
  Future<PermissionResult> request(Iterable<DevicePermission> permissions);

  /// Current status of every permission the feature can use, without prompting.
  Future<PermissionResult> checkAll();

  /// Prompts the user for every permission the feature can use.
  Future<PermissionResult> requestAll();

  /// Opens the system settings page for this app.
  ///
  /// Fails with a [DeviceIntegrationFailure] in the permission phase when the
  /// settings screen cannot be opened.
  Future<Result<void, DeviceIntegrationFailure>> openSettings();
}
