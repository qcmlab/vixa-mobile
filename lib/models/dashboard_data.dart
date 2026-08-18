class DailyActivityPoint {
  final String date;
  final int count;
  final double accuracyPercentage;

  DailyActivityPoint({
    required this.date,
    required this.count,
    this.accuracyPercentage = 0.0,
  });

  factory DailyActivityPoint.fromJson(Map<String, dynamic> json) {
    return DailyActivityPoint(
      date: json['date'] ?? '',
      count: json['cards_reviewed'] ?? json['count'] ?? 0,
      accuracyPercentage: (json['accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WeakSubjectInfo {
  final String subjectName;
  final double accuracyPercentage;
  final int totalReviews;

  WeakSubjectInfo({
    required this.subjectName,
    required this.accuracyPercentage,
    required this.totalReviews,
  });

  factory WeakSubjectInfo.fromJson(Map<String, dynamic> json) {
    return WeakSubjectInfo(
      subjectName: json['subject_name'] ?? '',
      accuracyPercentage: (json['accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
    );
  }
}

class DashboardData {
  final int cardsReviewedToday;
  final int cardsRemainingToday;
  final int dailyGoal;
  final int currentStreak;
  final int longestStreak;
  final int masteredCards;
  final int learningCards;
  final int totalCardsStudied;
  final double overallAccuracyPercentage;
  final List<DailyActivityPoint> weeklyActivity;
  final List<WeakSubjectInfo> weakSubjects;

  DashboardData({
    required this.cardsReviewedToday,
    required this.cardsRemainingToday,
    required this.dailyGoal,
    required this.currentStreak,
    required this.longestStreak,
    required this.masteredCards,
    required this.learningCards,
    required this.totalCardsStudied,
    required this.overallAccuracyPercentage,
    this.weeklyActivity = const [],
    this.weakSubjects = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      cardsReviewedToday: json['cards_reviewed_today'] ?? 0,
      cardsRemainingToday: json['cards_remaining_today'] ?? 0,
      dailyGoal: json['daily_goal'] ?? 10,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      masteredCards: json['mastered_cards'] ?? 0,
      learningCards: json['learning_cards'] ?? 0,
      totalCardsStudied: json['total_cards_studied'] ?? 0,
      overallAccuracyPercentage:
          (json['overall_accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
      weeklyActivity: (json['weekly_activity'] as List<dynamic>?)
              ?.map((p) => DailyActivityPoint.fromJson(p))
              .toList() ??
          [],
      weakSubjects: (json['weak_subjects'] as List<dynamic>?)
              ?.map((ws) => WeakSubjectInfo.fromJson(ws))
              .toList() ??
          [],
    );
  }
}
