/// providers.dart
/// AURA Assistant – Step 27: Continuous Listening — Riverpod providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/segmentation_config.dart';
import '../domain/repositories/audio_input_repository.dart';
import '../domain/services/continuous_listening_service.dart';

final continuousListeningServiceProvider = Provider<ContinuousListeningService>((ref) {
  throw UnimplementedError('continuousListeningServiceProvider must be overridden');
});

final audioInputRepositoryProvider = Provider<AudioInputRepository>((ref) {
  throw UnimplementedError('audioInputRepositoryProvider must be overridden');
});

final segmentationConfigProvider = StateProvider<SegmentationConfig>(
  (ref) => const SegmentationConfig(mode: SegmentationMode.hybrid),
);

final isListeningProvider = StateProvider<bool>((ref) => false);
