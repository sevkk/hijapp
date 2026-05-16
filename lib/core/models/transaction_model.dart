import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  creditPurchase,
  creditUse,
  referralRedeem,
  boutiquePurchase,
}

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.creditPurchase:
        return 'credit_purchase';
      case TransactionType.creditUse:
        return 'credit_use';
      case TransactionType.referralRedeem:
        return 'referral_redeem';
      case TransactionType.boutiquePurchase:
        return 'boutique_purchase';
    }
  }

  static TransactionType fromString(String s) {
    switch (s) {
      case 'credit_purchase':
        return TransactionType.creditPurchase;
      case 'credit_use':
        return TransactionType.creditUse;
      case 'referral_redeem':
        return TransactionType.referralRedeem;
      case 'boutique_purchase':
        return TransactionType.boutiquePurchase;
      default:
        return TransactionType.creditUse;
    }
  }
}

class TransactionModel {
  final String? id;
  final String userId;
  final TransactionType type;
  final int amount; // pozitif = ekleme, negatif = kullanım
  final String creditSource; // 'personal' | 'boutique:{boutiqueId}'
  final String? boutiqueId;
  final String? referralCode;
  final String description;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.creditSource,
    this.boutiqueId,
    this.referralCode,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: TransactionTypeExtension.fromString(data['type'] as String? ?? ''),
      amount: data['amount'] as int? ?? 0,
      creditSource: data['creditSource'] as String? ?? 'personal',
      boutiqueId: data['boutiqueId'] as String?,
      referralCode: data['referralCode'] as String?,
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type.value,
        'amount': amount,
        'creditSource': creditSource,
        'boutiqueId': boutiqueId,
        'referralCode': referralCode,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
