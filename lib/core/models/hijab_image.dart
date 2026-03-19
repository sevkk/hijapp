class HijabImage {
  final String id;
  final String path;
  final DateTime addedAt;

  HijabImage({
    required this.id,
    required this.path,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'addedAt': addedAt.toIso8601String(),
      };

  factory HijabImage.fromJson(Map<String, dynamic> json) => HijabImage(
        id: json['id'] as String,
        path: json['path'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
