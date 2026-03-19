import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/mediapipe_service.dart';
import '../../core/services/texture_overlay_service.dart';
import '../../core/utils/constants.dart';
import '../home/home_provider.dart';

final selectedUserPhotoProvider = StateProvider<File?>((ref) => null);

final isProcessingProvider = StateProvider<bool>((ref) => false);

final resultImageProvider = StateProvider<Uint8List?>((ref) => null);

final photoModeNotifierProvider =
    StateNotifierProvider<PhotoModeNotifier, AsyncValue<Uint8List?>>(
  (ref) => PhotoModeNotifier(ref),
);

class PhotoModeNotifier extends StateNotifier<AsyncValue<Uint8List?>> {
  final Ref _ref;

  PhotoModeNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> pickUserPhotoFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      _ref.read(selectedUserPhotoProvider.notifier).state = File(picked.path);
    }
  }

  Future<void> pickUserPhotoFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      _ref.read(selectedUserPhotoProvider.notifier).state = File(picked.path);
    }
  }

  /// Günlük limit kontrolü yapar.
  /// true: işlem yapılabilir, false: limit dolmuş
  bool canProcess() {
    final storage = _ref.read(storageServiceProvider);
    final count = storage.getDailyProcessingCount();
    return count < AppLimits.freeMaxDailyProcessing;
  }

  /// MediaPipe segmentasyon + lokal texture overlay pipeline'ını çalıştırır.
  /// Tümü cihaz üzerinde, API yok.
  Future<Uint8List?> processPhoto() async {
    final userPhoto = _ref.read(selectedUserPhotoProvider);
    final selectedHijab = _ref.read(selectedHijabProvider);

    if (userPhoto == null || selectedHijab == null) return null;

    final hijabFile = File(selectedHijab.path);

    state = const AsyncValue.loading();
    _ref.read(isProcessingProvider.notifier).state = true;

    try {
      final textureService = _ref.read(textureOverlayServiceProvider);
      final mediaPipeService = _ref.read(mediaPipeServiceProvider);

      final result = await textureService.processPhotoMode(
        userPhoto: userPhoto,
        hijabProduct: hijabFile,
        mediaPipeService: mediaPipeService,
      );

      // Günlük sayacı artır
      final storage = _ref.read(storageServiceProvider);
      await storage.incrementDailyCount();

      _ref.read(resultImageProvider.notifier).state = result;
      state = AsyncValue.data(result);
      _ref.read(isProcessingProvider.notifier).state = false;

      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(isProcessingProvider.notifier).state = false;
      return null;
    }
  }

  void reset() {
    _ref.read(selectedUserPhotoProvider.notifier).state = null;
    _ref.read(resultImageProvider.notifier).state = null;
    _ref.read(isProcessingProvider.notifier).state = false;
    state = const AsyncValue.data(null);
  }
}
