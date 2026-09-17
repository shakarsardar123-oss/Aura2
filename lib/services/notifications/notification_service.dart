/// Abstraction for local and push notifications.
///
/// Phase 2+ will implement platform-specific notification handling.
/// Phase 1 provides the contract only.
abstract class NotificationService {
  /// Requests notification permissions (Android 13+).
  Future<bool> requestPermissions();

  /// Shows a local notification with [title] and [body].
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  });

  /// Cancels a notification by [id].
  Future<void> cancelNotification(int id);

  /// Cancels all notifications.
  Future<void> cancelAllNotifications();
}
