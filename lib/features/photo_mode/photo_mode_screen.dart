import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/router.dart';
import '../../core/models/user_template.dart';
import '../../core/utils/constants.dart';
import '../home/home_provider.dart';
import 'photo_mode_provider.dart';

class PhotoModeScreen extends ConsumerWidget {
  const PhotoModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHijab = ref.watch(selectedHijabProvider);
    final userPhoto = ref.watch(selectedUserPhotoProvider);
    final isProcessing = ref.watch(isProcessingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.photoMode,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            ref.read(photoModeNotifierProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Seçili hijab önizleme
                  _buildHijabPreview(selectedHijab),
                  const SizedBox(height: 24),
                  // Kullanıcı fotoğrafı seçim alanı
                  _buildUserPhotoSection(context, ref, userPhoto),
                  const Spacer(),
                  // Dene butonu
                  _buildTryButton(context, ref, userPhoto, isProcessing),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildHijabPreview(dynamic selectedHijab) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: selectedHijab != null
                ? Image.file(
                    File(selectedHijab.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_outlined,
                      color: AppColors.textSecondary,
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seçili Başörtüsü',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Desen uygulanacak',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserPhotoSection(
      BuildContext context, WidgetRef ref, File? userPhoto) {
    return Expanded(
      flex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kendi fotoğrafını seç',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (userPhoto != null) _buildPhotoPreview(ref, userPhoto),
          if (userPhoto == null) _buildPhotoOptions(context, ref),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(WidgetRef ref, File photo) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Image.file(
                  photo,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedUserPhotoProvider.notifier).state = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoOptions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildOptionCard(
          icon: Icons.photo_library_outlined,
          title: 'Galeriden Seç',
          subtitle: 'Mevcut bir fotoğrafını kullan',
          onTap: () =>
              ref.read(photoModeNotifierProvider.notifier).pickUserPhotoFromGallery(),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.camera_alt_outlined,
          title: 'Anlık Çek',
          subtitle: 'Şimdi bir selfie çek',
          onTap: () =>
              ref.read(photoModeNotifierProvider.notifier).pickUserPhotoFromCamera(),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.collections_outlined,
          title: 'Taslak Fotoğraflarım',
          subtitle: 'Kayıtlı fotoğraflarından seç',
          onTap: () async {
            final template = await Navigator.pushNamed(
              context,
              AppRouter.templates,
              arguments: true,
            );
            if (template != null && template is UserTemplate) {
              ref.read(selectedUserPhotoProvider.notifier).state =
                  File(template.imagePath);
            }
          },
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: enabled ? AppColors.primary : AppColors.divider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryButton(
    BuildContext context,
    WidgetRef ref,
    File? userPhoto,
    bool isProcessing,
  ) {
    final isEnabled = userPhoto != null && !isProcessing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _onTryPressed(context, ref) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.primary : AppColors.divider,
          foregroundColor:
              isEnabled ? Colors.white : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Dene!',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _onTryPressed(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(photoModeNotifierProvider.notifier);

    // Günlük limit kontrolü
    if (!notifier.canProcess()) {
      if (context.mounted) {
        Navigator.pushNamed(context, AppRouter.premium);
      }
      return;
    }

    // İşlemi başlat
    final result = await notifier.processPhoto();

    if (!context.mounted) return;

    if (result != null) {
      Navigator.pushNamed(
        context,
        AppRouter.result,
        arguments: result,
      );
    } else {
      // Hata durumu
      final state = ref.read(photoModeNotifierProvider);
      final errorMessage = state.whenOrNull(
            error: (e, _) => e is Exception ? e.toString() : 'Bir hata oluştu',
          ) ??
          'Bir hata oluştu';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Başörtüsü deseni\nuygulanıyor...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu işlem birkaç saniye sürebilir',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
