import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _boutiqueData;
  int _activeCodesCount = 0;
  int _productCount = 0;
  List<Map<String, dynamic>> _recentTx = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (uid == null || email == null) return;

    final fs = FirebaseFirestore.instance;

    // Butik kaydını email'e göre bul
    final bQuery = await fs.collection('boutiques').where('email', isEqualTo: email).limit(1).get();
    if (bQuery.docs.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final boutique = bQuery.docs.first.data();
    final boutiqueId = bQuery.docs.first.id;

    final codesQuery = await fs.collection('referral_codes')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('isActive', isEqualTo: true)
        .get();

    final productsQuery = await fs.collection('boutique_products')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .get();

    // Son 5 işlem (kendi kullanıcılarına ait)
    final txQuery = await fs.collection('transactions')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    setState(() {
      _boutiqueData = boutique;
      _activeCodesCount = codesQuery.docs.length;
      _productCount = productsQuery.docs.length;
      _recentTx = txQuery.docs.map((d) => d.data()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));

    if (_boutiqueData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 64, color: AdminTheme.textSecondary),
            const SizedBox(height: 16),
            Text('Butik kaydı bulunamadı.', style: GoogleFonts.inter(fontSize: 18, color: AdminTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Bu hesap için Firebase\'de boutiques kaydı oluşturun.', style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
          ],
        ),
      );
    }

    final creditBalance = _boutiqueData!['creditBalance'] as int? ?? 0;
    final boutiqueName = _boutiqueData!['name'] as String? ?? 'Butik';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoş geldin, $boutiqueName 👋', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Butik yönetim panelinize genel bakış', style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
          const SizedBox(height: 32),

          // Stat cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(icon: Icons.toll, label: 'Kalan Kredi', value: '$creditBalance', color: AdminTheme.primary),
              _StatCard(icon: Icons.qr_code, label: 'Aktif Kodlar', value: '$_activeCodesCount', color: AdminTheme.secondary),
              _StatCard(icon: Icons.inventory_2, label: 'Ürün Sayısı', value: '$_productCount', color: const Color(0xFF8B5CF6)),
            ],
          ),

          const SizedBox(height: 40),
          Text('Son İşlemler', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
          const SizedBox(height: 16),

          if (_recentTx.isEmpty)
            _EmptyState(message: 'Henüz işlem yok.')
          else
            Card(
              child: Column(
                children: _recentTx.map((tx) => _TxRow(tx: tx)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final amount = tx['amount'] as int? ?? 0;
    final type = tx['type'] as String? ?? '';
    final desc = tx['description'] as String? ?? '';
    final ts = (tx['createdAt'] as Timestamp?)?.toDate();
    final dateStr = ts != null ? DateFormat('d MMM, HH:mm').format(ts) : '';
    final isPositive = amount > 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (isPositive ? AdminTheme.success : AdminTheme.error).withOpacity(0.1),
        child: Icon(isPositive ? Icons.add : Icons.remove,
            color: isPositive ? AdminTheme.success : AdminTheme.error, size: 18),
      ),
      title: Text(desc, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(type, style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${isPositive ? '+' : ''}$amount kredi',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700,
                  color: isPositive ? AdminTheme.success : AdminTheme.error)),
          Text(dateStr, style: GoogleFonts.inter(fontSize: 11, color: AdminTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(message, style: GoogleFonts.inter(color: AdminTheme.textSecondary)),
        ),
      );
}
