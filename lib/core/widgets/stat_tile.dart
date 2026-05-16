import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'brand_card.dart';

/// Spec v2 Bolum 8 — admin panelde metric card.
/// Buyuk rakam + kucuk label + opsiyonel delta (% degisim) + opsiyonel icon.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.gold),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted, letterSpacing: 0.3),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(
                deltaPositive ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: deltaPositive ? AppColors.sage : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                delta!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: deltaPositive ? AppColors.sage : AppColors.error,
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
