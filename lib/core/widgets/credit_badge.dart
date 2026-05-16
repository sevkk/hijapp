import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Spec v2 Bolum 8 — bordo+altin rozet: rakam + 'deneme' yazisi.
class CreditBadge extends StatelessWidget {
  final int credits;
  final String suffix;
  final bool compact;
  final VoidCallback? onTap;

  const CreditBadge({
    super.key,
    required this.credits,
    this.suffix = 'deneme',
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.gold, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond_outlined, size: compact ? 14 : 16, color: AppColors.goldLight),
            const SizedBox(width: 6),
            Text(
              '$credits',
              style: GoogleFonts.inter(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              suffix,
              style: GoogleFonts.inter(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
