import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/router.dart';
import '../../core/models/boutique_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/constants.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final recentHijabs = ref.watch(recentHijabsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 28),
                      _buildUploadArea(context, ref),
                      const SizedBox(height: 28),
                      _buildRecentSection(context, ref, recentHijabs),
                      const SizedBox(height: 20),
                      _buildConnectedBoutiques(context, ref),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildBottomButtons(context, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userAsync = ref.watch(currentUserModelProvider(uid));
    final credits = userAsync.maybeWhen(
      data: (user) => user?.credits ?? 0,
      orElse: () => 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Credits badge — real-time stream
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRouter.credits),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.toll, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '$credits Kredi',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Profile / Sign out
        PopupMenuButton<String>(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outlined, size: 20, color: AppColors.textPrimary),
          ),
          onSelected: (value) async {
            if (value == 'signout') {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRouter.onboarding, (r) => false);
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Çıkış Yap', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ],
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
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
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

  Widget _buildRecentSection(BuildContext context, WidgetRef ref, List recentHijabs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentlyUsed,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              ...recentHijabs.map((hijab) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildRecentHijabItem(context, ref, hijab),
                  )),
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
        width: 90,
        height: 90,
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
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
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

  Widget _buildConnectedBoutiques(BuildContext context, WidgetRef ref) {
    final boutiquesAsync = ref.watch(connectedBoutiquesProvider);

    return boutiquesAsync.when(
      data: (boutiques) {
        if (boutiques.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Butiklerim',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: boutiques.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _buildBoutiqueCard(context, boutiques[index]),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBoutiqueCard(BuildContext context, BoutiqueModel boutique) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.boutiqueCatalog, arguments: boutique.id),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (boutique.logoUrl != null && boutique.logoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: boutique.logoUrl!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.storefront_outlined,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              const Icon(Icons.storefront_outlined, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              boutique.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.storefront_outlined,
            label: 'Referans Kodu',
            color: AppColors.primary,
            onTap: () => Navigator.pushNamed(context, AppRouter.referral),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.toll,
            label: 'Kredi Al',
            color: AppColors.secondary,
            onTap: () => Navigator.pushNamed(context, AppRouter.credits),
          ),
        ),
      ],
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
