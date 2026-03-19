import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isMirrorRecordingProvider = StateProvider<bool>((ref) => false);

final recordingDurationProvider =
    StateProvider<Duration>((ref) => Duration.zero);

/// Hijab deseni görselini ui.Image olarak yükler.
final hijabPatternImageProvider =
    FutureProvider.family<ui.Image?, String>((ref, imagePath) async {
  final file = File(imagePath);
  if (!await file.exists()) return null;
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
});
