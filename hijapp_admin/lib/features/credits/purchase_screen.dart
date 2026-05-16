import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  int _selectedIndex = 1;

  static const List<Map<String, dynamic>> _packages = [
    {'credits': 100, 'price': 25.0, 'label': 'Başlangıç', 'desc': 'Deneme paketi, tek seferlik'},
    {'credits': 250, 'price': 100.0, 'label': 'Standart', 'desc': 'En popüler seçim'},
    {'credits': 500, 'price': 200.0, 'label': 'Pro', 'desc': 'Aktif butikler için'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kredi Satın Al', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary)),
          Text('Referans kodlarınız için kredi havuzunu doldurun', style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.textSecondary)),
          const SizedBox(height: 32),

          // Bilgi kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AdminTheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  'Satın aldığınız krediler havuzunuza eklenir. Referans kodları oluştururken bu havuzdan kredi atarsınız.',
                  style: GoogleFonts.inter(fontSize: 14, color: AdminTheme.primary),
                )),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Paketler
          Row(
            children: List.generate(_packages.length, (i) {
              final pkg = _packages[i];
              final isSelected = _selectedIndex == i;
              final isPopular = i == 1;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 220,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isSelected ? AdminTheme.primary.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AdminTheme.primary : AdminTheme.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${pkg['credits']} Kredi', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(pkg['label'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AdminTheme.textPrimary)),
                            Text(pkg['desc'] as String, style: GoogleFonts.inter(fontSize: 13, color: AdminTheme.textSecondary)),
                            const SizedBox(height: 20),
                            Text('\$${(pkg['price'] as double).toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: isSelected ? AdminTheme.primary : AdminTheme.textPrimary)),
                            Text('\$${((pkg['price'] as double) / (pkg['credits'] as int) * 100).toStringAsFixed(1)}¢ / kredi', style: GoogleFonts.inter(fontSize: 12, color: AdminTheme.textSecondary)),
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
                              gradient: const LinearGradient(colors: [AdminTheme.primary, AdminTheme.secondary]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Popüler', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: 220,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('Ödeme Sistemi', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    content: Text(
                      'Ödeme entegrasyonu (Stripe / iyzico) yakında aktif olacak. '
                      'Şu an kredi eklemek için uygulama geliştiricisiyle iletişime geçin: sevketburak@gmail.com',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    actions: [
                      ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam')),
                    ],
                  ),
                );
              },
              child: Text(
                'Satın Al — \$${(_packages[_selectedIndex]['price'] as double).toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
