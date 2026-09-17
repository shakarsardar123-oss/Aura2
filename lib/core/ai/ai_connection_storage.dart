/// ai_connection_storage.dart
/// AURA Assistant – R7-C: Secure Connection Storage Service
///
/// UPDATED: Gemini is now the default/primary provider.
/// - Default connection type: ConnectionType.gemini
/// - Default model: gemini-3.6-flash
/// - Default base URL: Gemini native API
/// - Gemini API key: FlutterSecureStorage (key: 'aura_gemini_api_key')
/// - OpenAI API key: FlutterSecureStorage (key: 'aura_openai_api_key') — preserved
/// - OpenAI base URL: FlutterSecureStorage (key: 'aura_openai_base_url') — preserved
/// - Gemini base URL: FlutterSecureStorage (key: 'aura_gemini_base_url')
/// - Model: SharedPreferences (key: 'aura_ai_model')
/// - Connection type: SharedPreferences (key: 'aura_ai_connection_type')
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_connection_config.dart';
import 'connection_type.dart';
import 'endpoint_validator.dart';
import 'provider_exception.dart';
import '../errors/result.dart';

/// SharedPreferences key for the AI model name.
const kModelStorageKey = 'aura_ai_model';

/// SharedPreferences key for the connection type index.
const kConnectionTypeStorageKey = 'aura_ai_connection_type';

/// Secure storage key for the Gemini base URL.
const kGeminiBaseUrlStorageKey = 'aura_gemini_base_url';

/// Secure storage key for the OpenAI base URL (preserved for backward compat).
const kOpenAIBaseUrlStorageKey = 'aura_openai_base_url';

/// Secure storage key for the Gemini API key.
const kGeminiApiKeyStorageKey = 'aura_gemini_api_key';

/// Secure storage key for the OpenAI API key (preserved for backward compat).
const kOpenAIApiKeyStorageKey = 'aura_openai_api_key';

/// Service for persisting and reading AI connection configuration.
///
/// Manages storage for both Gemini (primary) and OpenAI (secondary) providers.
/// API key CRUD for Gemini is handled by GeminiProvider directly.
/// API key CRUD for OpenAI is handled by OpenAIProvider directly.
/// This service handles: base URL reads, model name, connection type.
class AIConnectionStorage {
  AIConnectionStorage({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  // ─── Base URL ─────────────────────────────────────────────

  /// Reads the stored base URL for the given connection type.
  /// Returns the appropriate default if nothing is stored.
  Future<String> getBaseUrl([ConnectionType? type]) async {
    final connectionType = type ?? getConnectionType();
    switch (connectionType) {
      case ConnectionType.gemini:
        final url =
            await secureStorage.read(key: kGeminiBaseUrlStorageKey);
        return url ?? kDefaultBaseUrl;
      case ConnectionType.openaiCompatible:
        final url =
            await secureStorage.read(key: kOpenAIBaseUrlStorageKey);
        return url ?? kOpenAIDefaultBaseUrl;
      case ConnectionType.customOpenAI:
        final url =
            await secureStorage.read(key: kOpenAIBaseUrlStorageKey);
        return url ?? '';
    }
  }

  /// Stores a base URL for the given connection type in secure storage.
  ///
  /// Throws [AIProviderException] if validation fails.
  Future<void> setBaseUrl(String url, [ConnectionType? type]) async {
    final connectionType = type ?? getConnectionType();
    final result = EndpointValidator.validate(url);
    result.when(
      success: (validated) async {
        final storageKey = connectionType == ConnectionType.gemini
            ? kGeminiBaseUrlStorageKey
            : kOpenAIBaseUrlStorageKey;
        await secureStorage.write(key: storageKey, value: validated);
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
  /// Returns [ConnectionType.gemini] if nothing is stored
  /// or if the stored value is invalid.
  ConnectionType getConnectionType() {
    final index = sharedPreferences.getInt(kConnectionTypeStorageKey);
    if (index != null &&
        index >= 0 &&
        index < ConnectionType.values.length) {
      return ConnectionType.values[index];
    }
    // Default is now Gemini
    return ConnectionType.gemini;
  }

  /// Stores the connection type in SharedPreferences.
  void setConnectionType(ConnectionType type) {
    sharedPreferences.setInt(kConnectionTypeStorageKey, type.index);
  }

  // ─── Full Config ─────────────────────────────────────────

  /// Reads the full connection config from storage.
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
  /// API keys are NOT part of this config — use provider methods.
  Future<bool> saveConfig(AIConnectionConfig config) async {
    setConnectionType(config.connectionType);
    await setBaseUrl(config.baseUrl, config.connectionType);
    return setModel(config.model);
  }
}
