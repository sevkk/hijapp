import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';

class ReferralAnalyticsScreen extends StatefulWidget {
  const ReferralAnalyticsScreen({super.key});
  @override
  State<ReferralAnalyticsScreen> createState() => _ReferralAnalyticsScreenState();
}

class _ReferralAnalyticsScreenState extends State<ReferralAnalyticsScreen> {
  final _fs = FirebaseFirestore.instance;
  String? _boutiqueId;
  bool _loading = true;

  // Summary stats
  int _totalRedemptions = 0;
  int _totalCreditsDistributed = 0;
  int _uniqueUsers = 0;

  // Per-code breakdown
  List<Map<String, dynamic>> _codes = [];

  // Recent redemptions
  List<Map<String, dynamic>> _recentRedemptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    // Get boutique
    final bq = await _fs.collection('boutiques').where('email', isEqualTo: email).limit(1).get();
    if (bq.docs.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    _boutiqueId = bq.docs.first.id;

    // Get all referral codes for this boutique
    final codesQuery = await _fs
        .collection('referral_codes')
        .where('boutiqueId', isEqualTo: _boutiqueId)
        .orderBy('createdAt', descending: true)
        .get();

    final codes = codesQuery.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'code': data['code'] ?? '',
        'creditsPerRedemption': data['creditsPerRedemption'] ?? 0,
        'currentRedemptions': data['currentRedemptions'] ?? 0,
        'maxRedemptions': data['maxRedemptions'] ?? 0,
        'isActive': data['isActive'] ?? false,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      };
    }).toList();

    // Get recent transactions (referral_redeem type)
    final txQuery = await _fs
        .collection('transactions')
        .where('boutiqueId', isEqualTo: _boutiqueId)
        .where('type', isEqualTo: 'referral_redeem')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final redemptions = <Map<String, dynamic>>[];
    final uniqueUserIds = <String>{};
    int totalCredits = 0;

    for (final doc in txQuery.docs) {
      final data = doc.data();
      final userId = data['userId'] as String? ?? '';
      uniqueUserIds.add(userId);
      totalCredits += (data['amount'] as int? ?? 0);

      // Fetch user email for display
      String userEmail = userId;
      try {
        final userDoc = await _fs.collection('users').doc(userId).get();
        if (userDoc.exists) {
          userEmail = userDoc.data()?['email'] ?? userId;
        }
      } catch (_) {}

      redemptions.add({
        'userEmail': userEmail,
        'referralCode': data['referralCode'] ?? '',
        'amount': data['amount'] ?? 0,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      });
    }

    setState(() {
      _codes = codes;
      _recentRedemptions = redemptions;
      _totalRedemptions = txQuery.docs.length;
      _totalCreditsDistributed = totalCredits;
      _uniqueUsers = uniqueUserIds.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Referans Analitikleri',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
            Text('Referans kodlarının kullanım istatistikleri',
                style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
            const SizedBox(height: 24),

            // Summary cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  icon: Icons.people_alt_outlined,
                  label: 'Toplam Kullanım',
                  value: '$_totalRedemptions',
                  color: AdminTheme.primary,
                ),
                _StatCard(
                  icon: Icons.toll_outlined,
                  label: 'Dağıtılan Kredi',
                  value: '$_totalCreditsDistributed',
                  color: AdminTheme.secondary,
                ),
                _StatCard(
                  icon: Icons.person_outline,
                  label: 'Benzersiz Kullanıcı',
                  value: '$_uniqueUsers',
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Per-code breakdown
            Text('Kod Bazlı İstatistikler',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
            const SizedBox(height: 16),

            if (_codes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Henüz referans kodu oluşturulmamış',
                      style: GoogleFonts.inter(color: AdminTheme.textSecondary)),
                ),
              )
            else
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AdminTheme.border.withOpacity(0.3)),
                    columns: [
                      DataColumn(label: Text('Kod', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Durum', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Kredi/Kullanım', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Kullanım', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Toplam Dağıtılan', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      DataColumn(label: Text('Oluşturulma', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                    ],
                    rows: _codes.map((code) {
                      final redemptions = code['currentRedemptions'] as int;
                      final creditsPerUse = code['creditsPerRedemption'] as int;
                      final maxUses = code['maxRedemptions'] as int;
                      final isActive = code['isActive'] as bool;
                      final createdAt = code['createdAt'] as DateTime?;

                      return DataRow(cells: [
                        DataCell(Text(code['code'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'AKTİF' : 'PASİF',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        )),
                        DataCell(Text('$creditsPerUse kredi', style: GoogleFonts.inter(fontSize: 13))),
                        DataCell(Text(
                          maxUses > 0 ? '$redemptions / $maxUses' : '$redemptions / ∞',
                          style: GoogleFonts.inter(fontSize: 13),
                        )),
                        DataCell(Text(
                          '${redemptions * creditsPerUse} kredi',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminTheme.primary),
                        )),
                        DataCell(Text(
                          createdAt != null ? DateFormat('dd.MM.yyyy').format(createdAt) : '-',
                          style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Recent redemptions
            Text('Son Kullanımlar',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
            const SizedBox(height: 16),

            if (_recentRedemptions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Henüz referans kodu kullanımı yok',
                      style: GoogleFonts.inter(color: AdminTheme.textSecondary)),
                ),
              )
            else
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentRedemptions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final tx = _recentRedemptions[i];
                    final userEmail = tx['userEmail'] as String;
                    final code = tx['referralCode'] as String;
                    final amount = tx['amount'] as int;
                    final date = tx['createdAt'] as DateTime?;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AdminTheme.primary.withOpacity(0.1),
                        child: const Icon(Icons.person_outline, size: 20, color: AdminTheme.primary),
                      ),
                      title: Text(userEmail, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        'Kod: $code',
                        style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+$amount kredi',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                            ),
                          ),
                          if (date != null)
                            Text(
                              DateFormat('dd.MM.yyyy HH:mm').format(date),
                              style: GoogleFonts.inter(fontSize: 11, color: AdminTheme.textSecondary),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.textSecondary)),
        ],
      ),
    );
  }
}
