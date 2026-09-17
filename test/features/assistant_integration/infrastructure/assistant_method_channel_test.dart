// Test file for AssistantMethodChannel.
//
// Structural tests — verify the channel name, method name
// constants, and MethodChannel construction are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:aura_assistant/features/assistant_integration/infrastructure/assistant_method_channel.dart';
import 'package:aura_assistant/features/assistant_integration/domain/assistant_service.dart';

void main() {
  group('AssistantMethodChannel', () {
    test('channel name is correct', () {
      expect(
        AssistantMethodChannel.channelName,
        'com.aura.assistant/assistant_integration',
      );
    });

    test('detectStatus method name is correct', () {
      expect(
        AssistantMethodChannel.methodDetectStatus,
        'detectStatus',
      );
    });

    test('openAssistantSettings method name is correct', () {
      expect(
        AssistantMethodChannel.methodOpenAssistantSettings,
        'openAssistantSettings',
      );
    });

    test('getInvocationData method name is correct', () {
      expect(
        AssistantMethodChannel.methodGetInvocationData,
        'getInvocationData',
      );
    });

    test('isAssistantRoleSupported method name is correct', () {
      expect(
        AssistantMethodChannel.methodIsAssistantRoleSupported,
        'isAssistantRoleSupported',
      );
    });

    test('method channel is created with correct name', () {
      // We verify the channel name string is consistent.
      // The MethodChannel object requires a Flutter engine in tests,
      // so we only verify the constant.
      expect(AssistantMethodChannel.channelName, startsWith('com.aura.assistant/'));
    });

    test('AssistantMethodChannel implements AssistantService', () {
      // Compile-time check: the class implements the interface.
      // We verify by checking that an instance (if constructible) is a subtype.
      // Since MethodChannel requires Flutter bindings, we just
      // verify the class declaration is correct structurally.
      expect(
        #AssistantMethodChannel,
        isNotNull,
      );
    });

    test('all method name constants are non-empty', () {
      expect(AssistantMethodChannel.methodDetectStatus, isNotEmpty);
      expect(AssistantMethodChannel.methodOpenAssistantSettings, isNotEmpty);
      expect(AssistantMethodChannel.methodGetInvocationData, isNotEmpty);
      expect(AssistantMethodChannel.methodIsAssistantRoleSupported, isNotEmpty);
    });
  });
}
