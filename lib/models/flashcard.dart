class FlashcardModel {
  final String id;
  final String lessonId;
  final String type; // person, date, term, event, fact
  final String question;
  final String answer;
  final String? explanation;
  final String difficulty; // easy, medium, hard
  final String? source;

  FlashcardModel({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.answer,
    this.explanation,
    required this.difficulty,
    this.source,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] ?? '',
      lessonId: json['lesson_id'] ?? '',
      type: json['type'] ?? 'fact',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 'medium',
      source: json['source'],
    );
  }
}

class TodayReviewItem {
  final FlashcardModel card;
  final String queueType; // new, due_today, overdue
  final String status;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;

  TodayReviewItem({
    required this.card,
    required this.queueType,
    required this.status,
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
  });

  factory TodayReviewItem.fromJson(Map<String, dynamic> json) {
    final cardObj = FlashcardModel.fromJson(json['card']);
    final progressObj = json['progress'] as Map<String, dynamic>?;
    final queueType = json['queue_type'] ?? 'new';

    return TodayReviewItem(
      card: cardObj,
      queueType: queueType,
      status: progressObj != null ? (progressObj['status'] ?? 'learning') : 'new',
      repetitions: progressObj != null ? (progressObj['repetitions'] ?? 0) : 0,
      easeFactor: progressObj != null
          ? ((progressObj['ease_factor'] as num?)?.toDouble() ?? 2.5)
          : 2.5,
      intervalDays: progressObj != null ? (progressObj['interval_days'] ?? 0) : 0,
    );
  }
}

class TodayReviewsDeck {
  final List<TodayReviewItem> dueCards;
  final int totalDue;
  final int overdueCount;
  final int dueTodayCount;
  final int newCount;

  TodayReviewsDeck({
    required this.dueCards,
    required this.totalDue,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.newCount,
  });

  factory TodayReviewsDeck.fromJson(Map<String, dynamic> json) {
    final rawCards = (json['cards'] as List<dynamic>?) ?? (json['due_cards'] as List<dynamic>?) ?? [];
    return TodayReviewsDeck(
      dueCards: rawCards.map((item) => TodayReviewItem.fromJson(item)).toList(),
      totalDue: json['total_due'] ?? json['due_count'] ?? rawCards.length,
      overdueCount: json['overdue_count'] ?? 0,
      dueTodayCount: json['due_today_count'] ?? 0,
      newCount: json['new_count'] ?? json['new_cards_count'] ?? 0,
    );
  }
}
