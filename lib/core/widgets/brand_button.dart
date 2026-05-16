import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Spec v2 Bolum 8 — 3 varyantli birincil aksiyon butonu.
///
/// primary  : dolu bordo + krem yazi
/// secondary: kontur, altin border
/// ghost    : duz metin, alti cizgili olabilir
enum BrandButtonVariant { primary, secondary, ghost }

class BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BrandButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const BrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BrandButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;
    final child = loading
        ? const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final button = switch (variant) {
      BrandButtonVariant.primary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.cream,
            textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: child,
        ),
      BrandButtonVariant.secondary => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.gold, width: 1.2),
            textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: child,
        ),
      BrandButtonVariant.ghost => TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          child: child,
        ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
