/// ai_connection_storage.dart
/// AURA Assistant – R7-C: Secure Connection Storage Service
///
/// Manages persistence of AI connection configuration.
///
/// Storage strategy:
/// - API key: FlutterSecureStorage (key: 'aura_openai_api_key') — existing, unchanged
/// - Base URL: FlutterSecureStorage (key: 'aura_openai_base_url') — existing, unchanged
/// - Model: SharedPreferences (key: 'aura_ai_model') — non-secret, user-visible
/// - Connection type: SharedPreferences (key: 'aura_ai_connection_type') — non-secret
///
/// Why SharedPreferences for model and connection type?
/// - Model names are NOT secrets (visible in API responses, logs, UI)
/// - Connection type is NOT a secret
/// - SharedPreferences is synchronous-read, faster for non-secret data
/// - Keeps secure storage reserved for actual secrets (API key)
///
/// API key methods are delegated to OpenAIProvider's existing methods
/// (getApiKey/setApiKey/deleteApiKey) which use FlutterSecureStorage directly.
/// This service focuses on the NON-secret config: model, baseUrl read, and connection type.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_connection_config.dart';
import 'connection_type.dart';
import 'endpoint_validator.dart';
import 'provider_exception.dart';

/// SharedPreferences key for the AI model name.
const kModelStorageKey = 'aura_ai_model';

/// SharedPreferences key for the connection type index.
const kConnectionTypeStorageKey = 'aura_ai_connection_type';

/// Secure storage key for the base URL (shared with OpenAIProvider).
const kBaseUrlStorageKey = 'aura_openai_base_url';

/// Service for persisting and reading AI connection configuration.
///
/// API key CRUD is handled by OpenAIProvider directly.
/// This service handles: base URL read, model name, connection type.
class AIConnectionStorage {
  AIConnectionStorage({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  // ─── Base URL ─────────────────────────────────────────────

  /// Reads the stored base URL from secure storage.
  /// Returns [kDefaultBaseUrl] if nothing is stored.
  Future<String> getBaseUrl() async {
    final url = await secureStorage.read(key: kBaseUrlStorageKey);
    return url ?? kDefaultBaseUrl;
  }

  /// Stores a base URL in secure storage after validation.
  ///
  /// Throws [AIProviderException] if validation fails.
  /// Does NOT rewrite URLs — rejects insecure schemes outright.
  Future<void> setBaseUrl(String url) async {
    final result = EndpointValidator.validate(url);
    result.when(
      success: (validated) async {
        await secureStorage.write(key: kBaseUrlStorageKey, value: validated);
      },
      failure: (failure) {
        throw AIProviderException(
          message: failure.verdictReason ?? failure.message,
          errorCode: 'INVALID_BASE_URL',
          providerId: 'connection_storage',
        );
      },
    );
  }

  // ─── Model ────────────────────────────────────────────────

  /// Reads the stored model name from SharedPreferences.
  /// Returns [kDefaultChatModel] if nothing is stored.
  String getModel() {
    return sharedPreferences.getString(kModelStorageKey) ?? kDefaultChatModel;
  }

  /// Stores the model name in SharedPreferences.
  ///
  /// Validates that [model] is non-empty and non-whitespace.
  /// Returns true if stored successfully, false if validation fails.
  bool setModel(String model) {
    final trimmed = model.trim();
    if (trimmed.isEmpty) return false;
    sharedPreferences.setString(kModelStorageKey, trimmed);
    return true;
  }

  /// Deletes the stored model name, reverting to the default.
  void deleteModel() {
    sharedPreferences.remove(kModelStorageKey);
  }

  // ─── Connection Type ─────────────────────────────────────

  /// Reads the stored connection type from SharedPreferences.
  /// Returns [ConnectionType.openaiCompatible] if nothing is stored
  /// or if the stored value is invalid.
  ConnectionType getConnectionType() {
    final index = sharedPreferences.getInt(kConnectionTypeStorageKey);
    if (index != null &&
        index >= 0 &&
        index < ConnectionType.values.length) {
      return ConnectionType.values[index];
    }
    return ConnectionType.openaiCompatible;
  }

  /// Stores the connection type in SharedPreferences.
  void setConnectionType(ConnectionType type) {
    sharedPreferences.setInt(kConnectionTypeStorageKey, type.index);
  }

  // ─── Full Config ─────────────────────────────────────────

  /// Reads the full connection config from storage.
  ///
  /// Base URL is read asynchronously from secure storage;
  /// model and connection type are read synchronously from SharedPreferences.
  Future<AIConnectionConfig> getConfig() async {
    return AIConnectionConfig(
      connectionType: getConnectionType(),
      baseUrl: await getBaseUrl(),
      model: getModel(),
    );
  }

  /// Saves the full connection config to storage.
  ///
  /// Base URL is validated before saving.
  /// API key is NOT part of this config — use OpenAIProvider methods.
  ///
  /// Returns true if all fields saved successfully.
  /// Throws [AIProviderException] if base URL validation fails.
  Future<bool> saveConfig(AIConnectionConfig config) async {
    setConnectionType(config.connectionType);
    await setBaseUrl(config.baseUrl);
    return setModel(config.model);
  }
}
