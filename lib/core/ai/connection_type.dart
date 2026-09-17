/// connection_type.dart
/// AURA Assistant – R7-B: Connection Type Enum
///
/// Defines the supported AI connection types.
/// R7 scope: only openaiCompatible (OpenAI-compatible HTTPS API).
/// No Gemini, Claude, or "universal" provider.
library;

/// Supported AI connection types.
///
/// Currently only [openaiCompatible] is supported — any endpoint
/// that follows the OpenAI chat completions API contract
/// (POST /chat/completions with Authorization: Bearer header).
enum ConnectionType {
  /// OpenAI-compatible HTTPS API (chat completions contract).
  openaiCompatible,
}
