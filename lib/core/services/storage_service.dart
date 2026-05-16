import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hijab_image.dart';
import '../models/user_template.dart';

class StorageService {
  static const _recentHijabsKey = 'recent_hijabs';
  static const _templatesKey = 'user_templates';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  List<HijabImage> getRecentHijabs() {
    final data = _prefs.getStringList(_recentHijabsKey);
    if (data == null) return [];
    return data
        .map((e) => HijabImage.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRecentHijab(HijabImage hijab, {int maxCount = 10}) async {
    final current = getRecentHijabs();
    current.removeWhere((h) => h.path == hijab.path);
    current.insert(0, hijab);
    if (current.length > maxCount) {
      current.removeRange(maxCount, current.length);
    }
    await _prefs.setStringList(
      _recentHijabsKey,
      current.map((h) => jsonEncode(h.toJson())).toList(),
    );
  }

  Future<void> removeRecentHijab(String id) async {
    final current = getRecentHijabs();
    current.removeWhere((h) => h.id == id);
    await _prefs.setStringList(
      _recentHijabsKey,
      current.map((h) => jsonEncode(h.toJson())).toList(),
    );
  }

  // --- Template CRUD ---

  List<UserTemplate> getTemplates() {
    final data = _prefs.getStringList(_templatesKey);
    if (data == null) return [];
    return data
        .map((e) => UserTemplate.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTemplate(UserTemplate template, {int maxCount = 20}) async {
    final current = getTemplates();
    if (current.length >= maxCount) {
      current.removeLast();
    }
    current.insert(0, template);
    await _saveTemplates(current);
  }

  Future<void> removeTemplate(String id) async {
    final current = getTemplates();
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      final template = current[index];
      final file = File(template.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      current.removeAt(index);
      await _saveTemplates(current);
    }
  }

  Future<void> updateTemplateName(String id, String newName) async {
    final current = getTemplates();
    final index = current.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = current[index];
      current[index] = UserTemplate(
        id: old.id,
        name: newName,
        imagePath: old.imagePath,
        createdAt: old.createdAt,
      );
      await _saveTemplates(current);
    }
  }

  Future<void> _saveTemplates(List<UserTemplate> templates) async {
    await _prefs.setStringList(
      _templatesKey,
      templates.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }
}
