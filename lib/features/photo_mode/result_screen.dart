import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/models/try_on_event_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/constants.dart';
import 'photo_mode_provider.dart';

/// Result screen'e gecirilen argumanlar.
///
/// `imageBytes` zorunlu. Diger alanlar opsiyonel: butik/urun bilgisi
/// boutique catalog -> photo_mode akisindan gelir, b2c kisisel akista null'dur.
/// Geri-uyum: dogrudan `Uint8List` da kabul edilir (eski cagri sekli).
class ResultArgs {
  final Uint8List imageBytes;
  final String? boutiqueId;
  final String? productId;
  final String? referralCodeId;
  final TryOnUserType userType;
  final double costUsd;

  const ResultArgs({
    required this.imageBytes,
    this.boutiqueId,
    this.productId,
    this.referralCodeId,
    this.userType = TryOnUserType.free,
    this.costUsd = 0.01,
  });
}

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late Uint8List _imageBytes;
  ResultArgs? _args;
  String? _savedPath;
  bool _isSaved = false;
  bool _eventLogged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final raw = ModalRoute.of(context)!.settings.arguments;
    if (raw is ResultArgs) {
      _args = raw;
      _imageBytes = raw.imageBytes;
    } else if (raw is Uint8List) {
      _args = ResultArgs(imageBytes: raw);
      _imageBytes = raw;
    } else {
      throw ArgumentError('ResultScreen: invalid arguments type');
    }

    if (!_eventLogged) {
      _eventLogged = true;
      _logTryOnEvent(succeeded: true);
    }

    if (!_isSaved) {
      _autoSave();
    }
  }

  /// Spec v2 Bolum 3.3 / 5.4: basarili try-on'da event log + counter increment.
  /// boutiqueId/productId null ise event hala yazilir (counter'lar atlanir).
  Future<void> _logTryOnEvent({required bool succeeded, String? errorMessage}) async {
    final args = _args;
    if (args == null) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await ref.read(firestoreServiceProvider).logTryOnEvent(
            boutiqueId: args.boutiqueId ?? '',
            productId: args.productId ?? '',
            userId: uid,
            userType: uid == null ? TryOnUserType.anonymous : args.userType,
            referralCodeId: args.referralCodeId,
            succeeded: succeeded,
            costUsd: args.costUsd,
            errorMessage: errorMessage,
          );
    } catch (e) {
      // Event logging hicbir kullanici akisini bozmamali; sessizce gec.
      debugPrint('HIJAPP: try-on event log failed: $e');
    }
  }

  Future<void> _autoSave() async {
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        _imageBytes,
        quality: 100,
        name: 'hijapp_${DateTime.now().millisecondsSinceEpoch}',
      );

      final filePath = result['filePath'] as String?;
      if (mounted) {
        setState(() {
          _isSaved = result['isSuccess'] == true;
          _savedPath = filePath;
        });
        if (_isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Galeriye otomatik kaydedildi'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('HIJAPP: Auto-save failed: $e');
    }
  }

  Future<void> _deleteFromGallery() async {
    // Onay dialogu göster
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Görseli Sil',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Kaydedilen görsel galeriden silinecek. Emin misin?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'İptal',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      // Galeri dosyasını sil
      if (_savedPath != null) {
        final file = File(_savedPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (!mounted) return;

      setState(() {
        _isSaved = false;
        _savedPath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Görsel silindi'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Geri dön
      ref.read(photoModeNotifierProvider.notifier).reset();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silme hatası: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _shareImage() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/hijapp_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'HIJAPP ile denedim!',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşma hatası: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Geri tuşuna basılınca da kayıtlı kalır (otomatik kaydedildi zaten)
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sonuç',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Kayıt durumu
              if (_isSaved)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Galeriye kaydedildi',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              // Sonuç görseli
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      _imageBytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              // Alt butonlar
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.share_outlined,
              label: 'Paylaş',
              color: AppColors.primary,
              onTap: _shareImage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.refresh_outlined,
              label: 'Tekrar Dene',
              color: AppColors.secondary,
              onTap: () {
                ref.read(photoModeNotifierProvider.notifier).reset();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.delete_outline,
              label: 'Sil',
              color: Colors.red.shade400,
              onTap: _isSaved ? _deleteFromGallery : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final effectiveColor = isEnabled ? color : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: effectiveColor, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
