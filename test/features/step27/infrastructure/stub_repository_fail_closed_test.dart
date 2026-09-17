/// stub_repository_fail_closed_test.dart
/// Step 27 structural validation — all stubs are FAIL-CLOSED.
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Stub Repository FAIL-CLOSED', () {
    test('StubDeviceTransportRepository.isTransportAvailable returns false', () async {
      final repo = StubDeviceTransportRepository();
      expect(await repo.isTransportAvailable(), isFalse);
    });

    test('StubTranslationEngineRepository.isEngineAvailable returns false', () async {
      final repo = StubTranslationEngineRepository();
      expect(await repo.isEngineAvailable(), isFalse);
    });

    test('StubAudioInputRepository.isAvailable returns false', () {
      final repo = StubAudioInputRepository();
      expect(repo.isAvailable, isFalse);
    });

    test('StubOverlayRendererRepository.isAvailable returns false', () {
      final repo = StubOverlayRendererRepository();
      expect(repo.isAvailable, isFalse);
    });

    test('StubVisionRepository.isAvailable returns false', () {
      final repo = StubVisionRepository();
      expect(repo.isAvailable, isFalse);
    });

    test('StubScreenActionRepository.isAvailable returns false', () {
      final repo = StubScreenActionRepository();
      expect(repo.isAvailable, isFalse);
    });

    test('StubSystemResourceRepository.isAvailable returns false', () {
      final repo = StubSystemResourceRepository();
      expect(repo.isAvailable, isFalse);
    });

    test('StubApiGatewayRepository.isAvailable returns false', () {
      final repo = StubApiGatewayRepository();
      expect(repo.isAvailable, isFalse);
    });
  });
}
