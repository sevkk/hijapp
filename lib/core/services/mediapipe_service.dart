import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MediaPipeService {
  late final FaceDetector _faceDetector;

  MediaPipeService() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  /// Kamera frame'inden yüz konturlarını tespit eder.
  /// Başörtüsü bölgesini hesaplar ve polygon noktaları döner.
  Future<List<Offset>?> detectHijabRegion(
    CameraImage image,
    InputImageMetadata metadata,
  ) async {
    final inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: metadata,
    );

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;

    // Yüz konturlarından başörtüsü bölgesini türet
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour == null) return null;

    return _calculateHijabPolygon(faceContour.points, face.boundingBox);
  }

  /// Dosyadan hijab bölgesi tespit eder (fotoğraf modu için).
  Future<List<Offset>?> detectHijabRegionFromFile(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour == null) return null;

    return _calculateHijabPolygon(faceContour.points, face.boundingBox);
  }

  /// Dosyadan hijab mask (binary PNG) oluşturur (fotoğraf modu için).
  Future<Uint8List> generateHijabMask(File imageFile) async {
    // 1. Orijinal görsel boyutlarını al
    final bytes = await imageFile.readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final imageWidth = frame.image.width;
    final imageHeight = frame.image.height;
    frame.image.dispose();

    // 2. Hijab bölgesini tespit et
    final polygon = await detectHijabRegionFromFile(imageFile);
    if (polygon == null || polygon.isEmpty) {
      throw Exception(
        'Başörtüsü bölgesi tespit edilemedi. '
        'Lütfen yüzünüzün net göründüğü bir fotoğraf kullanın.',
      );
    }

    // 3. Siyah-beyaz mask oluştur (beyaz = başörtüsü bölgesi)
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(imageWidth.toDouble(), imageHeight.toDouble());

    // Siyah arka plan
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF000000),
    );

    // Beyaz polygon (başörtüsü bölgesi)
    final path = Path();
    path.moveTo(polygon.first.dx, polygon.first.dy);
    for (final point in polygon.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    // Yumuşak kenarlar için feather efekti
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    // Kenarları daha da yumuşat
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // PNG'ye dönüştür
    final picture = recorder.endRecording();
    final maskImage = await picture.toImage(imageWidth, imageHeight);
    final byteData = await maskImage.toByteData(format: ImageByteFormat.png);
    maskImage.dispose();

    if (byteData == null) {
      throw Exception('Mask görseli oluşturulamadı');
    }

    return byteData.buffer.asUint8List();
  }

  /// Yüz konturundan başörtüsü bölgesi polygon'unu hesaplar.
  List<Offset> _calculateHijabPolygon(
    List<Point<int>> facePoints,
    Rect boundingBox,
  ) {
    final topExpansion = boundingBox.height * 0.6;
    final sideExpansion = boundingBox.width * 0.15;

    final hijabPoints = <Offset>[];

    for (final point in facePoints) {
      double x = point.x.toDouble();
      double y = point.y.toDouble();

      // Üst yarıdaki noktaları yukarı kaydır
      if (y < boundingBox.center.dy) {
        y -= topExpansion;
        if (x < boundingBox.center.dx) {
          x -= sideExpansion;
        } else {
          x += sideExpansion;
        }
      }

      hijabPoints.add(Offset(x, y));
    }

    return hijabPoints;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = <int>[];
    for (final plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  void dispose() {
    _faceDetector.close();
  }
}

final mediaPipeServiceProvider = Provider<MediaPipeService>((ref) {
  return MediaPipeService();
});
