import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

/// Spec v2 Bolum 6.7: Ayarlar
/// - Butik bilgileri (isim, logo, website, Instagram)
/// - Bildirim tercihleri (haftalik rapor)
/// - Cikis
///
/// Kullanicilar bolumu ve API anahtarlari ileride.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  bool _weeklyReport = true;
  bool _loading = true;
  bool _saving = false;
  String? _status;
  String? _boutiqueId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _websiteCtrl.dispose();
    _instagramCtrl.dispose();
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      setState(() => _loading = false);
      return;
    }
    final snap = await FirebaseFirestore.instance
        .collection('boutiques')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final doc = snap.docs.first;
    final d = doc.data();
    _boutiqueId = doc.id;
    _nameCtrl.text = d['name'] as String? ?? '';
    _websiteCtrl.text = d['websiteUrl'] as String? ?? '';
    _instagramCtrl.text = d['instagramHandle'] as String? ?? '';
    _logoUrlCtrl.text = d['logoUrl'] as String? ?? '';
    _weeklyReport = d['weeklyReportEnabled'] as bool? ?? true;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_boutiqueId == null) return;
    setState(() {
      _saving = true;
      _status = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection('boutiques')
          .doc(_boutiqueId)
          .update({
        'name': _nameCtrl.text.trim(),
        'websiteUrl': _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        'instagramHandle': _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
        'logoUrl': _logoUrlCtrl.text.trim().isEmpty ? null : _logoUrlCtrl.text.trim(),
        'weeklyReportEnabled': _weeklyReport,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _status = 'Kaydedildi');
    } catch (e) {
      setState(() => _status = 'Kaydedilemedi: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ayarlar',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: AdminTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Butik bilgileri, bildirim tercihleri ve hesap.',
              style: GoogleFonts.inter(color: AdminTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Butik Bilgileri',
              children: [
                _field('Butik adı', _nameCtrl),
                _field('Website (https://...)', _websiteCtrl),
                _field('Instagram kullanıcı adı (@yoksuz)', _instagramCtrl),
                _field('Logo URL (Storage public link)', _logoUrlCtrl),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Bildirimler',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _weeklyReport,
                  onChanged: (v) => setState(() => _weeklyReport = v),
                  title: Text(
                    'Haftalık özet email',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Pazartesi 09:00 TR — son 7 günün denemeleri ve kod kullanımı',
                    style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary),
                  ),
                  activeThumbColor: AdminTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AdminTheme.cream, strokeWidth: 2))
                        : const Text('Kaydet'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Çıkış Yap'),
                ),
              ],
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!, style: GoogleFonts.inter(color: AdminTheme.success)),
            ],
            const SizedBox(height: 32),
            _SectionCard(
              title: 'Yakında',
              children: [
                _muted('Butik içi ek kullanıcılar (delege admin)'),
                _muted('API anahtarı (white-label entegrasyon)'),
                _muted('Custom domain (vitrin URL özelleştirme)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: c,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Widget _muted(String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          const Icon(Icons.circle, size: 4, color: AdminTheme.inkMuted),
          const SizedBox(width: 8),
          Text(s, style: GoogleFonts.inter(color: AdminTheme.textSecondary)),
        ]),
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AdminTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
