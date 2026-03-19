class UserModel {
  final String uid;
  final String email;
  final bool isPremium;
  final int dailyProcessingCount;
  final DateTime lastProcessingDate;

  UserModel({
    required this.uid,
    required this.email,
    this.isPremium = false,
    this.dailyProcessingCount = 0,
    DateTime? lastProcessingDate,
  }) : lastProcessingDate = lastProcessingDate ?? DateTime.now();

  bool get canProcess {
    if (isPremium) return true;
    final today = DateTime.now();
    if (lastProcessingDate.day != today.day ||
        lastProcessingDate.month != today.month ||
        lastProcessingDate.year != today.year) {
      return true;
    }
    return dailyProcessingCount < 5;
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'isPremium': isPremium,
        'dailyProcessingCount': dailyProcessingCount,
        'lastProcessingDate': lastProcessingDate.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        isPremium: json['isPremium'] as bool? ?? false,
        dailyProcessingCount: json['dailyProcessingCount'] as int? ?? 0,
        lastProcessingDate: json['lastProcessingDate'] != null
            ? DateTime.parse(json['lastProcessingDate'] as String)
            : null,
      );
}
