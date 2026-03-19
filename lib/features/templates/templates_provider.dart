import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_template.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/image_utils.dart';
import '../home/home_provider.dart';

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, List<UserTemplate>>((ref) {
  return TemplatesNotifier(ref.watch(storageServiceProvider));
});

class TemplatesNotifier extends StateNotifier<List<UserTemplate>> {
  final StorageService _storage;

  TemplatesNotifier(this._storage) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.getTemplates();
  }

  Future<File?> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<File?> pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> addTemplate(File imageFile, String name) async {
    final savedPath = await ImageUtils.saveTemplateLocally(imageFile);
    final template = UserTemplate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      imagePath: savedPath,
    );
    await _storage.addTemplate(template);
    _load();
  }

  Future<void> removeTemplate(String id) async {
    await _storage.removeTemplate(id);
    _load();
  }

  Future<void> renameTemplate(String id, String newName) async {
    await _storage.updateTemplateName(id, newName);
    _load();
  }

  bool get canAddMore => _storage.canAddTemplate();
}
