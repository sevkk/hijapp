import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Spec v2 Bolum 8 — kart standart: 12px radius, 0.5px border, 16-24 padding,
/// gölge yok. Premium bir his icin opsiyonel `goldTop` ince altin cizgi.
class BrandCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool goldTop;
  final Color? color;
  final VoidCallback? onTap;

  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.goldTop = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.creamSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: goldTop ? AppColors.gold : AppColors.border, width: goldTop ? 1.2 : 0.5),
          left: const BorderSide(color: AppColors.border, width: 0.5),
          right: const BorderSide(color: AppColors.border, width: 0.5),
          bottom: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: card,
    );
  }
}
