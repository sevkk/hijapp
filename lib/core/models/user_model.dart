import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final int credits;
  final int totalCreditsUsed;
  final List<String> redeemedCodes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.credits = 3,
    this.totalCreditsUsed = 0,
    this.redeemedCodes = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Kredi var mı?
  bool get canProcess => credits > 0;

  /// Firestore'dan oku
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      credits: data['credits'] as int? ?? 0,
      totalCreditsUsed: data['totalCreditsUsed'] as int? ?? 0,
      redeemedCodes: List<String>.from(data['redeemedCodes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'a yaz
  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'credits': credits,
        'totalCreditsUsed': totalCreditsUsed,
        'redeemedCodes': redeemedCodes,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// JSON'dan oku (local cache için)
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        credits: json['credits'] as int? ?? 0,
        totalCreditsUsed: json['totalCreditsUsed'] as int? ?? 0,
        redeemedCodes: List<String>.from(json['redeemedCodes'] ?? []),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  /// JSON'a yaz
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'credits': credits,
        'totalCreditsUsed': totalCreditsUsed,
        'redeemedCodes': redeemedCodes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
