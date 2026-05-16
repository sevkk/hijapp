import 'package:cloud_firestore/cloud_firestore.dart';

/// Spec v2 Bolum 3.4: BoutiqueModel'e totalTryOns, last30DaysTryOns,
/// productCategories, plan ve opsiyonel customDomain eklendi.
class BoutiqueModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? logoUrl;
  final String? instagramHandle;
  final String? websiteUrl;
  final int creditBalance;
  final int totalCreditsPurchased;
  final int totalCreditsDistributed;
  final int totalTryOns;
  final int last30DaysTryOns;
  final List<String> productCategories;
  final String plan; // 'starter' | 'pro' | 'enterprise'
  final String? customDomain;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BoutiqueModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.logoUrl,
    this.instagramHandle,
    this.websiteUrl,
    this.creditBalance = 0,
    this.totalCreditsPurchased = 0,
    this.totalCreditsDistributed = 0,
    this.totalTryOns = 0,
    this.last30DaysTryOns = 0,
    this.productCategories = const [],
    this.plan = 'starter',
    this.customDomain,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BoutiqueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BoutiqueModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      logoUrl: data['logoUrl'] as String?,
      instagramHandle: data['instagramHandle'] as String?,
      websiteUrl: data['websiteUrl'] as String?,
      creditBalance: (data['creditBalance'] as num?)?.toInt() ?? 0,
      totalCreditsPurchased: (data['totalCreditsPurchased'] as num?)?.toInt() ?? 0,
      totalCreditsDistributed: (data['totalCreditsDistributed'] as num?)?.toInt() ?? 0,
      totalTryOns: (data['totalTryOns'] as num?)?.toInt() ?? 0,
      last30DaysTryOns: (data['last30DaysTryOns'] as num?)?.toInt() ?? 0,
      productCategories: List<String>.from(data['productCategories'] as List? ?? const []),
      plan: data['plan'] as String? ?? 'starter',
      customDomain: data['customDomain'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'phone': phone,
        'logoUrl': logoUrl,
        'instagramHandle': instagramHandle,
        'websiteUrl': websiteUrl,
        'creditBalance': creditBalance,
        'totalCreditsPurchased': totalCreditsPurchased,
        'totalCreditsDistributed': totalCreditsDistributed,
        'totalTryOns': totalTryOns,
        'last30DaysTryOns': last30DaysTryOns,
        'productCategories': productCategories,
        'plan': plan,
        'customDomain': customDomain,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
