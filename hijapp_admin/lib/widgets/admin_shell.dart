import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: Row(
        children: [
          if (isWide) const _Sidebar(),
          Expanded(child: child),
        ],
      ),
      drawer: isWide ? null : const Drawer(child: _Sidebar()),
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: AdminTheme.sidebar,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                'HIJAPP Admin',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 240,
      color: AdminTheme.sidebar,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AdminTheme.primary, AdminTheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'HIJAPP',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Nav items
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard', current: location),
          _NavItem(icon: Icons.inventory_2_outlined, label: 'Ürünler', route: '/products', current: location),
          _NavItem(icon: Icons.qr_code_outlined, label: 'Referans Kodlar', route: '/codes', current: location),
          _NavItem(icon: Icons.analytics_outlined, label: 'Analitikler', route: '/analytics', current: location),
          _NavItem(icon: Icons.toll_outlined, label: 'Kredi Satın Al', route: '/credits', current: location),

          const Spacer(),
          const Divider(color: Colors.white12, height: 1),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54, size: 20),
            title: Text(
              'Çıkış Yap',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AdminTheme.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? AdminTheme.primary : Colors.white54,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : Colors.white70,
          ),
        ),
        onTap: () => context.go(route),
        dense: true,
      ),
    );
  }
}
