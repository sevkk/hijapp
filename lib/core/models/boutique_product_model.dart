import 'package:cloud_firestore/cloud_firestore.dart';

class BoutiqueProductModel {
  final String id;
  final String boutiqueId;
  final String name;
  final String imageUrl;
  final String? description;
  final String? price;
  final String? purchaseUrl;
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
    this.price,
    this.purchaseUrl,
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
      price: data['price'] as String?,
      purchaseUrl: data['purchaseUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      sortOrder: data['sortOrder'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'boutiqueId': boutiqueId,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'price': price,
        'purchaseUrl': purchaseUrl,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
