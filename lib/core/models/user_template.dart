class UserTemplate {
  final String id;
  final String name;
  final String imagePath;
  final DateTime createdAt;

  UserTemplate({
    required this.id,
    required this.name,
    required this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserTemplate.fromJson(Map<String, dynamic> json) => UserTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        imagePath: json['imagePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
