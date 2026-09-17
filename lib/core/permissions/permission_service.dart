import 'package:permission_handler/permission_handler.dart' as ph;

import '../errors/failures.dart';
import '../errors/result.dart';

/// Service for managing runtime permissions.
class PermissionService {
  PermissionService();

  /// Requests a single permission and returns the result.
  Future<Result<bool, PermissionFailure>> requestPermission(ph.Permission permission) async {
    try {
      final status = await permission.request();

      if (status.isGranted) {
        return Result.success(true);
      }

      if (status.isPermanentlyDenied) {
        return Result.failure(PermissionFailure(
          message: 'Permission ${permission.toString()} permanently denied. Please enable it in app settings.',
          code: 'PERMISSION_PERMANENTLY_DENIED',
          permission: permission.toString(),
        ));
      }

      return Result.failure(PermissionFailure(
        message: 'Permission ${permission.toString()} denied',
        code: 'PERMISSION_DENIED',
        permission: permission.toString(),
      ));
    } catch (e) {
      return Result.failure(PermissionFailure(
        message: 'Failed to request permission: $e',
        code: 'PERMISSION_ERROR',
        permission: permission.toString(),
      ));
    }
  }

  /// Checks if a permission is currently granted.
  Future<bool> isPermissionGranted(ph.Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Checks if a permission is permanently denied.
  Future<bool> isPermissionPermanentlyDenied(ph.Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Opens the app's system settings page.
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }

  /// Requests all permissions needed for AURA to function.
  Future<Map<ph.Permission, bool>> requestAllRequiredPermissions() async {
    final permissions = <ph.Permission, bool>{};

    // Microphone for speech recognition
    final mic = await requestPermission(ph.Permission.microphone);
    permissions[ph.Permission.microphone] = mic.isSuccess && mic.getOrElse(() => false);

    return permissions;
  }
}
