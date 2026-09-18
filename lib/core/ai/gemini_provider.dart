/// gemini_provider.dart
/// AURA Assistant – P1 Fix: Native Gemini AI Provider
///
/// Implements AIProvider using Google Gemini's native REST API
/// (POST /v1beta/models/{model}:generateContent?key={apikey})
/// instead of the broken OpenAI-compatible shim.
///
/// CRITICAL FIXES vs the old OpenAIProvider-for-Gemini approach:
/// 1. Uses Gemini-native auth: ?key= query parameter, NOT Authorization: Bearer
/// 2. Uses Gemini-native request format: contents[] with parts[]
/// 3. Uses Gemini-native response format: candidates[0].content.parts[0].text
/// 4. Robust error handling: empty body, non-JSON, HTTP errors, rate limits
/// 5. Never throws FormatException from jsonDecode on empty bodies
/// 6. Reports providerId as 'gemini' (not 'openai')
/// 7. AURA identity preserved: system prompt always includes Kurdish identity
library;

import 'dart:convert';
import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/services/ai_service.dart';
import '../../services/ai/ai_provider.dart';
import '../../core/ai/ai_message.dart';
import '../../core/ai/ai_connection_storage.dart';
import '../../core/ai/provider_exception.dart';
import '../../core/ai/endpoint_validator.dart';
import '../errors/result.dart';

/// Secure storage key for the Gemini API key.
const _geminiApiKeyStorageKey = 'aura_gemini_api_key';

/// Default Gemini base URL (native API, not OpenAI-compatible).
const _defaultGeminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

/// Default Gemini model for chat.
const kDefaultGeminiChatModel = 'gemini-3.6-flash';

/// Native Gemini REST API provider implementation.
///
/// Makes actual HTTP requests to Google's Gemini API using the
/// native request/response format. API key is stored securely
/// in FlutterSecureStorage with a Gemini-specific key.
class GeminiProvider implements AIProvider {
  GeminiProvider({
    required this.secureStorage,
    this.connectionStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final FlutterSecureStorage secureStorage;

  /// Optional [AIConnectionStorage] for reading the user-configured model.
  /// When null, falls back to [kDefaultGeminiChatModel].
  final AIConnectionStorage? connectionStorage;

  final http.Client _httpClient;

  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  @override
  bool supportsModel(String modelId) => supportedModels.contains(modelId);

  @override
  List<String> get supportedModels => const [
        'gemini-3.6-flash',
        'gemini-2.5-flash-preview-05-20',
        'gemini-2.5-pro-preview-05-06',
        'gemini-1.5-pro',
        'gemini-1.5-flash',
      ];

  /// Retrieves the stored Gemini API key from secure storage.
  Future<String?> getApiKey() =>
      secureStorage.read(key: _geminiApiKeyStorageKey);

  /// Stores the Gemini API key in secure storage.
  Future<void> setApiKey(String key) =>
      secureStorage.write(key: _geminiApiKeyStorageKey, value: key);

  /// Deletes the stored Gemini API key.
  Future<void> deleteApiKey() =>
      secureStorage.delete(key: _geminiApiKeyStorageKey);

  /// Retrieves the stored base URL from secure storage.
  /// Returns [_defaultGeminiBaseUrl] if nothing is stored.
  Future<String> getBaseUrl() async {
    final url = await secureStorage.read(key: 'aura_gemini_base_url');
    return url ?? _defaultGeminiBaseUrl;
  }

  /// Stores a custom Gemini base URL in secure storage.
  Future<void> setBaseUrl(String url) async {
    final result = EndpointValidator.validate(url);
    result.when(
      success: (validated) async {
        await secureStorage.write(key: 'aura_gemini_base_url', value: validated);
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

  /// Converts AIMessage list to Gemini contents format.
  List<Map<String, dynamic>> _buildContents(
    AIRequest request,
  ) {
    final contents = <Map<String, dynamic>>[];

    // Add conversation history if available.
    if (request.messages != null) {
      for (final msg in request.messages!) {
        final role = msg.role == AIMessageRole.system
            ? 'user' // Gemini doesn't have system role; inject via systemInstruction
            : msg.role == AIMessageRole.assistant
                ? 'model'
                : 'user';

        // Skip tool result messages; they'll be handled via functionCall in the future
        if (msg.role == AIMessageRole.tool) continue;

        contents.add({
          'role': role,
          'parts': [
            {'text': msg.content},
          ],
        });
      }
    }

    // Add user prompt if not already covered by messages.
    if (request.messages == null || request.messages!.isEmpty) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': request.prompt},
        ],
      });
    }

    return contents;
  }

  /// Build the system instruction from the agent config.
  Map<String, dynamic>? _buildSystemInstruction(AIRequest request) {
    // Always ensure AURA identity is preserved
    const baseIdentity =
        'من ئەورای تایبەتی تۆم. وەڵامی کوردی سۆرانی بدەرەوە.';
    final systemPrompt = request.agentConfig.systemPrompt;
    if (systemPrompt.isEmpty && baseIdentity.isEmpty) return null;

    // Combine identity with any custom system prompt
    final combined = systemPrompt.isEmpty
        ? baseIdentity
        : '$baseIdentity\n\n$systemPrompt';

    return {
      'parts': [
        {'text': combined},
      ],
    };
  }

  /// Maps common lowercase/Dart-style type names to Gemini's required
  /// UPPERCASE JSON Schema type enum values.
  static const Map<String, String> _geminiTypeMap = {
    'string': 'STRING',
    'str': 'STRING',
    'int': 'INTEGER',
    'integer': 'INTEGER',
    'double': 'NUMBER',
    'float': 'NUMBER',
    'number': 'NUMBER',
    'num': 'NUMBER',
    'bool': 'BOOLEAN',
    'boolean': 'BOOLEAN',
    'list': 'ARRAY',
    'array': 'ARRAY',
    'map': 'OBJECT',
    'object': 'OBJECT',
    'dict': 'OBJECT',
  };

  /// Recursively walks a JSON Schema map and converts every 'type' value
  /// to the UPPERCASE format required by the Gemini API
  /// (STRING, INTEGER, NUMBER, BOOLEAN, ARRAY, OBJECT), including nested
  /// 'properties' and 'items' schemas.
  dynamic _normalizeSchemaTypes(dynamic node) {
    if (node is Map) {
      final result = <String, dynamic>{};
      node.forEach((key, value) {
        if (key == 'type' && value is String) {
          final normalized = _geminiTypeMap[value.toLowerCase()] ??
              value.toUpperCase();
          result[key] = normalized;
        } else if (key == 'properties' && value is Map) {
          final props = <String, dynamic>{};
          value.forEach((propKey, propValue) {
            props[propKey] = _normalizeSchemaTypes(propValue);
          });
          result[key] = props;
        } else if (key == 'items') {
          result[key] = _normalizeSchemaTypes(value);
        } else {
          result[key] = value is Map || value is List
              ? _normalizeSchemaTypes(value)
              : value;
        }
      });
      return result;
    } else if (node is List) {
      return node.map((e) => _normalizeSchemaTypes(e)).toList();
    }
    return node;
  }

  /// Build tool declarations in Gemini functionDeclarations format.
  List<Map<String, dynamic>>? _buildToolDeclarations(
    List<Map<String, dynamic>>? toolDefinitions,
  ) {
    if (toolDefinitions == null || toolDefinitions.isEmpty) return null;

    return toolDefinitions.map((tool) {
      final function = tool['function'] as Map<String, dynamic>? ?? tool;
      final rawParameters =
          function['parameters'] ?? tool['parameters'] ?? {};
      final normalizedParameters =
          _normalizeSchemaTypes(rawParameters) as Map<String, dynamic>;
      return {
        'functionDeclarations': [
          {
            'name': function['name'] ?? tool['name'] ?? '',
            'description':
                function['description'] ?? tool['description'] ?? '',
            'parameters': normalizedParameters,
          },
        ],
      };
    }).toList();
  }

  @override
  Future<AIResponse> complete(AIRequest request) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw AIProviderException(
        message:
            'Gemini API key not configured. Please set it in Settings.',
        statusCode: 401,
        errorCode: 'NO_API_KEY',
        providerId: id,
      );
    }

    final baseUrl =
        EndpointValidator.normalizeTrailingSlash(await getBaseUrl());

    // Use user-configured model from AIConnectionStorage if available,
    // otherwise fall back to the agent config modelId, then default.
    final model = connectionStorage?.getModel() ??
        request.agentConfig.modelId ??
        kDefaultGeminiChatModel;

    final temperature =
        request.temperature ?? request.agentConfig.temperature;
    final maxTokens = request.maxTokens ?? request.agentConfig.maxTokens;

    // Build the Gemini-native request body
    final body = <String, dynamic>{
      'contents': _buildContents(request),
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      },
    };

    // System instruction
    final systemInstruction = _buildSystemInstruction(request);
    if (systemInstruction != null) {
      body['systemInstruction'] = systemInstruction;
    }

    // Tool declarations
    final tools = _buildToolDeclarations(request.toolDefinitions);
    if (tools != null && tools.isNotEmpty) {
      body['tools'] = tools;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Gemini native API uses ?key= query param, NOT Authorization header
      final uri = Uri.parse(
        '$baseUrl/models/$model:generateContent?key=$apiKey',
      );

      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      stopwatch.stop();

      // ── Robust error handling ──
      if (response.statusCode != 200) {
        // Try to parse error body, but handle empty/non-JSON gracefully
        String errorMessage;
        String? errorCode;
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
            final error = errorBody['error'] as Map<String, dynamic>?;
            errorMessage = error?['message'] as String? ??
                'Gemini API request failed with status ${response.statusCode}';
            errorCode = error?['status'] as String?;
          } else {
            errorMessage =
                'Gemini API request failed with status ${response.statusCode} (empty response body)';
          }
        } on FormatException {
          // Body exists but is not valid JSON
          errorMessage =
              'Gemini API returned status ${response.statusCode} with non-JSON body';
        } catch (e) {
          errorMessage =
              'Gemini API request failed with status ${response.statusCode}';
        }

        throw AIProviderException(
          message: errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
          providerId: id,
        );
      }

      // Parse successful response — handle empty body gracefully
      Map<String, dynamic> data;
      try {
        if (response.body.isEmpty) {
          throw AIProviderException(
            message: 'Gemini API returned 200 but with empty response body',
            statusCode: 200,
            errorCode: 'EMPTY_RESPONSE',
            providerId: id,
          );
        }
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw AIProviderException(
          message:
              'Gemini API returned 200 but response body is not valid JSON',
          statusCode: 200,
          errorCode: 'INVALID_JSON',
          providerId: id,
        );
      }

      // Extract the text from candidates[0].content.parts[0].text
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        // Check for promptFeedback block (e.g., safety filtering)
        final promptFeedback =
            data['promptFeedback'] as Map<String, dynamic>?;
        if (promptFeedback != null) {
          final blockReason =
              promptFeedback['blockReason'] as String?;
          throw AIProviderException(
            message:
                'Gemini response blocked: ${blockReason ?? "unknown reason"}',
            statusCode: 200,
            errorCode: 'RESPONSE_BLOCKED',
            providerId: id,
          );
        }
        throw AIProviderException(
          message: 'Gemini API returned no candidates in response',
          statusCode: 200,
          errorCode: 'NO_CANDIDATES',
          providerId: id,
        );
      }

      final candidate = candidates.first as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;

      // Extract text from parts
      String text = '';
      List<AIToolCall>? toolCalls;

      if (parts != null && parts.isNotEmpty) {
        for (final part in parts) {
          final partMap = part as Map<String, dynamic>;
          if (partMap.containsKey('text')) {
            text += partMap['text'] as String? ?? '';
          }
          // Handle function calls from Gemini
          if (partMap.containsKey('functionCall')) {
            final fc = partMap['functionCall'] as Map<String, dynamic>;
            toolCalls ??= [];
            toolCalls.add(AIToolCall(
              id: 'gemini_fc_${toolCalls.length}',
              functionName: fc['name'] as String? ?? '',
              arguments: fc['args'] as Map<String, dynamic>? ?? {},
            ));
          }
        }
      }

      final finishReason = candidate['finishReason'] as String?;
      final usageMetadata =
          data['usageMetadata'] as Map<String, dynamic>?;

      final aiResponse = AIResponse(
        text: text,
        modelId: model,
        conversationId: request.conversationId,
        finishReason: finishReason,
        latencyMs: stopwatch.elapsedMilliseconds,
        usage: usageMetadata != null
            ? AIUsage(
                promptTokens:
                    usageMetadata['promptTokenCount'] as int? ?? 0,
                completionTokens:
                    usageMetadata['candidatesTokenCount'] as int? ?? 0,
                totalTokens:
                    usageMetadata['totalTokenCount'] as int? ?? 0,
              )
            : null,
      );

      if (toolCalls != null && toolCalls.isNotEmpty) {
        aiResponse.toolCalls = toolCalls;
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
    } on FormatException catch (e) {
      // This should be rare with our guards, but just in case
      throw AIProviderException(
        message: 'Failed to parse Gemini response: ${e.message}',
        providerId: id,
        errorCode: 'PARSE_ERROR',
        originalError: e,
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
    // For now, streaming yields the complete response as a single chunk.
    // Full SSE streaming via Gemini's streamGenerateContent can be added later.
    final response = await complete(request);
    yield response;
  }
}
