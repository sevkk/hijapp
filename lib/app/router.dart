import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/photo_mode/photo_mode_screen.dart';
import '../features/photo_mode/result_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/templates/templates_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String photoMode = '/photo-mode';
  static const String result = '/result';
  static const String templates = '/templates';
  static const String premium = '/premium';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case premium:
        return MaterialPageRoute(
          builder: (_) => const PremiumScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
