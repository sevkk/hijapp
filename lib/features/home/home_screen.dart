import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/router.dart';
import '../../core/utils/constants.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentHijabs = ref.watch(recentHijabsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildUploadArea(context, ref),
              const SizedBox(height: 32),
              _buildRecentSection(context, ref, recentHijabs),
              const Spacer(),
              _buildBottomButtons(context, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ).createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Virtual Hijab Try-On',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _pickHijabFromGallery(context, ref),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.uploadHijab,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection(
      BuildContext context, WidgetRef ref, List recentHijabs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentlyUsed,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${recentHijabs.length}/${AppLimits.freeMaxRecentHijabs}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              ...recentHijabs.map((hijab) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildRecentHijabItem(context, ref, hijab),
                  )),
              if (recentHijabs.length < AppLimits.freeMaxRecentHijabs)
                _buildAddNewItem(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHijabItem(BuildContext context, WidgetRef ref, dynamic hijab) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedHijabProvider.notifier).state = hijab;
        Navigator.pushNamed(context, AppRouter.photoMode);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            File(hijab.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewItem(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _pickHijabFromGallery(context, ref),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary, size: 28),
            const SizedBox(height: 4),
            Text(
              AppStrings.addNew,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickHijabFromGallery(context, ref),
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text(AppStrings.pickFromGallery),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickHijabFromCamera(context, ref),
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: const Text(AppStrings.takePhoto),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickHijabFromGallery(BuildContext context, WidgetRef ref) async {
    final hijab = await ref.read(recentHijabsProvider.notifier).pickFromGallery();
    if (hijab != null && context.mounted) {
      ref.read(selectedHijabProvider.notifier).state = hijab;
      Navigator.pushNamed(context, AppRouter.photoMode);
    }
  }

  Future<void> _pickHijabFromCamera(BuildContext context, WidgetRef ref) async {
    final hijab = await ref.read(recentHijabsProvider.notifier).pickFromCamera();
    if (hijab != null && context.mounted) {
      ref.read(selectedHijabProvider.notifier).state = hijab;
      Navigator.pushNamed(context, AppRouter.photoMode);
    }
  }

}
