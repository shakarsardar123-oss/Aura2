/// ai_connection_config_test.dart
/// R7-G: Tests for AIConnectionConfig model (R7-B)
///
/// Verifies: defaults, copyWith, equality, hasValidModel,
/// isOpenAICompatible, toString.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:aura_assistant/core/ai/ai_connection_config.dart';
import 'package:aura_assistant/core/ai/connection_type.dart';

void main() {
  // ─── AIConnectionConfig.defaults() ──────────────────────────────────

  group('AIConnectionConfig — defaults constructor', () {
    test('defaults() has openaiCompatible connection type', () {
      const config = AIConnectionConfig.defaults();
      expect(config.connectionType, ConnectionType.openaiCompatible);
    });

    test('defaults() has kDefaultBaseUrl', () {
      const config = AIConnectionConfig.defaults();
      expect(config.baseUrl, kDefaultBaseUrl);
    });

    test('defaults() has kDefaultChatModel', () {
      const config = AIConnectionConfig.defaults();
      expect(config.model, kDefaultChatModel);
    });

    test('defaults() is const-constructible', () {
      // If this compiles and runs, the const constructor works.
      const config = AIConnectionConfig.defaults();
      expect(config, isNotNull);
    });
  });

  // ─── copyWith ───────────────────────────────────────────────────────

  group('AIConnectionConfig — copyWith', () {
    test('copyWith changes model only', () {
      const original = AIConnectionConfig.defaults();
      final updated = original.copyWith(model: 'gpt-4o');
      expect(updated.model, 'gpt-4o');
      expect(updated.baseUrl, original.baseUrl);
      expect(updated.connectionType, original.connectionType);
    });

    test('copyWith changes baseUrl only', () {
      const original = AIConnectionConfig.defaults();
      final updated = original.copyWith(baseUrl: 'https://custom.api.com/v1');
      expect(updated.baseUrl, 'https://custom.api.com/v1');
      expect(updated.model, original.model);
      expect(updated.connectionType, original.connectionType);
    });

    test('copyWith with no args returns identical copy', () {
      const original = AIConnectionConfig.defaults();
      final copy = original.copyWith();
      expect(copy, original);
    });

    test('copyWith changes connectionType', () {
      // Only one ConnectionType exists currently, but verify mechanism works.
      const original = AIConnectionConfig.defaults();
      final updated = original.copyWith(connectionType: ConnectionType.openaiCompatible);
      expect(updated.connectionType, ConnectionType.openaiCompatible);
    });
  });

  // ─── Equality ───────────────────────────────────────────────────────

  group('AIConnectionConfig — equality', () {
    test('identical configs are equal', () {
      const a = AIConnectionConfig.defaults();
      const b = AIConnectionConfig.defaults();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different models are not equal', () {
      const a = AIConnectionConfig.defaults();
      final b = a.copyWith(model: 'gpt-4o');
      expect(a == b, isFalse);
    });

    test('different base URLs are not equal', () {
      const a = AIConnectionConfig.defaults();
      final b = a.copyWith(baseUrl: 'https://custom.api.com/v1');
      expect(a == b, isFalse);
    });

    test('non-AIConnectionConfig object is not equal', () {
      const config = AIConnectionConfig.defaults();
      expect(config == Object(), isFalse);
    });
  });

  // ─── hasValidModel ─────────────────────────────────────────────────

  group('AIConnectionConfig — hasValidModel', () {
    test('non-empty model hasValidModel is true', () {
      const config = AIConnectionConfig(model: 'gpt-4o', baseUrl: kDefaultBaseUrl, connectionType: ConnectionType.openaiCompatible);
      expect(config.hasValidModel, isTrue);
    });

    test('empty string model hasValidModel is false', () {
      const config = AIConnectionConfig(model: '', baseUrl: kDefaultBaseUrl, connectionType: ConnectionType.openaiCompatible);
      expect(config.hasValidModel, isFalse);
    });

    test('whitespace-only model hasValidModel is false', () {
      const config = AIConnectionConfig(model: '   ', baseUrl: kDefaultBaseUrl, connectionType: ConnectionType.openaiCompatible);
      expect(config.hasValidModel, isFalse);
    });

    test('model with leading/trailing whitespace hasValidModel is true (trim check)', () {
      const config = AIConnectionConfig(model: '  gpt-4o  ', baseUrl: kDefaultBaseUrl, connectionType: ConnectionType.openaiCompatible);
      // hasValidModel checks trim().isNotEmpty, so '  gpt-4o  ' trimmed is 'gpt-4o' → valid
      expect(config.hasValidModel, isTrue);
    });
  });

  // ─── isOpenAICompatible ────────────────────────────────────────────

  group('AIConnectionConfig — isOpenAICompatible', () {
    test('defaults is openaiCompatible', () {
      const config = AIConnectionConfig.defaults();
      expect(config.isOpenAICompatible, isTrue);
    });
  });

  // ─── Constants ──────────────────────────────────────────────────────

  group('AIConnectionConfig — constants', () {
    test('kDefaultChatModel is gpt-4o-mini', () {
      expect(kDefaultChatModel, 'gpt-4o-mini');
    });

    test('kDefaultVisionModel is gpt-4o', () {
      expect(kDefaultVisionModel, 'gpt-4o');
    });

    test('kDefaultBaseUrl is https://api.openai.com/v1', () {
      expect(kDefaultBaseUrl, 'https://api.openai.com/v1');
    });
  });

  // ─── toString ──────────────────────────────────────────────────────

  group('AIConnectionConfig — toString', () {
    test('toString includes type, baseUrl, model', () {
      const config = AIConnectionConfig.defaults();
      final str = config.toString();
      expect(str, contains('openaiCompatible'));
      expect(str, contains('https://api.openai.com/v1'));
      expect(str, contains('gpt-4o-mini'));
    });
  });
}
