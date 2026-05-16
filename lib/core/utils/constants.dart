import 'package:flutter/material.dart';

/// HIJAPP "Saray" palette (Spec v2, Bolum 2.1).
///
/// Eski isimler (primary/secondary/tertiary/background/surface/surfaceLight/
/// textPrimary/textSecondary/divider) yeni hex degerleriyle korunuyor;
/// boylece var olan 200+ ekran referansi otomatik olarak yeni paleti aliyor.
/// Yeni semantik isimler (cream, gold, sage, inkBlack, ...) spec'le bire bir
/// eslesir ve sonraki ekranlar bunlari kullanmali.
class AppColors {
  // --- Spec tokens (kanonik) ---
  static const Color primary = Color(0xFF4B1528);
  static const Color primaryLight = Color(0xFF72243E);
  static const Color cream = Color(0xFFF8F2E8);
  static const Color creamSoft = Color(0xFFFBF6EE);
  static const Color gold = Color(0xFFB8895E);
  static const Color goldLight = Color(0xFFFAC775);
  static const Color sage = Color(0xFF8FA68A);
  static const Color inkBlack = Color(0xFF2A1F25);
  static const Color inkMuted = Color(0xFF6B5A60);
  static const Color border = Color(0xFFE8DDD0);
  static const Color white = Colors.white;
  static const Color error = Color(0xFFB23A48);

  // --- Geri-uyum alias'lari (eski ekranlar icin) ---
  static const Color secondary = primaryLight;
  static const Color tertiary = gold;
  static const Color background = cream;
  static const Color surface = creamSoft;
  static const Color surfaceLight = creamSoft;
  static const Color textPrimary = inkBlack;
  static const Color textSecondary = inkMuted;
  static const Color divider = border;
  static const Color success = sage;
}

class AppStrings {
  static const String appName = 'HIJAPP';
  static const String uploadHijab = 'Denemek istedigin basortusunu yukle';
  static const String recentlyUsed = 'Son Kullandiklarin';
  static const String pickFromGallery = 'Galeriden Sec';
  static const String takePhoto = 'Fotograf Cek';
  static const String photoMode = 'Fotograf Modu';
  static const String addNew = 'Yeni Ekle';
  static const String credits = 'Kredi';
  static const String buyCredits = 'Kredi Satin Al';
  static const String enterReferralCode = 'Referans Kodu Gir';
  static const String tryOn = 'Dene';
  static const String buyNow = 'Satin Al';
  static const String boutiqueProducts = 'Butik Urunleri';
  static const String remainingCredits = 'Kalan Kredi';
  static const String noCredits = 'Kredin kalmadi';
}

// B2C consumer packages (Spec v2 Bolum 0).
class CreditPackages {
  static const List<Map<String, dynamic>> b2c = [
    {'credits': 10, 'price': 49.0, 'label': '10 Deneme', 'id': 'credits_10'},
    {'credits': 25, 'price': 99.0, 'label': '25 Deneme', 'id': 'credits_25'},
    {'credits': 50, 'price': 169.0, 'label': '50 Deneme', 'id': 'credits_50', 'popular': true},
    {'credits': 100, 'price': 299.0, 'label': '100 Deneme', 'id': 'credits_100'},
  ];

  // Butik kredi paketleri — 5 kademeli segment-bazli (Spec v2 Bolum 0 / 6.6 revize).
  static const List<Map<String, dynamic>> b2b = [
    {'credits': 50, 'price': 599.0, 'label': 'Starter', 'id': 'boutique_starter', 'tagline': 'Kucuk butik, ilk deneme'},
    {'credits': 100, 'price': 1000.0, 'label': 'Growth', 'id': 'boutique_growth', 'tagline': 'Ana giris paketi'},
    {'credits': 500, 'price': 4490.0, 'label': 'Pro', 'id': 'boutique_pro', 'tagline': 'Buyuyen butik (-%10)', 'discountPct': 10},
    {'credits': 2000, 'price': 16990.0, 'label': 'Premium', 'id': 'boutique_premium', 'popular': true, 'tagline': 'Markalasmis butik (-%15)', 'discountPct': 15},
    {'credits': 10000, 'price': 79990.0, 'label': 'Enterprise', 'id': 'boutique_enterprise', 'tagline': 'Modanisa olceginde (-%20)', 'discountPct': 20, 'contactSales': true},
  ];
}

class AppLimits {
  static const int freeTrialCredits = 3;
  static const int dailyFreeLimit = 5;
  static const int maxTemplates = 20;
}
