class ReviewSubmissionResult {
  final String status;
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final String nextReviewAt;
  final int currentStreak;
  final List<String> newlyUnlockedAchievements;

  ReviewSubmissionResult({
    required this.status,
    required this.intervalDays,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReviewAt,
    required this.currentStreak,
    this.newlyUnlockedAchievements = const [],
  });

  factory ReviewSubmissionResult.fromJson(Map<String, dynamic> json) {
    return ReviewSubmissionResult(
      status: json['status'] ?? 'learning',
      intervalDays: json['interval_days'] ?? 1,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      repetitions: json['repetitions'] ?? 1,
      nextReviewAt: json['next_review_at'] ?? '',
      currentStreak: json['current_streak'] ?? 1,
      newlyUnlockedAchievements: (json['newly_unlocked_achievements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
