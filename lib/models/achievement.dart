class AchievementModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? iconUrl;
  final String category;
  final int points;
  final bool isUnlocked;
  final String? unlockedAt;

  AchievementModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.category,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'],
      category: json['category'] ?? 'learning',
      points: json['points'] ?? 10,
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt: json['unlocked_at'],
    );
  }
}
