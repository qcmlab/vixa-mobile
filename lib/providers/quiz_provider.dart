import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/quiz.dart';

class QuizState {
  final List<QuizModel> quizzes;
  final bool isLoading;
  final String? errorMessage;
  final QuizDetailModel? currentQuizDetail;
  final int currentQuestionIndex;
  final Map<String, dynamic> userAnswers;
  final QuizScoreResult? lastResult;

  const QuizState({
    this.quizzes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentQuizDetail,
    this.currentQuestionIndex = 0,
    this.userAnswers = const {},
    this.lastResult,
  });

  QuizState copyWith({
    List<QuizModel>? quizzes,
    bool? isLoading,
    String? errorMessage,
    QuizDetailModel? currentQuizDetail,
    int? currentQuestionIndex,
    Map<String, dynamic>? userAnswers,
    QuizScoreResult? lastResult,
    bool clearError = false,
    bool clearQuiz = false,
    bool clearResult = false,
  }) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentQuizDetail: clearQuiz ? null : (currentQuizDetail ?? this.currentQuizDetail),
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final ApiClient _api = ApiClient();

  QuizNotifier() : super(const QuizState());

  Future<void> fetchQuizzes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.get('/quizzes');
      if (res != null && res['success'] == true) {
        final list = (res['data'] as List<dynamic>)
            .map((q) => QuizModel.fromJson(q))
            .toList();
        state = state.copyWith(quizzes: list, isLoading: false, clearError: true);
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  Future<bool> startQuiz(String quizId) async {
    state = state.copyWith(
      isLoading: true,
      currentQuestionIndex: 0,
      userAnswers: {},
      clearResult: true,
      clearError: true,
    );

    try {
      final detailRes = await _api.get('/quizzes/$quizId');
      if (detailRes != null && detailRes['success'] == true) {
        final detail = QuizDetailModel.fromJson(detailRes['data']);
        await _api.post('/quizzes/$quizId/start');
        state = state.copyWith(currentQuizDetail: detail, isLoading: false, clearError: true);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  void recordAnswer(String questionId, dynamic answer) {
    final updated = Map<String, dynamic>.from(state.userAnswers);
    updated[questionId] = answer;
    state = state.copyWith(userAnswers: updated);
  }

  void nextQuestion() {
    if (state.currentQuizDetail != null &&
        state.currentQuestionIndex < state.currentQuizDetail!.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  Future<bool> submitQuiz() async {
    if (state.currentQuizDetail == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    final answersList = state.userAnswers.entries
        .map((e) => {'question_id': e.key, 'user_answer': e.value})
        .toList();

    try {
      final res = await _api.post(
        '/quizzes/${state.currentQuizDetail!.quiz.id}/submit',
        body: {'answers': answersList},
      );

      if (res != null && res['success'] == true) {
        final result = QuizScoreResult.fromJson(res['data']);
        state = state.copyWith(lastResult: result, isLoading: false, clearError: true);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }

    state = state.copyWith(isLoading: false);
    return false;
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
