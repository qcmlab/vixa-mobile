import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/injection_container.dart';
import '../features/feed/data/flashcard_repository.dart';
import '../models/flashcard.dart';
import '../widgets/feed/memorization_feedback_bar.dart';

class TiktokFeedState {
  final List<FlashcardModel> cards;
  final bool isLoading;
  final String? error;
  final int currentIndex;
  final int masteredTodayCount;
  final int streakDays;
  final String selectedSubject; // 'all', 'history', 'geography'
  final String selectedType; // 'all', 'qcm', 'date', 'person', 'term', 'fact'

  TiktokFeedState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
    this.masteredTodayCount = 12,
    this.streakDays = 5,
    this.selectedSubject = 'all',
    this.selectedType = 'all',
  });

  TiktokFeedState copyWith({
    List<FlashcardModel>? cards,
    bool? isLoading,
    String? error,
    int? currentIndex,
    int? masteredTodayCount,
    int? streakDays,
    String? selectedSubject,
    String? selectedType,
  }) {
    return TiktokFeedState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
      masteredTodayCount: masteredTodayCount ?? this.masteredTodayCount,
      streakDays: streakDays ?? this.streakDays,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class TiktokFeedNotifier extends StateNotifier<TiktokFeedState> {
  final IFlashcardRepository _repository;

  TiktokFeedNotifier(this._repository) : super(TiktokFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool forceRefresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final loadedCards = await _repository.getFeedCards(
        type: state.selectedType,
        forceRefresh: forceRefresh,
      );

      // Filter by subject if specified
      List<FlashcardModel> filteredCards = List.from(loadedCards);
      if (state.selectedSubject != 'all') {
        filteredCards = filteredCards.where((c) {
          final sub = c.subjectName ?? '';
          if (state.selectedSubject == 'history') {
            return sub.contains('تاريخ') || c.type == 'date' || c.type == 'person';
          } else if (state.selectedSubject == 'geography') {
            return sub.contains('جغرافيا') || c.type == 'term';
          }
          return true;
        }).toList();
      }

      // Always shuffle for random addictive TikTok feed order
      filteredCards.shuffle();

      state = state.copyWith(
        cards: filteredCards,
        isLoading: false,
        currentIndex: 0,
      );

      // Flush any queued offline reviews in background
      _repository.flushOfflineReviews();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setSubjectFilter(String subject) {
    if (state.selectedSubject == subject) return;
    state = state.copyWith(selectedSubject: subject);
    loadFeed();
  }

  void setTypeFilter(String type) {
    if (state.selectedType == type) return;
    state = state.copyWith(selectedType: type);
    loadFeed();
  }

  void toggleFavorite(String cardId) {
    final updated = state.cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();

    state = state.copyWith(cards: updated);
  }

  Future<void> submitFeedback(String cardId, FeedbackLevel level) async {
    int rating = 3;
    switch (level) {
      case FeedbackLevel.notYet:
        rating = 1; // Again / Failed
        break;
      case FeedbackLevel.partially:
        rating = 3; // Hard / 50%
        break;
      case FeedbackLevel.mastered:
        rating = 5; // Easy / 100%
        break;
    }

    await _repository.submitCardReview(cardId, rating);

    if (level == FeedbackLevel.mastered) {
      state = state.copyWith(
        masteredTodayCount: state.masteredTodayCount + 1,
      );
    } else if (level == FeedbackLevel.notYet) {
      // Re-insert the card 3 to 5 items down the current list so student sees it again soon!
      final cardsList = List<FlashcardModel>.from(state.cards);
      final cardIdx = cardsList.indexWhere((c) => c.id == cardId);
      if (cardIdx != -1) {
        final card = cardsList[cardIdx];
        final reinsertIdx = (cardIdx + 4).clamp(0, cardsList.length);
        cardsList.insert(reinsertIdx, card);
        state = state.copyWith(cards: cardsList);
      }
    }
  }
}

final tiktokFeedProvider = StateNotifierProvider.autoDispose<TiktokFeedNotifier, TiktokFeedState>((ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  return TiktokFeedNotifier(repository);
});
