import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/boutique_model.dart';
import '../models/boutique_product_model.dart';
import '../models/referral_code_model.dart';
import '../models/try_on_event_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ───────── USER ─────────

  /// Kullanıcı dokümanını getir
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Kullanıcı dokümanını dinle (real-time)
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Kullanıcı dokümanını güncelle
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(data);
  }

  // ───────── KREDİ ─────────

  /// Kredi kullan (atomik — race condition önlenir)
  Future<bool> useCredit(String uid) async {
    return _firestore.runTransaction<bool>((transaction) async {
      final userRef = _firestore.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return false;

      final currentCredits = snapshot.data()?['credits'] as int? ?? 0;
      if (currentCredits <= 0) return false;

      transaction.update(userRef, {
        'credits': FieldValue.increment(-1),
        'totalCreditsUsed': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Transaction log
      final txRef = _firestore.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': uid,
        'type': 'credit_use',
        'amount': -1,
        'creditSource': 'personal',
        'description': 'Fotoğraf işleme',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  /// Kredi ekle (satın alma sonrası)
  Future<void> addCredits(String uid, int amount, String source) async {
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(uid);

      transaction.update(userRef, {
        'credits': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final txRef = _firestore.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': uid,
        'type': 'credit_purchase',
        'amount': amount,
        'creditSource': source,
        'description': '$amount kredi satın alındı',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
  // ───────── KREDİ (BUTIK) ─────────

  /// Kullanıcının belirli bir butiğe ait kalan kredisini getir
  Future<int> getBoutiqueCredits(String userId, String boutiqueId) async {
    final query = await _firestore
        .collection('user_boutique_credits')
        .where('userId', isEqualTo: userId)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return 0;
    return query.docs.first.data()['remainingCredits'] as int? ?? 0;
  }

  /// Butik kredisinden 1 düş (atomik)
  Future<bool> useBoutiqueCredit(String userId, String boutiqueId) async {
    // Transaction dışında query yap, sonra doc ref ile transaction kullan
    final query = await _firestore
        .collection('user_boutique_credits')
        .where('userId', isEqualTo: userId)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;
    final docRef = query.docs.first.reference;

    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final remaining = snapshot.data()?['remainingCredits'] as int? ?? 0;
      if (remaining <= 0) return false;

      transaction.update(docRef, {
        'remainingCredits': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Transaction log
      final txRef = _firestore.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': userId,
        'type': 'credit_use',
        'amount': -1,
        'creditSource': 'boutique:$boutiqueId',
        'boutiqueId': boutiqueId,
        'description': 'Butik denemesi',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  // ───────── REFERANS KOD ─────────

  /// Referans kodu doğrula ve uygula
  Future<ReferralCodeModel?> getReferralCode(String code) async {
    final query = await _firestore
        .collection('referral_codes')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return ReferralCodeModel.fromFirestore(query.docs.first);
  }

  /// Referans kodu kullan (atomik)
  Future<String> redeemReferralCode(String userId, String code) async {
    final query = await _firestore
        .collection('referral_codes')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return 'Kod bulunamadı';

    final codeRef = query.docs.first.reference;
    final codeModel = ReferralCodeModel.fromFirestore(query.docs.first);

    if (!codeModel.isValid) return 'Kod geçersiz veya süresi dolmuş';

    // Kullanıcı daha önce kullanmış mı?
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final redeemedCodes = List<String>.from(userDoc.data()?['redeemedCodes'] ?? []);
    if (redeemedCodes.contains(code.toUpperCase())) return 'Bu kodu daha önce kullandın';

    // user_boutique_credits kaydı transaction öncesi sorgulanır
    final ubcQuery = await _firestore
        .collection('user_boutique_credits')
        .where('userId', isEqualTo: userId)
        .where('boutiqueId', isEqualTo: codeModel.boutiqueId)
        .limit(1)
        .get();

    // Atomik işlem
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(userId);

      if (ubcQuery.docs.isEmpty) {
        final ubcRef = _firestore.collection('user_boutique_credits').doc();
        transaction.set(ubcRef, {
          'userId': userId,
          'boutiqueId': codeModel.boutiqueId,
          'code': code.toUpperCase(),
          'remainingCredits': codeModel.creditsPerRedemption,
          'totalCreditsReceived': codeModel.creditsPerRedemption,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(ubcQuery.docs.first.reference, {
          'remainingCredits': FieldValue.increment(codeModel.creditsPerRedemption),
          'totalCreditsReceived': FieldValue.increment(codeModel.creditsPerRedemption),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Kodun kullanım sayısını artır
      transaction.update(codeRef, {
        'currentRedemptions': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcıya kodu kaydet (tekrar kullanmasın)
      transaction.update(userRef, {
        'redeemedCodes': FieldValue.arrayUnion([code.toUpperCase()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Transaction log
      final txRef = _firestore.collection('transactions').doc();
      transaction.set(txRef, {
        'userId': userId,
        'type': 'referral_redeem',
        'amount': codeModel.creditsPerRedemption,
        'creditSource': 'boutique:${codeModel.boutiqueId}',
        'boutiqueId': codeModel.boutiqueId,
        'referralCode': code.toUpperCase(),
        'description': '${codeModel.creditsPerRedemption} butik kredisi eklendi',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return 'ok:${codeModel.boutiqueId}';
  }

  // ───────── KULLANICI-BUTIK BAĞLANTILARI ─────────

  /// Kullanıcının bağlı olduğu tüm butik kredilerini getir
  Future<List<Map<String, dynamic>>> getUserAllBoutiqueCredits(String userId) async {
    final query = await _firestore
        .collection('user_boutique_credits')
        .where('userId', isEqualTo: userId)
        .get();
    return query.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Kullanıcının belirli bir butiğe erişimi var mı?
  Future<bool> hasUserBoutiqueAccess(String userId, String boutiqueId) async {
    final query = await _firestore
        .collection('user_boutique_credits')
        .where('userId', isEqualTo: userId)
        .where('boutiqueId', isEqualTo: boutiqueId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // ───────── BUTIK ─────────

  /// Butik bilgisini getir
  Future<BoutiqueModel?> getBoutique(String boutiqueId) async {
    final doc = await _firestore.collection('boutiques').doc(boutiqueId).get();
    if (!doc.exists) return null;
    return BoutiqueModel.fromFirestore(doc);
  }

  /// Butiğin ürünlerini getir
  Future<List<BoutiqueProductModel>> getBoutiqueProducts(String boutiqueId) async {
    final query = await _firestore
        .collection('boutique_products')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return query.docs.map(BoutiqueProductModel.fromFirestore).toList();
  }

  /// Butigin belirli bir kategorideki urunleri (Spec v2 Bolum 3 — kategori filtresi)
  Future<List<BoutiqueProductModel>> getProductsByCategory(
    String boutiqueId,
    String category, {
    int limit = 100,
  }) async {
    final query = await _firestore
        .collection('boutique_products')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .limit(limit)
        .get();
    return query.docs.map(BoutiqueProductModel.fromFirestore).toList();
  }

  /// En cok denenen N urun (dashboard'da kullanilir)
  Future<List<BoutiqueProductModel>> getTopProducts(
    String boutiqueId, {
    int limit = 10,
    bool last30Days = false,
  }) async {
    final field = last30Days ? 'last30DaysCount' : 'tryOnCount';
    final query = await _firestore
        .collection('boutique_products')
        .where('boutiqueId', isEqualTo: boutiqueId)
        .where('isActive', isEqualTo: true)
        .orderBy(field, descending: true)
        .limit(limit)
        .get();
    return query.docs.map(BoutiqueProductModel.fromFirestore).toList();
  }

  // ───────── TRY-ON EVENT LOG ─────────

  /// Spec v2 Bolum 3.2: Bir try-on event'i logla ve ilgili counter'lari arttir.
  ///
  /// Tek transaction'da:
  ///   1. try_on_events/{eventId} yeni dokuman
  ///   2. boutique_products/{productId}.tryOnCount += 1
  ///   3. boutiques/{boutiqueId}.totalTryOns += 1
  ///   4. (varsa) referral_codes/{codeId} icin son kullanim zamani
  Future<String> logTryOnEvent({
    required String boutiqueId,
    required String productId,
    String? userId,
    TryOnUserType userType = TryOnUserType.free,
    String? referralCodeId,
    String replicateModel = 'prunaai/p-image-edit',
    bool succeeded = true,
    double costUsd = 0.0,
    String? errorMessage,
  }) async {
    final eventRef = _firestore.collection('try_on_events').doc();

    await _firestore.runTransaction((transaction) async {
      transaction.set(eventRef, {
        'boutiqueId': boutiqueId,
        'productId': productId,
        'userId': userId,
        'userType': userType.wire,
        'referralCodeId': referralCodeId,
        'timestamp': FieldValue.serverTimestamp(),
        'replicateModel': replicateModel,
        'succeeded': succeeded,
        'costUsd': costUsd,
        if (errorMessage != null) 'errorMessage': errorMessage,
      });

      // Sadece basarili event'ler counter'lari arttirir.
      if (succeeded) {
        if (productId.isNotEmpty) {
          transaction.update(
            _firestore.collection('boutique_products').doc(productId),
            {
              'tryOnCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
        }
        if (boutiqueId.isNotEmpty) {
          transaction.update(
            _firestore.collection('boutiques').doc(boutiqueId),
            {
              'totalTryOns': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
        }
      }
    });

    return eventRef.id;
  }

  /// Belirli bir tarih araliginda butigin event'lerini getir.
  ///
  /// `boutiqueId + timestamp DESC` indexi gerekir.
  Future<List<TryOnEventModel>> getBoutiqueAnalytics(
    String boutiqueId, {
    DateTime? from,
    DateTime? to,
    int limit = 500,
  }) async {
    Query<Map<String, dynamic>> q = _firestore
        .collection('try_on_events')
        .where('boutiqueId', isEqualTo: boutiqueId);
    if (from != null) {
      q = q.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      q = q.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }
    final snap = await q.orderBy('timestamp', descending: true).limit(limit).get();
    return snap.docs.map(TryOnEventModel.fromFirestore).toList();
  }
}

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Kullanıcı modelini dinleyen provider
final currentUserModelProvider = StreamProvider.family<UserModel?, String>(
  (ref, uid) {
    return ref.watch(firestoreServiceProvider).watchUser(uid);
  },
);
