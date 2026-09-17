import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/services/ai_service.dart';
import '../../services/ai/ai_provider.dart';
import '../../core/ai/ai_message.dart';
import '../../core/ai/ai_connection_config.dart' show kDefaultChatModel;
import '../../core/ai/ai_connection_storage.dart';
import '../../core/ai/provider_exception.dart';
import '../../core/ai/endpoint_validator.dart';

/// Secure storage key for the OpenAI API key.
const _apiKeyStorageKey = 'aura_openai_api_key';

/// Default OpenAI-compatible base URL.
const _defaultBaseUrl = 'https://api.openai.com/v1';

/// Secure storage key for the base URL.
const _baseUrlStorageKey = 'aura_openai_base_url';

/// Real OpenAI-compatible AI provider implementation.
///
/// Makes actual HTTP requests to an OpenAI-compatible API endpoint.
/// API key and base URL are stored securely in FlutterSecureStorage.
class OpenAIProvider implements AIProvider {
  OpenAIProvider({
    required this.secureStorage,
    this.connectionStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final FlutterSecureStorage secureStorage;

  /// Optional [AIConnectionStorage] for reading the user-configured model.
  /// When null, the provider falls back to [request.agentConfig.modelId]
  /// for backward compatibility.
  final AIConnectionStorage? connectionStorage;

  final http.Client _httpClient;

  @override
  String get id => 'openai';

  @override
  String get displayName => 'OpenAI';

  @override
  bool supportsModel(String modelId) => supportedModels.contains(modelId);

  @override
  List<String> get supportedModels => const [
        'gpt-4o',
        'gpt-4o-mini',
        'gpt-4-turbo',
        'gpt-4',
        'gpt-3.5-turbo',
        'gpt-3.5-turbo-16k',
      ];

  /// Retrieves the stored API key from secure storage.
  Future<String?> getApiKey() => secureStorage.read(key: _apiKeyStorageKey);

  /// Stores the API key in secure storage.
  Future<void> setApiKey(String key) =>
      secureStorage.write(key: _apiKeyStorageKey, value: key);

  /// Deletes the stored API key.
  Future<void> deleteApiKey() => secureStorage.delete(key: _apiKeyStorageKey);

  /// Retrieves the stored base URL from secure storage.
  Future<String> getBaseUrl() async {
    final url = await secureStorage.read(key: _baseUrlStorageKey);
    return url ?? _defaultBaseUrl;
  }

  /// Stores a custom base URL in secure storage.
  ///
  /// Validates that [url] uses HTTPS and is well-formed before storing.
  /// Throws [AIProviderException] if validation fails.
  /// Does NOT rewrite URLs — rejects insecure schemes outright.
  Future<void> setBaseUrl(String url) async {
    final result = EndpointValidator.validate(url);
    result.when(
      success: (validated) async {
        await secureStorage.write(
          key: _baseUrlStorageKey,
          value: validated,
        );
      },
      failure: (failure) {
        throw AIProviderException(
          message: failure.verdictReason ?? failure.message,
          errorCode: 'INVALID_BASE_URL',
          providerId: id,
        );
      },
    );
  }

  /// Builds the complete messages payload for the chat completions API.
  List<Map<String, dynamic>> _buildMessages(AIRequest request) {
    final messages = <Map<String, dynamic>>[];

    // System prompt from agent config.
    if (request.agentConfig.systemPrompt.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': request.agentConfig.systemPrompt,
      });
    }

    // Add conversation history if available.
    if (request.messages != null) {
      for (final msg in request.messages!) {
        messages.add(msg.toMap());
      }
    }

    // User prompt.
    messages.add({'role': 'user', 'content': request.prompt});

    return messages;
  }

  /// Builds the tool definitions payload for the chat completions API.
  List<Map<String, dynamic>>? _buildTools(
    List<Map<String, dynamic>>? toolDefinitions,
  ) {
    if (toolDefinitions == null || toolDefinitions.isEmpty) return null;
    return toolDefinitions;
  }

  @override
  Future<AIResponse> complete(AIRequest request) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIProviderException(
        message: 'OpenAI API key not configured. Please set it in Settings.',
        statusCode: 401,
        errorCode: 'NO_API_KEY',
        providerId: id,
      );
    }

    final baseUrl =
        EndpointValidator.normalizeTrailingSlash(await getBaseUrl());
    // Use user-configured model from AIConnectionStorage if available,
    // otherwise fall back to the agent config modelId for backward compat.
    final model = connectionStorage?.getModel() ?? request.agentConfig.modelId;
    final temperature = request.temperature ?? request.agentConfig.temperature;
    final maxTokens = request.maxTokens ?? request.agentConfig.maxTokens;

    final body = <String, dynamic>{
      'model': model,
      'messages': _buildMessages(request),
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    final tools = _buildTools(request.toolDefinitions);
    if (tools != null) {
      body['tools'] = tools;
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      stopwatch.stop();

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw AIProviderException(
          message: errorBody['error']?['message'] as String? ??
              'API request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          errorCode: errorBody['error']?['code']?.toString(),
          providerId: id,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choice = (data['choices'] as List<dynamic>).first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      final content = message['content'] as String? ?? '';
      final toolCalls = message['tool_calls'] as List<dynamic>?;
      final usage = data['usage'] as Map<String, dynamic>?;

      // Build extended response with tool calls.
      final aiResponse = AIResponse(
        text: content,
        modelId: data['model'] as String? ?? model,
        conversationId: request.conversationId,
        finishReason: choice['finish_reason'] as String?,
        latencyMs: stopwatch.elapsedMilliseconds,
        usage: usage != null
            ? AIUsage(
                promptTokens: usage['prompt_tokens'] as int? ?? 0,
                completionTokens: usage['completion_tokens'] as int? ?? 0,
                totalTokens: usage['total_tokens'] as int? ?? 0,
              )
            : null,
      );

      // Attach tool calls if present (stored in extendedResponse).
      if (toolCalls != null && toolCalls.isNotEmpty) {
        aiResponse.toolCalls = toolCalls
            .map((tc) => AIToolCall.fromMap(tc as Map<String, dynamic>))
            .toList();
      }

      return aiResponse;
    } on AIProviderException {
      rethrow;
    } on http.ClientException catch (e) {
      throw AIProviderException(
        message: 'Network error: ${e.message}',
        providerId: id,
        originalError: e,
      );
    } on TimeoutException {
      throw AIProviderException(
        message: 'Request timed out after 120 seconds',
        providerId: id,
        errorCode: 'TIMEOUT',
      );
    } catch (e) {
      throw AIProviderException(
        message: 'Unexpected error: $e',
        providerId: id,
        originalError: e,
      );
    }
  }

  @override
  Stream<AIResponse> streamComplete(AIRequest request) async* {
    // For Phase 3, streaming is simplified — we yield the complete response
    // as a single chunk. Full SSE streaming can be added later.
    final response = await complete(request);
    yield response;
  }
}

/// Riverpod provider for the OpenAI provider instance.
final openaiProviderProvider = Provider<OpenAIProvider>((ref) {
  throw UnimplementedError(
    'openaiProviderProvider must be overridden in main.dart with FlutterSecureStorage',
  );
});
