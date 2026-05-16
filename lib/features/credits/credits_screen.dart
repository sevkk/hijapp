import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/utils/constants.dart';

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  int _selectedPackageIndex = 1;
  int _currentCredits = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  // In-App Purchase
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  List<ProductDetails> _products = [];
  bool _iapAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initIAP();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      if (mounted) setState(() => _iapAvailable = false);
      return;
    }

    // Ürün ID'lerini yükle
    final productIds = CreditPackages.b2c.map((p) => p['id'] as String).toSet();
    final response = await _iap.queryProductDetails(productIds);

    // Satın alma akışını dinle
    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    if (mounted) {
      setState(() {
        _iapAvailable = true;
        _products = response.productDetails;
      });
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _deliverPurchase(purchase);
        await _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          setState(() => _isPurchasing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Satın alma hatası: ${purchase.error?.message ?? 'Bilinmeyen hata'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        if (mounted) setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _deliverPurchase(PurchaseDetails purchase) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Satın alınan ürünün kredi miktarını bul
    final pkg = CreditPackages.b2c.firstWhere(
      (p) => p['id'] == purchase.productID,
      orElse: () => {},
    );
    if (pkg.isEmpty) return;

    final credits = pkg['credits'] as int;

    // Firestore'a atomik olarak kredi ekle
    final firestore = FirebaseFirestore.instance;
    await firestore.runTransaction((tx) async {
      final userRef = firestore.collection('users').doc(uid);
      tx.update(userRef, {
        'credits': FieldValue.increment(credits),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final txRef = firestore.collection('transactions').doc();
      tx.set(txRef, {
        'userId': uid,
        'type': 'credit_purchase',
        'amount': credits,
        'creditSource': 'personal',
        'description': '${pkg['label']} satın alındı',
        'productId': purchase.productID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    if (mounted) {
      setState(() {
        _currentCredits += credits;
        _isPurchasing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$credits kredi hesabına eklendi! 🎉'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadData(); // İşlem geçmişini yenile
    }
  }

  Future<void> _purchaseCredits() async {
    final pkg = CreditPackages.b2c[_selectedPackageIndex];
    final productId = pkg['id'] as String;

    // IAP yoksa (simulator / test ortamı) → mock delivery
    if (!_iapAvailable || _products.isEmpty) {
      _showIAPUnavailableDialog(pkg);
      return;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => _products.first,
    );

    setState(() => _isPurchasing = true);

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  void _showIAPUnavailableDialog(Map<String, dynamic> pkg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ödeme Sistemi', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Ödeme sistemi bu cihazda kullanılamıyor (test/emülatör ortamı). '
          'Gerçek bir cihazda App Store / Play Store üzerinden satın alma yapabilirsin.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tamam', style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(uid).get();

    final txQuery = await firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    if (mounted) {
      setState(() {
        _currentCredits = userDoc.data()?['credits'] ?? 0;
        _recentTransactions = txQuery.docs.map((d) => d.data()).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 28),
                        Text(
                          'Kredi Paketi Seç',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(CreditPackages.b2c.length, (i) {
                          final pkg = CreditPackages.b2c[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPackageCard(
                              index: i,
                              credits: pkg['credits'] as int,
                              price: pkg['price'] as double,
                              label: pkg['label'] as String,
                              isPopular: i == 1,
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        _buildPurchaseButton(),
                        const SizedBox(height: 20),
                        // Referral link
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/referral'),
                            child: RichText(
                              text: TextSpan(
                                text: 'Referans kodun var mı? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Kodu Gir',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_recentTransactions.isNotEmpty) ...[
                          Text(
                            'Son İşlemler',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._recentTransactions.map((tx) => _buildTransactionRow(tx)),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const Icon(Icons.toll, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '$_currentCredits',
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Mevcut Kredin',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required int index,
    required int credits,
    required double price,
    required String label,
    bool isPopular = false,
  }) {
    final isSelected = _selectedPackageIndex == index;
    final perCredit = (price / credits).toStringAsFixed(2);

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surfaceLight : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12)]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$credits',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$$perCredit / kredi',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Popüler',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final pkg = CreditPackages.b2c[_selectedPackageIndex];
    final price = pkg['price'] as double;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isPurchasing ? null : _purchaseCredits,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isPurchasing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Satın Al — \$${price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> tx) {
    final type = tx['type'] as String? ?? 'unknown';
    final amount = tx['amount'] as int? ?? 0;
    final isPositive = type == 'referral_redeem' || type == 'credit_purchase' || amount > 0;

    String label;
    IconData icon;
    switch (type) {
      case 'referral_redeem':
        label = 'Referans Kodu';
        icon = Icons.redeem;
        break;
      case 'credit_purchase':
        label = 'Kredi Satın Alma';
        icon = Icons.shopping_cart;
        break;
      case 'credit_use':
        label = 'Deneme Kullanımı';
        icon = Icons.auto_awesome;
        break;
      default:
        label = 'İşlem';
        icon = Icons.receipt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.shade50 : Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: isPositive ? Colors.green : Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}$amount',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isPositive ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
