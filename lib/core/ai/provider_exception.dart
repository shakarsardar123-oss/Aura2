/// Exception thrown by AI providers when a request fails.
class AIProviderException implements Exception {
  const AIProviderException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.providerId,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final String? providerId;
  final Object? originalError;

  /// Authentication failure (401/403).
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Rate limit hit (429).
  bool get isRateLimit => statusCode == 429;

  /// Server error (5xx).
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Network error (no status code).
  bool get isNetworkError => statusCode == null && originalError != null;

  @override
  String toString() =>
      'AIProviderException($providerId, $statusCode, $errorCode): $message';
}
