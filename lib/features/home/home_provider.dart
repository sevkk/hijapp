import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/hijab_image.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/image_utils.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPrefsProvider));
});

final recentHijabsProvider =
    StateNotifierProvider<RecentHijabsNotifier, List<HijabImage>>((ref) {
  return RecentHijabsNotifier(ref.watch(storageServiceProvider));
});

final selectedHijabProvider = StateProvider<HijabImage?>((ref) => null);

class RecentHijabsNotifier extends StateNotifier<List<HijabImage>> {
  final StorageService _storage;

  RecentHijabsNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getRecentHijabs();
  }

  Future<HijabImage?> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return _addHijab(File(picked.path));
  }

  Future<HijabImage?> pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked == null) return null;
    return _addHijab(File(picked.path));
  }

  Future<HijabImage> _addHijab(File file) async {
    final savedPath = await ImageUtils.saveImageLocally(file);
    final hijab = HijabImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: savedPath,
    );
    await _storage.addRecentHijab(hijab);
    _load();
    return hijab;
  }
}
