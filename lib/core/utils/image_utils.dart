import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> saveImageLocally(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final hijabDir = Directory('${dir.path}/hijabs');
    if (!await hijabDir.exists()) {
      await hijabDir.create(recursive: true);
    }
    final ext = imageFile.path.split('.').last;
    final fileName = 'hijab_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final savedFile = await imageFile.copy('${hijabDir.path}/$fileName');
    return savedFile.path;
  }

  static Future<String> saveTemplateLocally(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final templateDir = Directory('${dir.path}/templates');
    if (!await templateDir.exists()) {
      await templateDir.create(recursive: true);
    }
    final ext = imageFile.path.split('.').last;
    final fileName = 'template_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final savedFile = await imageFile.copy('${templateDir.path}/$fileName');
    return savedFile.path;
  }
}
