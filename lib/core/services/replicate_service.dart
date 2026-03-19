import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ReplicateException implements Exception {
  final String message;
  final int? statusCode;

  ReplicateException(this.message, {this.statusCode});

  @override
  String toString() => 'ReplicateException: $message';
}

class ReplicateService {
  // API key'i --dart-define ile ver:
  // flutter run --dart-define=REPLICATE_API_KEY=r8_xxx
  static const String _apiKey =
      String.fromEnvironment('REPLICATE_API_KEY', defaultValue: '');
  static const String _baseUrl = 'https://api.replicate.com/v1';
  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _maxWait = Duration(seconds: 90);

  final Map<String, String> _headers;

  ReplicateService()
      : _headers = {
          'Authorization': 'Token $_apiKey',
          'Content-Type': 'application/json',
        };

  /// prunaai/p-image-edit ile hijab try-on.
  /// Kullanıcı fotoğrafı + ürün deseni alır, sonuç görseli döner.
  /// Tek API çağrısı — segmentasyon gerekmez.
  Future<Uint8List> processHijabTryOn(
    File userPhoto,
    File hijabProduct,
  ) async {
    try {
      final userBase64 = base64Encode(await userPhoto.readAsBytes());
      final productBase64 = base64Encode(await hijabProduct.readAsBytes());

      final userUri = 'data:image/jpeg;base64,$userBase64';
      final productUri = 'data:image/jpeg;base64,$productBase64';

      debugPrint('HIJAPP DEBUG: p-image-edit başlıyor...');

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
      debugPrint('HIJAPP DEBUG: prediction created: $predictionId');

      final result = await _pollPrediction(predictionId);
      final output = result['output'];

      if (output == null) {
        throw ReplicateException('İşlem sonucu boş döndü');
      }

      debugPrint(
          'HIJAPP DEBUG: output type: ${output.runtimeType}');
      return await _downloadOutput(output);
    } catch (e) {
      if (e is ReplicateException) rethrow;
      throw ReplicateException('İşlem hatası: $e');
    }
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
            'HIJAPP DEBUG: rate limited, ${retryAfter}sn bekleniyor... (deneme ${attempt + 1}/3)');
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

      debugPrint('HIJAPP DEBUG: poll status: $status');

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

    debugPrint('HIJAPP DEBUG: downloading from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw ReplicateException(
          'Görsel indirilemedi: ${response.statusCode}');
    }

    debugPrint(
        'HIJAPP DEBUG: downloaded ${response.bodyBytes.length} bytes');
    return response.bodyBytes;
  }
}

final replicateServiceProvider = Provider<ReplicateService>((ref) {
  return ReplicateService();
});
