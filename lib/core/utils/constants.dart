import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD9078F);
  static const Color secondary = Color(0xFF6FB7BF);
  static const Color tertiary = Color(0xFFD99873);
  static const Color background = Color(0xFFFFF8F4);
  static const Color surface = Color(0xFFF2BEA0);
  static const Color surfaceLight = Color(0xFFFFF0EA);
  static const Color textPrimary = Color(0xFF592512);
  static const Color textSecondary = Color(0xFF8B6B5A);
  static const Color divider = Color(0xFFE8D5CB);
  static const Color white = Colors.white;
}

class AppStrings {
  static const String appName = 'HIJAPP';
  static const String uploadHijab = 'Denemek istediğin başörtüsünü yükle';
  static const String recentlyUsed = 'Son Kullandıkların';
  static const String pickFromGallery = 'Galeriden Seç';
  static const String takePhoto = 'Fotoğraf Çek';
  static const String photoMode = 'Fotoğraf Modu';
  static const String addNew = 'Yeni Ekle';
  static const String credits = 'Kredi';
  static const String buyCredits = 'Kredi Satın Al';
  static const String enterReferralCode = 'Referans Kodu Gir';
  static const String tryOn = 'Dene';
  static const String buyNow = 'Satın Al';
  static const String boutiqueProducts = 'Butik Ürünleri';
  static const String remainingCredits = 'Kalan Kredi';
  static const String noCredits = 'Kredin kalmadı';
}

// B2C Credit Packages
class CreditPackages {
  static const List<Map<String, dynamic>> b2c = [
    {'credits': 10, 'price': 2.99, 'label': '10 Kredi', 'id': 'credits_10'},
    {'credits': 25, 'price': 5.99, 'label': '25 Kredi', 'id': 'credits_25'},
    {'credits': 50, 'price': 9.99, 'label': '50 Kredi', 'id': 'credits_50'},
  ];

  static const List<Map<String, dynamic>> b2b = [
    {'credits': 100, 'price': 25.0, 'label': '100 Kredi', 'id': 'boutique_100'},
    {'credits': 250, 'price': 100.0, 'label': '250 Kredi', 'id': 'boutique_250'},
    {'credits': 500, 'price': 200.0, 'label': '500 Kredi', 'id': 'boutique_500'},
  ];
}

class AppLimits {
  static const int freeTrialCredits = 3;
  static const int maxTemplates = 20;
}

