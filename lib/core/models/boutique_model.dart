import 'package:cloud_firestore/cloud_firestore.dart';

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
      creditBalance: data['creditBalance'] as int? ?? 0,
      totalCreditsPurchased: data['totalCreditsPurchased'] as int? ?? 0,
      totalCreditsDistributed: data['totalCreditsDistributed'] as int? ?? 0,
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
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
