import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mediapipe_service.dart';

class TextureOverlayService {
  /// SAM 2'den gelen mask + kullanıcı fotoğrafı + ürün deseni ile
  /// lokal texture overlay yapar, final görseli Uint8List olarak döner.
  Future<Uint8List> applyTextureOverlay({
    required File userPhoto,
    required File hijabProduct,
    required Uint8List maskBytes,
  }) async {
    // 1. Görselleri ui.Image'a dönüştür
    final userImage = await _loadImage(await userPhoto.readAsBytes());
    final productImage = await _loadImage(await hijabProduct.readAsBytes());
    final maskImage = await _loadImage(maskBytes);

    // 2. Canvas ile birleştir
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size =
        Size(userImage.width.toDouble(), userImage.height.toDouble());

    // 2a. Kullanıcı fotoğrafını çiz (arka plan)
    canvas.drawImage(userImage, Offset.zero, Paint());

    // 2b. Ürün desenini mask'ın beyaz alanına uygula
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    // Ürün desenini tile olarak çiz
    final productShader = ImageShader(
      productImage,
      TileMode.repeated,
      TileMode.repeated,
      _calculateFitMatrix(productImage, size),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = productShader,
    );

    // Mask ile blend: sadece mask'ın beyaz olduğu alanı tut
    canvas.drawImage(
      maskImage,
      Offset.zero,
      Paint()..blendMode = BlendMode.dstIn,
    );

    canvas.restore();

    // 2c. Orijinal gölgeleri korumak için multiply katmanı
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    canvas.drawImage(
      userImage,
      Offset.zero,
      Paint()
        ..blendMode = BlendMode.multiply
        ..color = const Color.fromRGBO(255, 255, 255, 0.3),
    );

    // Yine mask ile kırp
    canvas.drawImage(
      maskImage,
      Offset.zero,
      Paint()..blendMode = BlendMode.dstIn,
    );

    canvas.restore();

    // 3. Canvas'ı PNG'ye dönüştür
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Görsel oluşturulamadı');
    }

    return byteData.buffer.asUint8List();
  }

  /// Tek adımda fotoğraf modu pipeline'ı.
  /// MediaPipe ile mask oluştur + texture overlay uygula.
  Future<Uint8List> processPhotoMode({
    required File userPhoto,
    required File hijabProduct,
    required MediaPipeService mediaPipeService,
  }) async {
    // 1. MediaPipe ile mask oluştur
    final maskBytes = await mediaPipeService.generateHijabMask(userPhoto);

    // 2. Texture overlay uygula
    return applyTextureOverlay(
      userPhoto: userPhoto,
      hijabProduct: hijabProduct,
      maskBytes: maskBytes,
    );
  }

  /// Bytes'tan ui.Image'a dönüştürür.
  Future<ui.Image> _loadImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Ürün desenini hedef boyuta sığdırmak için transform matrisi hesaplar.
  Float64List _calculateFitMatrix(ui.Image productImage, Size targetSize) {
    final scaleX = targetSize.width / productImage.width;
    final scaleY = targetSize.height / productImage.height;
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final matrix = Matrix4.identity();
    matrix.storage[0] = scale;
    matrix.storage[5] = scale;
    return matrix.storage;
  }
}

final textureOverlayServiceProvider =
    Provider<TextureOverlayService>((ref) {
  return TextureOverlayService();
});
