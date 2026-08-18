import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/flashcard.dart';
import '../models/review_submission.dart';
import '../services/widget_sync_service.dart';

class StudyState {
  final TodayReviewsDeck? deck;
  final bool isLoading;
  final String? errorMessage;
  final int currentIndex;
  final bool isCardFlipped;
  final int sessionReviewedCount;
  final int sessionCorrectCount;
  final List<String> sessionUnlockedAchievements;

  const StudyState({
    this.deck,
    this.isLoading = false,
    this.errorMessage,
    this.currentIndex = 0,
    this.isCardFlipped = false,
    this.sessionReviewedCount = 0,
    this.sessionCorrectCount = 0,
    this.sessionUnlockedAchievements = const [],
  });

  int get totalCardsInSession => deck?.dueCards.length ?? 0;
  bool get isSessionCompleted => deck != null && currentIndex >= totalCardsInSession;

  TodayReviewItem? get currentCardItem {
    if (deck == null || deck!.dueCards.isEmpty) return null;
    if (currentIndex >= deck!.dueCards.length) return null;
    return deck!.dueCards[currentIndex];
  }

  StudyState copyWith({
    TodayReviewsDeck? deck,
    bool? isLoading,
    String? errorMessage,
    int? currentIndex,
    bool? isCardFlipped,
    int? sessionReviewedCount,
    int? sessionCorrectCount,
    List<String>? sessionUnlockedAchievements,
    bool clearError = false,
    bool clearDeck = false,
  }) {
    return StudyState(
      deck: clearDeck ? null : (deck ?? this.deck),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentIndex: currentIndex ?? this.currentIndex,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      sessionReviewedCount: sessionReviewedCount ?? this.sessionReviewedCount,
      sessionCorrectCount: sessionCorrectCount ?? this.sessionCorrectCount,
      sessionUnlockedAchievements: sessionUnlockedAchievements ?? this.sessionUnlockedAchievements,
    );
  }
}

class StudyNotifier extends StateNotifier<StudyState> {
  final ApiClient _api = ApiClient();
  DateTime _cardStartTime = DateTime.now();

  StudyNotifier() : super(const StudyState());

  Future<void> fetchTodayReviews() async {
    state = state.copyWith(
      isLoading: true,
      currentIndex: 0,
      isCardFlipped: false,
      sessionReviewedCount: 0,
      sessionCorrectCount: 0,
      sessionUnlockedAchievements: [],
      clearError: true,
    );

    try {
      final res = await _api.get('/reviews/today');
      if (res != null && res['success'] == true) {
        final deck = TodayReviewsDeck.fromJson(res['data']);
        _cardStartTime = DateTime.now();

        // Sync review deck to home widget
        final cardList = deck.dueCards.map((item) => item.card).toList();
        if (cardList.isNotEmpty) {
          WidgetSyncService.syncFlashcards(cardList);
        }

        state = state.copyWith(deck: deck, isLoading: false, clearError: true);
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  void flipCard() {
    state = state.copyWith(isCardFlipped: !state.isCardFlipped);
  }

  Future<ReviewSubmissionResult?> submitRating(String rating) async {
    final current = state.currentCardItem;
    if (current == null) return null;

    final responseTimeMs = DateTime.now().difference(_cardStartTime).inMilliseconds;

    try {
      final res = await _api.post('/reviews', body: {
        'card_id': current.card.id,
        'rating': rating,
        'response_time_ms': responseTimeMs,
      });

      if (res != null && res['success'] == true) {
        final result = ReviewSubmissionResult.fromJson(res['data']);

        final updatedReviewedCount = state.sessionReviewedCount + 1;
        final updatedCorrectCount = (rating == 'good' || rating == 'easy')
            ? state.sessionCorrectCount + 1
            : state.sessionCorrectCount;

        final updatedAchievements = List<String>.from(state.sessionUnlockedAchievements);
        if (result.newlyUnlockedAchievements.isNotEmpty) {
          updatedAchievements.addAll(result.newlyUnlockedAchievements);
        }

        _cardStartTime = DateTime.now();

        state = state.copyWith(
          currentIndex: state.currentIndex + 1,
          isCardFlipped: false,
          sessionReviewedCount: updatedReviewedCount,
          sessionCorrectCount: updatedCorrectCount,
          sessionUnlockedAchievements: updatedAchievements,
          clearError: true,
        );

        return result;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
    return null;
  }
}

final studyProvider = StateNotifierProvider<StudyNotifier, StudyState>((ref) {
  return StudyNotifier();
});
