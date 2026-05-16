import 'package:cloud_firestore/cloud_firestore.dart';

/// Butik vitrinindeki bir urun (esarp, sal, hijap, tunik vb.).
///
/// Spec v2 Bolum 3.1: `price` ve `purchaseUrl` cikarildi (uygulamada satis yok);
/// yerine opsiyonel `boutiqueWebsiteUrl` (sade outbound link), `tryOnCount`,
/// `last30DaysCount` ve `category` eklendi.
class BoutiqueProductModel {
  final String id;
  final String boutiqueId;
  final String name;
  final String imageUrl;
  final String? description;
  final String category;
  final String? boutiqueWebsiteUrl;
  final int tryOnCount;
  final int last30DaysCount;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  BoutiqueProductModel({
    required this.id,
    required this.boutiqueId,
    required this.name,
    required this.imageUrl,
    this.description,
    this.category = 'esarp',
    this.boutiqueWebsiteUrl,
    this.tryOnCount = 0,
    this.last30DaysCount = 0,
    this.isActive = true,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BoutiqueProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BoutiqueProductModel(
      id: doc.id,
      boutiqueId: data['boutiqueId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      description: data['description'] as String?,
      category: data['category'] as String? ?? 'esarp',
      boutiqueWebsiteUrl: data['boutiqueWebsiteUrl'] as String?,
      tryOnCount: (data['tryOnCount'] as num?)?.toInt() ?? 0,
      last30DaysCount: (data['last30DaysCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'boutiqueId': boutiqueId,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'category': category,
        'boutiqueWebsiteUrl': boutiqueWebsiteUrl,
        'tryOnCount': tryOnCount,
        'last30DaysCount': last30DaysCount,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  BoutiqueProductModel copyWith({
    String? name,
    String? imageUrl,
    String? description,
    String? category,
    String? boutiqueWebsiteUrl,
    int? tryOnCount,
    int? last30DaysCount,
    bool? isActive,
    int? sortOrder,
  }) {
    return BoutiqueProductModel(
      id: id,
      boutiqueId: boutiqueId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      boutiqueWebsiteUrl: boutiqueWebsiteUrl ?? this.boutiqueWebsiteUrl,
      tryOnCount: tryOnCount ?? this.tryOnCount,
      last30DaysCount: last30DaysCount ?? this.last30DaysCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
