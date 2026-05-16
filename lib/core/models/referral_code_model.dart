import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralCodeModel {
  final String id;
  final String code;
  final String boutiqueId;
  final int creditsPerRedemption;
  final int maxRedemptions; // 0 = sınırsız
  final int currentRedemptions;
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
    this.isActive = true,
    this.expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Kod hâlâ kullanılabilir mi?
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
      creditsPerRedemption: data['creditsPerRedemption'] as int? ?? 0,
      maxRedemptions: data['maxRedemptions'] as int? ?? 0,
      currentRedemptions: data['currentRedemptions'] as int? ?? 0,
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
        'isActive': isActive,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
