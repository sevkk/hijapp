import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Spec v2 Bolum 8 — vitrin gecisi icin butik logosu + isim chip'i.
class BoutiqueChip extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final VoidCallback? onTap;
  final bool selected;

  const BoutiqueChip({
    super.key,
    required this.name,
    this.logoUrl,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.creamSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 24, height: 24,
                child: logoUrl != null && logoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: logoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.border),
                        errorWidget: (_, __, ___) => const Icon(Icons.storefront_outlined, size: 16, color: AppColors.inkMuted),
                      )
                    : Container(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        child: const Icon(Icons.storefront_outlined, size: 14, color: AppColors.inkBlack),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.cream : AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
