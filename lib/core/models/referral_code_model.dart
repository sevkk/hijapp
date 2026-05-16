import 'package:cloud_firestore/cloud_firestore.dart';

/// Spec v2 Bolum 3.5: ReferralCodeModel'e totalCreditsGranted, redeemedByUsers,
/// campaignTag eklendi. campaignTag butigin "hangi kanaldan gelen kod daha cok
/// donuyor" gormesi icin.
class ReferralCodeModel {
  final String id;
  final String code;
  final String boutiqueId;
  final int creditsPerRedemption;
  final int maxRedemptions; // 0 = sinirsiz
  final int currentRedemptions;
  final int totalCreditsGranted;
  final List<String> redeemedByUsers;
  final String? campaignTag;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralCodeModel({
    required this.id,
    required this.code,
    required this.boutiqueId,
    required this.creditsPerRedemption,
    this.maxRedemptions = 0,
    this.currentRedemptions = 0,
    this.totalCreditsGranted = 0,
    this.redeemedByUsers = const [],
    this.campaignTag,
    this.isActive = true,
    this.expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxRedemptions > 0 && currentRedemptions >= maxRedemptions) return false;
    return true;
  }

  factory ReferralCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralCodeModel(
      id: doc.id,
      code: data['code'] as String? ?? '',
      boutiqueId: data['boutiqueId'] as String? ?? '',
      creditsPerRedemption: (data['creditsPerRedemption'] as num?)?.toInt() ?? 0,
      maxRedemptions: (data['maxRedemptions'] as num?)?.toInt() ?? 0,
      currentRedemptions: (data['currentRedemptions'] as num?)?.toInt() ?? 0,
      totalCreditsGranted: (data['totalCreditsGranted'] as num?)?.toInt() ?? 0,
      redeemedByUsers: List<String>.from(data['redeemedByUsers'] as List? ?? const []),
      campaignTag: data['campaignTag'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'code': code,
        'boutiqueId': boutiqueId,
        'creditsPerRedemption': creditsPerRedemption,
        'maxRedemptions': maxRedemptions,
        'currentRedemptions': currentRedemptions,
        'totalCreditsGranted': totalCreditsGranted,
        'redeemedByUsers': redeemedByUsers,
        'campaignTag': campaignTag,
        'isActive': isActive,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
