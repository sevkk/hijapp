import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';

/// Spec v2 Bolum 6.6 (revize): 5 kademeli butik kredi paketleri.
/// iyzico checkout: `createIyzicoCheckout` callable function cagrilir,
/// donen `paymentPageUrl` yeni tab'da acilir. Test mode'da stub URL doner.
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  int _selectedIndex = 3; // Premium - en populer
  bool _loading = false;
  String? _status;

  static const List<Map<String, dynamic>> _packages = [
    {'id': 'boutique_starter', 'credits': 50, 'price': 599.0, 'label': 'Starter', 'desc': 'Kucuk butik, ilk deneme', 'pricePerCredit': 11.98},
    {'id': 'boutique_growth', 'credits': 100, 'price': 1000.0, 'label': 'Growth', 'desc': 'Ana giris paketi', 'pricePerCredit': 10.00},
    {'id': 'boutique_pro', 'credits': 500, 'price': 4490.0, 'label': 'Pro', 'desc': 'Buyuyen butik', 'pricePerCredit': 8.98, 'discount': 10},
    {'id': 'boutique_premium', 'credits': 2000, 'price': 16990.0, 'label': 'Premium', 'desc': 'Markalasmis butik', 'pricePerCredit': 8.49, 'discount': 15, 'popular': true},
    {'id': 'boutique_enterprise', 'credits': 10000, 'price': 79990.0, 'label': 'Enterprise', 'desc': 'Modanisa olceginde', 'pricePerCredit': 8.00, 'discount': 20, 'contactSales': true},
  ];

  Future<void> _startCheckout() async {
    final pkg = _packages[_selectedIndex];
    if (pkg['contactSales'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Enterprise Paket', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w500)),
          content: Text(
            'Enterprise paket icin lutfen bize ulasin: iletisim@hijapp.com\n'
            'Ozel sartlar ve faturalama icin gorusulur.',
            style: GoogleFonts.inter(),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam')),
          ],
        ),
      );
      return;
    }

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      setState(() => _status = 'Once giris yapin');
      return;
    }

    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('createIyzicoCheckout');
      final result = await callable.call<Map<String, dynamic>>({
        'packageId': pkg['id'],
        'credits': pkg['credits'],
        'priceTry': pkg['price'],
        'buyer': {
          'name': 'Butik',
          'surname': 'Yetkilisi',
          'email': email,
        },
      });
      final data = result.data;
      final url = data['paymentPageUrl'] as String?;
      final testMode = data['testMode'] == true;
      if (url == null) {
        setState(() => _status = 'iyzico cevabi eksik');
        return;
      }
      if (testMode && mounted) {
        setState(() => _status = 'Test mode: gercek odeme yapilmadi (' + url + ')');
      }
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    } on FirebaseFunctionsException catch (e) {
      setState(() => _status = 'Hata: ${e.message ?? e.code}');
    } catch (e) {
      setState(() => _status = 'Hata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkg = _packages[_selectedIndex];
    final priceWithVat = (pkg['price'] as double) * 1.20;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kredi Satın Al',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AdminTheme.textPrimary,
            ),
          ),
          Text(
            'Vitrininizdeki denemeler ve referans kodlari icin kredi havuzunu doldurun.',
            style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Bilgi banneri
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminTheme.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.gold.withValues(alpha: 0.4), width: 0.6),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AdminTheme.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aldiginiz krediler havuzunuza eklenir. Musteriye dagittiginiz her kod icin maks. kullanım × kredi rezerve edilir.',
                    style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.inkBlack),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Paket kartlari
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(_packages.length, (i) {
              final p = _packages[i];
              final isSelected = _selectedIndex == i;
              final isPopular = p['popular'] == true;
              final discount = p['discount'] as int?;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 220,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isSelected ? AdminTheme.creamSoft : AdminTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AdminTheme.primary : AdminTheme.border,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['label'] as String,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(p['desc'] as String, style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary)),
                          const SizedBox(height: 16),
                          Text(
                            '${p['credits']} kredi',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AdminTheme.inkBlack),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₺${(p['price'] as double).toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '₺${(p['pricePerCredit'] as double).toStringAsFixed(2)}/kredi',
                            style: GoogleFonts.inter(fontSize: 11, color: AdminTheme.textSecondary),
                          ),
                          if (discount != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AdminTheme.sage.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '%$discount indirim',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AdminTheme.sage),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isPopular)
                      Positioned(
                        top: -10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AdminTheme.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'En populer',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AdminTheme.inkBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Ozet + KDV (B2B faturada sart)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AdminTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _summaryRow('${pkg['label']} paketi', '${pkg['credits']} kredi'),
                _summaryRow('Net tutar', '₺${(pkg['price'] as double).toStringAsFixed(2)}'),
                _summaryRow('KDV (%20)', '₺${((pkg['price'] as double) * 0.20).toStringAsFixed(2)}', muted: true),
                const Divider(),
                _summaryRow(
                  'Genel toplam',
                  '₺${priceWithVat.toStringAsFixed(2)}',
                  bold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: 280,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _startCheckout,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AdminTheme.cream, strokeWidth: 2))
                  : Text(
                      pkg['contactSales'] == true
                          ? 'Bize Ulasin'
                          : 'iyzico ile Odeme — ₺${priceWithVat.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!, style: GoogleFonts.inter(color: AdminTheme.inkMuted)),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, bool muted = false}) {
    final style = GoogleFonts.inter(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: muted ? AdminTheme.inkMuted : AdminTheme.inkBlack,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
