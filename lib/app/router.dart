import 'package:flutter/material.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/boutique/referral_screen.dart';
import '../features/boutique/boutique_catalog_screen.dart';
import '../features/credits/credits_screen.dart';
import '../features/home/home_screen.dart';
import '../features/photo_mode/photo_mode_screen.dart';
import '../features/photo_mode/result_screen.dart';
import '../features/templates/templates_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String photoMode = '/photo-mode';
  static const String result = '/result';
  static const String templates = '/templates';
  static const String credits = '/credits';
  static const String referral = '/referral';
  static const String boutiqueCatalog = '/boutique-catalog';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case photoMode:
        return MaterialPageRoute(
          builder: (_) => const PhotoModeScreen(),
          settings: settings,
        );
      case result:
        return MaterialPageRoute(
          builder: (_) => const ResultScreen(),
          settings: settings,
        );
      case templates:
        return MaterialPageRoute(
          builder: (_) => const TemplatesScreen(),
          settings: settings,
        );
      case credits:
        return MaterialPageRoute(builder: (_) => const CreditsScreen());
      case referral:
        return MaterialPageRoute(builder: (_) => const ReferralScreen());
      case boutiqueCatalog:
        final boutiqueId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BoutiqueCatalogScreen(boutiqueId: boutiqueId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    }
  }
}
