class FlashcardModel {
  final String id;
  final String lessonId;
  final String type; // person, date, term, event, fact, qcm, advice
  final String question;
  final String answer;
  final String? explanation;
  final String difficulty; // easy, medium, hard
  final String? source;
  final String? subjectName;
  final String? lessonTitle;
  final List<String>? options;
  final int? correctOptionIndex;
  final String? hint;
  final bool isFavorite;

  FlashcardModel({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.answer,
    this.explanation,
    required this.difficulty,
    this.source,
    this.subjectName,
    this.lessonTitle,
    this.options,
    this.correctOptionIndex,
    this.hint,
    this.isFavorite = false,
  });

  FlashcardModel copyWith({
    String? id,
    String? lessonId,
    String? type,
    String? question,
    String? answer,
    String? explanation,
    String? difficulty,
    String? source,
    String? subjectName,
    String? lessonTitle,
    List<String>? options,
    int? correctOptionIndex,
    String? hint,
    bool? isFavorite,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      source: source ?? this.source,
      subjectName: subjectName ?? this.subjectName,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      hint: hint ?? this.hint,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedOptions;
    if (json['options'] != null && json['options'] is List) {
      parsedOptions = (json['options'] as List).map((e) => e.toString()).toList();
    }

    final id = json['id'] ?? json['card_id'] ?? '';
    final rawType = json['card_type'] ?? json['type'] ?? json['modality'] ?? 'fact';
    final question = json['question'] ?? json['front_prompt'] ?? json['front'] ?? '';
    final answer = json['answer'] ?? json['back_answer'] ?? json['back'] ?? '';
    final explanation = json['explanation'] ?? json['pedagogical_explanation'];
    final hint = json['hint'] ?? json['mnemonic_hint'];
    final subjectName = json['subject_name'] ?? json['subject'] ?? json['subject_title'];
    final lessonTitle = json['lesson_title'] ?? json['lesson'] ?? json['lesson_name'];

    // Normalize type string
    String normalizedType = rawType.toString().toLowerCase();
    if (normalizedType.contains('qcm')) {
      normalizedType = 'qcm';
    } else if (normalizedType.contains('date')) {
      normalizedType = 'date';
    } else if (normalizedType.contains('person')) {
      normalizedType = 'person';
    } else if (normalizedType.contains('term')) {
      normalizedType = 'term';
    } else if (normalizedType.contains('advice')) {
      normalizedType = 'advice';
    } else if (normalizedType.contains('classic') || normalizedType.contains('fact')) {
      normalizedType = 'fact';
    }

    return FlashcardModel(
      id: id.toString(),
      lessonId: (json['lesson_id'] ?? '').toString(),
      type: normalizedType,
      question: question.toString(),
      answer: answer.toString(),
      explanation: explanation?.toString(),
      difficulty: (json['difficulty'] ?? 'medium').toString(),
      source: json['source']?.toString(),
      subjectName: subjectName?.toString(),
      lessonTitle: lessonTitle?.toString(),
      options: parsedOptions,
      correctOptionIndex: json['correct_option_index'] as int?,
      hint: hint?.toString(),
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'type': type,
      'question': question,
      'answer': answer,
      'explanation': explanation,
      'difficulty': difficulty,
      'source': source,
      'subject_name': subjectName,
      'lesson_title': lessonTitle,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'hint': hint,
      'is_favorite': isFavorite,
    };
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
