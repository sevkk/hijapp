import 'package:cloud_firestore/cloud_firestore.dart';

/// Spec v2 Bolum 3.2: Her basarili (veya basarisiz) try-on bir event olarak
/// `try_on_events` koleksiyonuna loglanir. Analitik akisinin temeli.
///
/// Indexler:
///   - boutiqueId + timestamp DESC
///   - productId + timestamp DESC
///   - referralCodeId + timestamp DESC
enum TryOnUserType { free, paid, referral, anonymous }

extension TryOnUserTypeX on TryOnUserType {
  String get wire {
    switch (this) {
      case TryOnUserType.free:
        return 'free';
      case TryOnUserType.paid:
        return 'paid';
      case TryOnUserType.referral:
        return 'referral';
      case TryOnUserType.anonymous:
        return 'anonymous';
    }
  }

  static TryOnUserType fromWire(String? v) {
    switch (v) {
      case 'paid':
        return TryOnUserType.paid;
      case 'referral':
        return TryOnUserType.referral;
      case 'anonymous':
        return TryOnUserType.anonymous;
      case 'free':
      default:
        return TryOnUserType.free;
    }
  }
}

class TryOnEventModel {
  final String id;
  final String boutiqueId;
  final String productId;
  final String? userId;
  final TryOnUserType userType;
  final String? referralCodeId;
  final DateTime timestamp;
  final String replicateModel;
  final bool succeeded;
  final double costUsd;
  final String? errorMessage;

  TryOnEventModel({
    required this.id,
    required this.boutiqueId,
    required this.productId,
    this.userId,
    this.userType = TryOnUserType.free,
    this.referralCodeId,
    DateTime? timestamp,
    this.replicateModel = 'prunaai/p-image-edit',
    this.succeeded = true,
    this.costUsd = 0.0,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TryOnEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TryOnEventModel(
      id: doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      userId: data['userId'] as String?,
      userType: TryOnUserTypeX.fromWire(data['userType'] as String?),
      referralCodeId: data['referralCodeId'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replicateModel: data['replicateModel'] as String? ?? 'prunaai/p-image-edit',
      succeeded: data['succeeded'] as bool? ?? true,
      costUsd: (data['costUsd'] as num?)?.toDouble() ?? 0.0,
      errorMessage: data['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'boutiqueId': boutiqueId,
        'productId': productId,
        'userId': userId,
        'userType': userType.wire,
        'referralCodeId': referralCodeId,
        'timestamp': Timestamp.fromDate(timestamp),
        'replicateModel': replicateModel,
        'succeeded': succeeded,
        'costUsd': costUsd,
        'errorMessage': errorMessage,
      };
}
