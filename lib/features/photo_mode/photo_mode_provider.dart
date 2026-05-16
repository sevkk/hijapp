import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/replicate_service.dart';
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

  /// Kredi kontrolü — Firestore'dan kullanıcının kredisi var mı diye bakar
  Future<bool> canProcess() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final firestoreService = _ref.read(firestoreServiceProvider);
    final user = await firestoreService.getUser(uid);
    return user != null && user.canProcess;
  }

  /// prunaai/p-image-edit ile hijab try-on.
  /// Tek API çağrısı — kullanıcı fotoğrafı + ürün deseni → sonuç.
  /// 1 kredi düşer (Firestore transaction).
  Future<Uint8List?> processPhoto() async {
    final userPhoto = _ref.read(selectedUserPhotoProvider);
    final selectedHijab = _ref.read(selectedHijabProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (userPhoto == null || selectedHijab == null || uid == null) return null;

    final hijabFile = File(selectedHijab.path);

    state = const AsyncValue.loading();
    _ref.read(isProcessingProvider.notifier).state = true;

    try {
      // Önce kredi düş (atomik transaction)
      final firestoreService = _ref.read(firestoreServiceProvider);
      final success = await firestoreService.useCredit(uid);
      if (!success) {
        throw Exception('Yeterli krediniz yok. Lütfen kredi satın alın.');
      }

      final replicateService = _ref.read(replicateServiceProvider);

      final result = await replicateService.processHijabTryOn(
        userPhoto,
        hijabFile,
      );

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
