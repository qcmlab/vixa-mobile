class QuestionModel {
  final String id;
  final String quizId;
  final String questionText;
  final String questionType;
  final dynamic options;
  final int points;
  final int order;

  QuestionModel({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.points,
    required this.order,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'multiple_choice',
      options: json['options'],
      points: json['points'] ?? 1,
      order: json['order'] ?? 1,
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final String? description;
  final int? timeLimitSeconds;
  final int questionsCount;

  QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.timeLimitSeconds,
    this.questionsCount = 0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      timeLimitSeconds: json['time_limit_seconds'],
      questionsCount: json['questions_count'] ?? 0,
    );
  }
}

class QuizDetailModel {
  final QuizModel quiz;
  final List<QuestionModel> questions;

  QuizDetailModel({required this.quiz, required this.questions});

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) {
    return QuizDetailModel(
      quiz: QuizModel.fromJson(json),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
    );
  }
}

class QuizScoreResult {
  final String attemptId;
  final int score;
  final int maxScore;
  final double percentage;
  final bool isPassed;

  QuizScoreResult({
    required this.attemptId,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.isPassed,
  });

  factory QuizScoreResult.fromJson(Map<String, dynamic> json) {
    return QuizScoreResult(
      attemptId: json['attempt_id'] ?? '',
      score: json['score'] ?? 0,
      maxScore: json['max_score'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['is_passed'] ?? false,
    );
  }
}
