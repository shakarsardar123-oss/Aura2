/// ai_connection_config.dart
/// AURA Assistant – R7-B: Unified AI Connection Config Model
///
/// Immutable model representing the user's AI connection configuration.
/// This is the single source of truth for connection settings
/// used by both chat (OpenAIProvider) and vision (OpenAIVisionService).
///
/// API key is NOT part of this model — it stays in secure storage
/// accessed via OpenAIProvider methods (getApiKey/setApiKey/deleteApiKey).
///
/// Design decisions:
/// - connectionType: enum to support future connection types (currently openaiCompatible only)
/// - baseUrl: the API base URL (validated by EndpointValidator)
/// - model: the model name to use for chat AND vision
/// - Model is NOT secret — stored in SharedPreferences, not secure storage
library;

import 'connection_type.dart';

/// Default model for chat completions.
const kDefaultChatModel = 'gpt-4o-mini';

/// Default model for vision (must support image input).
const kDefaultVisionModel = 'gpt-4o';

/// Default OpenAI-compatible base URL.
const kDefaultBaseUrl = 'https://api.openai.com/v1';

/// Unified AI connection configuration model.
///
/// Immutable value object. Create new instances via copyWith
/// or the named constructors.
class AIConnectionConfig {
  const AIConnectionConfig({
    required this.connectionType,
    required this.baseUrl,
    required this.model,
  });

  /// Creates a config with OpenAI-compatible defaults.
  const AIConnectionConfig.defaults()
      : connectionType = ConnectionType.openaiCompatible,
        baseUrl = kDefaultBaseUrl,
        model = kDefaultChatModel;

  /// The type of AI connection.
  final ConnectionType connectionType;

  /// Base URL for the API endpoint (HTTPS only, validated by EndpointValidator).
  final String baseUrl;

  /// Model name to use for requests.
  /// For chat: used as the model parameter in /chat/completions.
  /// For vision: used as the model parameter in vision /chat/completions.
  final String model;

  /// Whether this config uses the OpenAI-compatible connection type.
  bool get isOpenAICompatible => connectionType == ConnectionType.openaiCompatible;

  /// Whether the model field is non-empty and non-whitespace.
  bool get hasValidModel => model.trim().isNotEmpty;

  /// Create a copy with optional field overrides.
  AIConnectionConfig copyWith({
    ConnectionType? connectionType,
    String? baseUrl,
    String? model,
  }) {
    return AIConnectionConfig(
      connectionType: connectionType ?? this.connectionType,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIConnectionConfig &&
        other.connectionType == connectionType &&
        other.baseUrl == baseUrl &&
        other.model == model;
  }

  @override
  int get hashCode => Object.hash(connectionType, baseUrl, model);

  @override
  String toString() =>
      'AIConnectionConfig(type: $connectionType, baseUrl: $baseUrl, model: $model)';
}
