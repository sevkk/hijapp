import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/constants.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _successBoutiqueName;
  int? _successCredits;
  String? _successBoutiqueId;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Lütfen bir referans kodu girin');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successBoutiqueName = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Look up the code
      final codeQuery = await firestore
          .collection('referral_codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (codeQuery.docs.isEmpty) {
        setState(() {
          _error = 'Geçersiz kod. Lütfen kontrol edin.';
          _isLoading = false;
        });
        return;
      }

      final codeDoc = codeQuery.docs.first;
      final codeData = codeDoc.data();

      // Check if code is active
      if (codeData['isActive'] != true) {
        setState(() {
          _error = 'Bu kodun süresi dolmuş';
          _isLoading = false;
        });
        return;
      }

      // Check if user already redeemed this code
      final userData = await firestore.collection('users').doc(uid).get();
      final redeemedCodes = List<String>.from(userData.data()?['redeemedCodes'] ?? []);
      if (redeemedCodes.contains(code)) {
        setState(() {
          _error = 'Bu kodu zaten kullandınız';
          _isLoading = false;
        });
        return;
      }

      // Check remaining uses
      final remainingUses = codeData['remainingUses'] as int? ?? 0;
      if (remainingUses <= 0) {
        setState(() {
          _error = 'Bu kodun kullanım hakkı dolmuş';
          _isLoading = false;
        });
        return;
      }

      final creditsToAdd = codeData['credits'] as int? ?? 0;
      final boutiqueId = codeData['boutiqueId'] as String;

      // Get boutique name
      final boutiqueDoc = await firestore.collection('boutiques').doc(boutiqueId).get();
      final boutiqueName = boutiqueDoc.data()?['name'] ?? 'Butik';

      // Transaction: add credits to user, mark code usage, decrement remaining
      await firestore.runTransaction((transaction) async {
        // Add credits to user
        transaction.update(firestore.collection('users').doc(uid), {
          'credits': FieldValue.increment(creditsToAdd),
          'redeemedCodes': FieldValue.arrayUnion([code]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Decrement code remaining uses
        transaction.update(codeDoc.reference, {
          'remainingUses': FieldValue.increment(-1),
          'usedBy': FieldValue.arrayUnion([uid]),
        });

        // Log transaction
        transaction.set(firestore.collection('transactions').doc(), {
          'userId': uid,
          'type': 'referral_redeem',
          'credits': creditsToAdd,
          'referralCode': code,
          'boutiqueId': boutiqueId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      setState(() {
        _successBoutiqueName = boutiqueName;
        _successCredits = creditsToAdd;
        _successBoutiqueId = boutiqueId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Bir hata oluştu. Lütfen tekrar deneyin.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
        ),
        title: Text(
          'Referans Kodu',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront_outlined, size: 40, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              'Butik Referans Kodu',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Butiğinizden aldığınız kodu girerek\nücretsiz deneme kredisi kazanın',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Success state
            if (_successBoutiqueName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle, size: 32, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kod Başarıyla Kullanıldı!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_successBoutiqueName size $_successCredits kredi hediye etti',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/boutique-catalog',
                            arguments: _successBoutiqueId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Ürünleri Keşfet',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Code input
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: 'XXXX-XXXX',
                  hintStyle: GoogleFonts.robotoMono(
                    fontSize: 24,
                    color: AppColors.divider,
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),

              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _redeemCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Kodu Onayla',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // How it works
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Nasıl Çalışır?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1', 'Butikten Kod Al', 'Anlaşmalı butikten referans kodunuzu alın'),
                  const SizedBox(height: 12),
                  _buildStep('2', 'Kodu Gir', 'Yukarıdaki alana kodunuzu girin ve onaylayın'),
                  const SizedBox(height: 12),
                  _buildStep('3', 'Ücretsiz Dene', 'Hediye kredilerinizle ürünleri deneyin'),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
