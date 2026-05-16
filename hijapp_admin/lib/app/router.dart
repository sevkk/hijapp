import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_screen.dart';
import '../features/referral_codes/codes_screen.dart';
import '../features/credits/purchase_screen.dart';
import '../features/referral_codes/referral_analytics_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/admin_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginPage = state.matchedLocation == '/login';
    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/codes',
          builder: (context, state) => const CodesScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const ReferralAnalyticsScreen(),
        ),
        GoRoute(
          path: '/credits',
          builder: (context, state) => const PurchaseScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
