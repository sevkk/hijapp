import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ReplicateException implements Exception {
  final String message;
  final int? statusCode;

  ReplicateException(this.message, {this.statusCode});

  @override
  String toString() => 'ReplicateException: $message';
}

class ReplicateService {
  // flutter run --dart-define=REPLICATE_API_KEY=r8_xxx
  // flutter run --dart-define=REPLICATE_API_KEY=r8_xxx --dart-define=MOCK_MODE=true
  static const String _apiKey =
      String.fromEnvironment('REPLICATE_API_KEY', defaultValue: '');
  static const bool _mockMode =
      bool.fromEnvironment('MOCK_MODE', defaultValue: false);
  static const String _baseUrl = 'https://api.replicate.com/v1';
  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _maxWait = Duration(seconds: 90);

  final Map<String, String> _headers;

  ReplicateService()
      : _headers = {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        };

  /// Mock mode aktif mi?
  bool get isMockMode => _mockMode;

  /// prunaai/p-image-edit ile hijab try-on.
  /// Önce cache kontrol eder. Cache varsa API çağrısı yapmaz.
  /// Mock mode'da her zaman lokal overlay döner.
  Future<Uint8List> processHijabTryOn(
    File userPhoto,
    File hijabProduct,
  ) async {
    if (_mockMode) {
      return _mockProcessing(userPhoto, hijabProduct);
    }

    // Cache kontrol
    final cacheKey = await _generateCacheKey(userPhoto, hijabProduct);
    final cached = await _getFromCache(cacheKey);
    if (cached != null) {
      debugPrint('HIJAPP CACHE: Sonuç cache\'ten döndürüldü (API çağrısı yok)');
      return cached;
    }

    final result = await _apiProcessing(userPhoto, hijabProduct);

    // Sonucu cache'e kaydet
    await _saveToCache(cacheKey, result);
    debugPrint('HIJAPP CACHE: Sonuç cache\'e kaydedildi');

    return result;
  }

  /// İki görselin hash'inden benzersiz cache key oluşturur.
  Future<String> _generateCacheKey(File file1, File file2) async {
    final bytes1 = await file1.readAsBytes();
    final bytes2 = await file2.readAsBytes();
    final combined = md5.convert([...bytes1, ...bytes2]);
    return combined.toString();
  }

  /// Cache'ten sonuç döndürür. Yoksa null.
  Future<Uint8List?> _getFromCache(String key) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${dir.path}/hijapp_cache/$key.png');
      if (await cacheFile.exists()) {
        return cacheFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('HIJAPP CACHE: Okuma hatası: $e');
    }
    return null;
  }

  /// Sonucu cache'e kaydeder.
  Future<void> _saveToCache(String key, Uint8List data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/hijapp_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      final cacheFile = File('${cacheDir.path}/$key.png');
      await cacheFile.writeAsBytes(data);
    } catch (e) {
      debugPrint('HIJAPP CACHE: Kaydetme hatası: $e');
    }
  }

  /// MOCK: Basit Canvas overlay — API çağrısı yok, $0 maliyet.
  /// Hijab desenini yarı şeffaf olarak fotoğrafın üst bölgesine yerleştirir.
  Future<Uint8List> _mockProcessing(
    File userPhoto,
    File hijabProduct,
  ) async {
    debugPrint('HIJAPP MOCK: Mock mode aktif, API çağrısı yapılmıyor');

    final userBytes = await userPhoto.readAsBytes();
    final productBytes = await hijabProduct.readAsBytes();

    final userImage = await _decodeImage(userBytes);
    final productImage = await _decodeImage(productBytes);

    final w = userImage.width;
    final h = userImage.height;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Kullanıcı fotoğrafını çiz
    canvas.drawImage(userImage, Offset.zero, Paint());

    // Hijab desenini yarı şeffaf olarak üst bölgeye yerleştir
    final hijabArea = Rect.fromLTWH(
      0,
      0,
      w.toDouble(),
      h * 0.5, // üst yarı
    );

    canvas.saveLayer(hijabArea, Paint());
    canvas.drawImageRect(
      productImage,
      Rect.fromLTWH(
        0, 0,
        productImage.width.toDouble(),
        productImage.height.toDouble(),
      ),
      hijabArea,
      Paint()..filterQuality = FilterQuality.high,
    );
    // Yarı şeffaf yap
    canvas.drawRect(
      hijabArea,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..blendMode = BlendMode.dstIn,
    );
    canvas.restore();

    // "MOCK" watermark ekle
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'MOCK MODE',
        style: TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(w / 2 - textPainter.width / 2, h - 60),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // Gerçekçi gecikme simülasyonu
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('HIJAPP MOCK: Mock sonuç oluşturuldu');
    return byteData!.buffer.asUint8List();
  }

  /// GERÇEK API: prunaai/p-image-edit çağrısı, $0.01/işlem.
  Future<Uint8List> _apiProcessing(
    File userPhoto,
    File hijabProduct,
  ) async {
    try {
      final userBase64 = base64Encode(await userPhoto.readAsBytes());
      final productBase64 = base64Encode(await hijabProduct.readAsBytes());

      final userUri = 'data:image/jpeg;base64,$userBase64';
      final productUri = 'data:image/jpeg;base64,$productBase64';

      debugPrint('HIJAPP API: p-image-edit başlıyor...');

      final prediction = await _createPrediction(
        version:
            '05a6b136010c1590ff0de1a473b5bc8a5aa221359229f9a69b230d093503eae0',
        input: {
          'images': [userUri, productUri],
          'prompt':
              'Replace the hijab/headscarf in image 1 with the fabric pattern shown in image 2. '
                  'Keep the person\'s face, skin, pose, expression, and background exactly the same. '
                  'Only change the hijab/headscarf area to match the pattern, color, and texture from image 2. '
                  'The result should look like a natural, photorealistic photo of the person wearing a hijab made from the fabric in image 2.',
          'turbo': true,
        },
      );

      final predictionId = prediction['id'] as String;
      debugPrint('HIJAPP API: prediction created: $predictionId');

      final result = await _pollPrediction(predictionId);
      final output = result['output'];

      if (output == null) {
        throw ReplicateException('İşlem sonucu boş döndü');
      }

      debugPrint('HIJAPP API: output type: ${output.runtimeType}');
      return await _downloadOutput(output);
    } catch (e) {
      if (e is ReplicateException) rethrow;
      throw ReplicateException('İşlem hatası: $e');
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<Map<String, dynamic>> _createPrediction({
    String? version,
    required Map<String, dynamic> input,
  }) async {
    final body = <String, dynamic>{'input': input};
    if (version != null) body['version'] = version;

    for (int attempt = 0; attempt < 3; attempt++) {
      final response = await http.post(
        Uri.parse('$_baseUrl/predictions'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 429) {
        final responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;
        final retryAfter = responseBody['retry_after'] as int? ?? 5;
        debugPrint(
            'HIJAPP API: rate limited, ${retryAfter}sn bekleniyor... (deneme ${attempt + 1}/3)');
        await Future.delayed(Duration(seconds: retryAfter + 1));
        continue;
      }

      throw ReplicateException(
        'Prediction oluşturulamadı: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    throw ReplicateException(
        'Rate limit aşıldı, lütfen biraz bekleyip tekrar deneyin');
  }

  Future<Map<String, dynamic>> _pollPrediction(String predictionId) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < _maxWait) {
      final response = await http.get(
        Uri.parse('$_baseUrl/predictions/$predictionId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String;

      debugPrint('HIJAPP API: poll status: $status');

      switch (status) {
        case 'succeeded':
          return data;
        case 'failed':
          final error = data['error'] ?? 'Bilinmeyen hata';
          throw ReplicateException('İşlem başarısız: $error');
        case 'canceled':
          throw ReplicateException('İşlem iptal edildi');
        default:
          await Future.delayed(_pollInterval);
      }
    }

    throw ReplicateException('İşlem zaman aşımına uğradı (90sn)');
  }

  Future<Uint8List> _downloadOutput(dynamic output) async {
    String url;

    if (output is List && output.isNotEmpty) {
      url = output[0] as String;
    } else if (output is String) {
      if (output.startsWith('data:')) {
        final base64Part = output.split(',').last;
        return base64Decode(base64Part);
      }
      url = output;
    } else if (output is Map) {
      final firstUrl = output.values.firstWhere(
        (v) => v is String && v.startsWith('http'),
        orElse: () => null,
      );
      if (firstUrl != null) {
        url = firstUrl as String;
      } else {
        throw ReplicateException('Output URL bulunamadı');
      }
    } else {
      throw ReplicateException('Beklenmeyen output formatı: $output');
    }

    debugPrint('HIJAPP API: downloading from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw ReplicateException(
          'Görsel indirilemedi: ${response.statusCode}');
    }

    debugPrint(
        'HIJAPP API: downloaded ${response.bodyBytes.length} bytes');
    return response.bodyBytes;
  }
}

final replicateServiceProvider = Provider<ReplicateService>((ref) {
  return ReplicateService();
});
