/// endpoint_validator.dart
/// AURA Assistant – R6-D: HTTPS Endpoint Validation
///
/// Shared validation utility for AI provider base URLs.
/// Enforces HTTPS-only, rejects http/ftp/malformed URLs.
/// Does NOT rewrite URLs. Does NOT restrict to specific provider domains.
/// Does NOT add localhost HTTP bypass.
///
/// Uses project Result/Failure architecture for validation failures.
library;

import 'package:aura_assistant/core/errors/result.dart';
import 'package:aura_assistant/features/security/domain/models/security_failure.dart';

/// Validates that an AI provider base URL meets security requirements.
///
/// Requirements:
/// - Must be a valid URI (parseable by Uri.parse)
/// - Must use HTTPS scheme
/// - Must have a host
/// - Must NOT contain userinfo (embedded credentials)
///
/// Does NOT:
/// - Restrict to specific provider domains
/// - Rewrite http:// to https://
/// - Add localhost HTTP bypass
///
/// **Note:** localhost and 127.0.0.1 over plain HTTP are explicitly
/// NOT supported, even for development. Use an HTTPS proxy or
/// a local TLS-terminating reverse proxy if you need to test
/// against a local endpoint.
/// - Add localhost HTTP bypass
class EndpointValidator {
  EndpointValidator._();

  /// Validates [url] as an acceptable AI endpoint base URL.
  ///
  /// Returns [Result.success] with the validated URL string,
  /// or [Result.failure] with a [SecurityFailure] explaining the problem.
  static Result<String, SecurityFailure> validate(String url) {
    // ─── Empty / whitespace ──────────────────────────────────
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return SecurityFailure.providerPrivacyViolation(
        action: 'setBaseUrl',
        verdictReason: 'Base URL must not be empty.',
      ).asFailure<String>();
    }

    // ─── Parse URI ───────────────────────────────────────────
    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (e) {
      return SecurityFailure.providerPrivacyViolation(
        action: 'setBaseUrl',
        verdictReason: 'Invalid URL format. Could not parse: $trimmed',
      ).asFailure<String>();
    }

    // ─── HTTPS-only ───────────────────────────────────────────
    if (uri.scheme.toLowerCase() != 'https') {
      return SecurityFailure.providerPrivacyViolation(
        action: 'setBaseUrl',
        verdictReason:
            'Insecure scheme "${uri.scheme}" rejected. '
            'Only HTTPS endpoints are allowed.',
      ).asFailure<String>();
    }

    // ─── Must have a host ────────────────────────────────────
    if (uri.host.isEmpty) {
      return SecurityFailure.providerPrivacyViolation(
        action: 'setBaseUrl',
        verdictReason: 'URL must include a host. Got: $trimmed',
      ).asFailure<String>();
    }

    // ─── No embedded credentials (userinfo) ──────────────────
    if (uri.userInfo.isNotEmpty) {
      return SecurityFailure.providerPrivacyViolation(
        action: 'setBaseUrl',
        verdictReason:
            'URL must not contain embedded credentials (userinfo).',
      ).asFailure<String>();
    }

    return Result.success(trimmed);
  }

  /// Normalizes a base URL for safe path concatenation.
  ///
  /// Strips trailing slash from [baseUrl] so that
  /// `$normalizedBaseUrl/chat/completions` never produces a double slash.
  ///
  /// This does NOT validate the URL — use [validate] first.
  static String normalizeTrailingSlash(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
