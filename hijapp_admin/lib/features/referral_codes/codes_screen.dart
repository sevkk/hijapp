import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

class CodesScreen extends StatefulWidget {
  const CodesScreen({super.key});
  @override
  State<CodesScreen> createState() => _CodesScreenState();
}

class _CodesScreenState extends State<CodesScreen> {
  final _fs = FirebaseFirestore.instance;
  String? _boutiqueId;
  List<QueryDocumentSnapshot> _codes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBoutiqueAndCodes();
  }

  Future<void> _loadBoutiqueAndCodes() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final bQuery = await _fs.collection('boutiques').where('email', isEqualTo: email).limit(1).get();
    if (bQuery.docs.isEmpty) { setState(() => _loading = false); return; }

    _boutiqueId = bQuery.docs.first.id;
    final codesQuery = await _fs.collection('referral_codes')
        .where('boutiqueId', isEqualTo: _boutiqueId)
        .orderBy('createdAt', descending: true)
        .get();

    setState(() { _codes = codesQuery.docs; _loading = false; });
  }

  void _showCreateDialog() {
    final codeCtrl = TextEditingController();
    final creditsCtrl = TextEditingController(text: '5');
    final maxCtrl = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Yeni Referans Kodu', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kod (örn: BUTIK-AYSE-2026)')),
            const SizedBox(height: 12),
            TextField(controller: creditsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kredi miktarı')),
            const SizedBox(height: 12),
            TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max kullanım (0 = sınırsız)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.toUpperCase().trim();
              if (code.isEmpty || _boutiqueId == null) return;
              await _fs.collection('referral_codes').add({
                'code': code,
                'boutiqueId': _boutiqueId,
                'creditsPerRedemption': int.tryParse(creditsCtrl.text) ?? 5,
                'maxRedemptions': int.tryParse(maxCtrl.text) ?? 0,
                'currentRedemptions': 0,
                'isActive': true,
                'expiresAt': null,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              if (mounted) { Navigator.pop(ctx); _loadBoutiqueAndCodes(); }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(String docId, bool current) async {
    await _fs.collection('referral_codes').doc(docId).update({'isActive': !current, 'updatedAt': FieldValue.serverTimestamp()});
    _loadBoutiqueAndCodes();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Referans Kodlar', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
                  Text('Müşteri referans kodlarını yönetin', style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
                ],
              )),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Kod'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AdminTheme.primary))
          else if (_codes.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(children: [
                const Icon(Icons.qr_code_outlined, size: 64, color: AdminTheme.textSecondary),
                const SizedBox(height: 16),
                Text('Henüz kod oluşturmadın', style: GoogleFonts.inter(color: AdminTheme.textSecondary, fontSize: 16)),
              ]),
            ))
          else
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: _codes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final doc = _codes[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final isActive = data['isActive'] as bool? ?? false;
                    final code = data['code'] as String? ?? '';
                    final credits = data['creditsPerRedemption'] as int? ?? 0;
                    final used = data['currentRedemptions'] as int? ?? 0;
                    final max = data['maxRedemptions'] as int? ?? 0;

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AdminTheme.success.withOpacity(0.1) : AdminTheme.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(isActive ? 'AKTİF' : 'PASİF',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                                color: isActive ? AdminTheme.success : AdminTheme.textSecondary)),
                      ),
                      title: Text(code, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: Text('$credits kredi • $used/${max == 0 ? '∞' : max} kullanım',
                          style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.textSecondary)),
                      trailing: Switch(
                        value: isActive,
                        activeColor: AdminTheme.primary,
                        onChanged: (_) => _toggleActive(doc.id, isActive),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
