import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/utils/constants.dart';

/// HIJAPP "Saray" temasi (Spec v2 Bolum 2).
///
/// Tipografi: Playfair Display (basliklar) + Inter (govde).
/// Renkler: AppColors uzerinden — hex degerlerini ekrana yazma.
/// Koseler: 8/12/14-18. Golge yok; ayrim border + ic dolgu ile.
class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final displayFamily = GoogleFonts.playfairDisplay().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.cream,
        secondary: AppColors.gold,
        onSecondary: AppColors.inkBlack,
        tertiary: AppColors.sage,
        surface: AppColors.creamSoft,
        onSurface: AppColors.inkBlack,
        error: AppColors.error,
        onError: AppColors.cream,
        outline: AppColors.border,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
          fontSize: 24,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
          fontSize: 20,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
          fontSize: 17,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.inkBlack),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.inkBlack),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.inkBlack,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.inkBlack,
        ),
        iconTheme: const IconThemeData(color: AppColors.inkBlack),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.creamSoft,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.creamSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.inkMuted, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.inkMuted, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }
}
