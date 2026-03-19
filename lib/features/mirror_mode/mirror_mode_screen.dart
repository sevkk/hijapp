import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/router.dart';
import '../../core/services/mediapipe_service.dart';
import '../../core/utils/constants.dart';
import '../home/home_provider.dart';
import 'mirror_mode_provider.dart';

class MirrorModeScreen extends ConsumerStatefulWidget {
  const MirrorModeScreen({super.key});

  @override
  ConsumerState<MirrorModeScreen> createState() => _MirrorModeScreenState();
}

class _MirrorModeScreenState extends ConsumerState<MirrorModeScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;

  List<Offset>? _hijabPolygon;
  bool _isProcessingFrame = false;
  int _frameCount = 0;

  bool _isRecording = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  final bool _isPremium = false;

  late MediaPipeService _mediaPipeService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mediaPipeService = ref.read(mediaPipeServiceProvider);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    _mediaPipeService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Ön kamera varsayılan
    _currentCameraIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (_currentCameraIndex < 0) _currentCameraIndex = 0;

    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      await _cameraController!.startImageStream(_processFrame);

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Kamera başlatılamadı: $e');
    }
  }

  void _processFrame(CameraImage image) {
    if (_frameCount++ % 3 != 0) return;
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    final camera = _cameras[_currentCameraIndex];
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _getRotation(camera),
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    _mediaPipeService.detectHijabRegion(image, metadata).then((polygon) {
      if (mounted) {
        setState(() {
          _hijabPolygon = polygon;
          _isProcessingFrame = false;
        });
      }
    }).catchError((_) {
      _isProcessingFrame = false;
    });
  }

  InputImageRotation _getRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    setState(() => _isCameraInitialized = false);
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();
      final xFile = await _cameraController!.takePicture();
      if (mounted) {
        _showPhotoPreview(xFile.path);
      }
      if (_cameraController!.value.isInitialized) {
        await _cameraController!.startImageStream(_processFrame);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf çekilemedi: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (!_isPremium) {
      Navigator.pushNamed(context, AppRouter.premium);
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isRecording) {
      final xFile = await _cameraController!.stopVideoRecording();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      if (mounted) _showVideoSaved(xFile.path);
    } else {
      // Stream'i durdur çünkü video recording ile birlikte çalışmıyor
      await _cameraController!.stopImageStream();
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
      _startRecordingTimer();
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showPhotoPreview(String path) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PhotoPreviewSheet(
        imagePath: path,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showVideoSaved(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Video kaydedildi!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Paylaş',
          textColor: Colors.white,
          onPressed: () async {
            await Share.shareXFiles([XFile(path)]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedHijab = ref.watch(selectedHijabProvider);

    // Hijab desen görseli
    ui.Image? patternImage;
    if (selectedHijab != null) {
      final asyncImage =
          ref.watch(hijabPatternImageProvider(selectedHijab.path));
      patternImage = asyncImage.valueOrNull;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.mirrorMode,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (selectedHijab != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.file(
                    File(selectedHijab.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera preview
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Hijab overlay
          if (_hijabPolygon != null && patternImage != null)
            CustomPaint(
              painter: HijabOverlayPainter(
                polygon: _hijabPolygon,
                patternImage: patternImage,
              ),
            ),

          // Kayıt göstergesi
          if (_isRecording) _buildRecordingIndicator(),

          // Alt kontroller
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 56,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_recordingDuration),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 32,
          right: 32,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Kamera değiştir
            _ControlButton(
              icon: Icons.cameraswitch_outlined,
              size: 48,
              onTap: _switchCamera,
            ),
            // Fotoğraf çek
            _CaptureButton(
              isRecording: _isRecording,
              onTap: _takePhoto,
            ),
            // Video kayıt
            _ControlButton(
              icon: _isRecording
                  ? Icons.stop
                  : (_isPremium
                      ? Icons.videocam_outlined
                      : Icons.videocam_off_outlined),
              size: 48,
              showLock: !_isPremium && !_isRecording,
              isRecording: _isRecording,
              onTap: _toggleVideoRecording,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool showLock;
  final bool isRecording;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.showLock = false,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isRecording
                  ? Colors.red
                  : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
          if (showLock)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const _CaptureButton({
    required this.isRecording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewSheet extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClose;

  const _PhotoPreviewSheet({
    required this.imagePath,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final bytes = await File(imagePath).readAsBytes();
                    await ImageGallerySaverPlus.saveImage(
                      bytes,
                      quality: 100,
                      name: 'hijapp_mirror_${DateTime.now().millisecondsSinceEpoch}',
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Galeriye kaydedildi!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_alt_outlined, size: 18),
                  label: const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Share.shareXFiles([XFile(imagePath)],
                        text: 'HIJAPP ile denedim!');
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Paylaş'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HijabOverlayPainter extends CustomPainter {
  final List<Offset>? polygon;
  final ui.Image? patternImage;

  HijabOverlayPainter({this.polygon, this.patternImage});

  @override
  void paint(Canvas canvas, Size size) {
    if (polygon == null || polygon!.isEmpty) return;

    final path = Path();
    path.moveTo(polygon!.first.dx, polygon!.first.dy);
    for (final point in polygon!.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    if (patternImage != null) {
      canvas.save();
      canvas.clipPath(path);
      final bounds = path.getBounds();
      canvas.drawImageRect(
        patternImage!,
        Rect.fromLTWH(
          0,
          0,
          patternImage!.width.toDouble(),
          patternImage!.height.toDouble(),
        ),
        bounds,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(HijabOverlayPainter oldDelegate) =>
      polygon != oldDelegate.polygon;
}
