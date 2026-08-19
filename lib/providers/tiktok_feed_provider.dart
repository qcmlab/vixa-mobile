import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/injection_container.dart';
import '../features/feed/data/flashcard_repository.dart';
import '../models/flashcard.dart';

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
      List<FlashcardModel> filteredCards = loadedCards;
      if (state.selectedSubject != 'all') {
        filteredCards = loadedCards.where((c) {
          final sub = c.subjectName ?? '';
          if (state.selectedSubject == 'history') {
            return sub.contains('تاريخ') || c.type == 'date' || c.type == 'person';
          } else if (state.selectedSubject == 'geography') {
            return sub.contains('جغرافيا') || c.type == 'term';
          }
          return true;
        }).toList();
      }

      state = state.copyWith(
        cards: filteredCards,
        isLoading: false,
        currentIndex: 0,
      );

      // Flush any queued offline reviews in the background
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

  Future<void> submitQuickReview(String cardId, int rating) async {
    await _repository.submitCardReview(cardId, rating);

    if (rating >= 4) {
      state = state.copyWith(
        masteredTodayCount: state.masteredTodayCount + 1,
      );
    }
  }
}

final tiktokFeedProvider = StateNotifierProvider.autoDispose<TiktokFeedNotifier, TiktokFeedState>((ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  return TiktokFeedNotifier(repository);
});
