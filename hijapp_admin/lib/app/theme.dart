import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HIJAPP admin paneli temasi — Saray paleti (Spec v2 Bolum 2).
///
/// Mobil tarafindaki AppColors ile ayni hex degerlerini kullaniyor; admin web
/// projesi pubspec yoluyla mobil paketi import etmedigi icin tokenler burada
/// duplike ediliyor. Hex'leri tek noktada degistirmek isteyince ikisini de
/// guncelle (mobil: lib/core/utils/constants.dart).
class AdminTheme {
  // Saray paleti — mobil ile bire bir
  static const Color primary = Color(0xFF4B1528); // bordo
  static const Color primaryLight = Color(0xFF72243E);
  static const Color cream = Color(0xFFF8F2E8);
  static const Color creamSoft = Color(0xFFFBF6EE);
  static const Color gold = Color(0xFFB8895E);
  static const Color goldLight = Color(0xFFFAC775);
  static const Color sage = Color(0xFF8FA68A);
  static const Color inkBlack = Color(0xFF2A1F25);
  static const Color inkMuted = Color(0xFF6B5A60);
  static const Color border = Color(0xFFE8DDD0);
  static const Color error = Color(0xFFB23A48);
  static const Color success = sage;

  // Admin shell ozel — koyu sidebar yerine bordo-yumusak panel
  static const Color background = cream;
  static const Color surface = creamSoft;
  static const Color textPrimary = inkBlack;
  static const Color textSecondary = inkMuted;
  static const Color sidebar = primary;
  static const Color sidebarText = cream;
  static const Color sidebarActive = gold;

  // Geri-uyum alias'i (eski ekranlar AdminTheme.secondary kullaniyordu)
  static const Color secondary = gold;

  static ThemeData get theme {
    final baseText = GoogleFonts.interTextTheme();
    final displayFamily = GoogleFonts.playfairDisplay().fontFamily;
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: cream,
        secondary: gold,
        onSecondary: inkBlack,
        tertiary: sage,
        surface: creamSoft,
        onSurface: inkBlack,
        error: error,
        onError: cream,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontFamily: displayFamily,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(color: inkBlack),
        bodyMedium: baseText.bodyMedium?.copyWith(color: inkBlack),
        bodySmall: baseText.bodySmall?.copyWith(color: inkMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: inkBlack),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: GoogleFonts.inter(color: inkMuted, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: inkMuted, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.5,
        space: 0.5,
      ),
    );
  }
}
