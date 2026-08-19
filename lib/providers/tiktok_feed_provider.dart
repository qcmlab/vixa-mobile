import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/injection_container.dart';
import '../core/storage/storage_service.dart';
import '../features/feed/data/flashcard_repository.dart';
import '../models/flashcard.dart';
import '../services/widget_sync_service.dart';
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
  final Map<String, String> cardFeedbackMap; // cardId -> 'notYet' | 'partially' | 'mastered'
  final String activeDeckId;
  final String activeDeckTitle;

  TiktokFeedState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
    this.masteredTodayCount = 12,
    this.streakDays = 5,
    this.selectedSubject = 'all',
    this.selectedType = 'all',
    this.cardFeedbackMap = const {},
    this.activeDeckId = 'all_mixed',
    this.activeDeckTitle = 'بنك البكالوريا الشامل',
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
    Map<String, String>? cardFeedbackMap,
    String? activeDeckId,
    String? activeDeckTitle,
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
      cardFeedbackMap: cardFeedbackMap ?? this.cardFeedbackMap,
      activeDeckId: activeDeckId ?? this.activeDeckId,
      activeDeckTitle: activeDeckTitle ?? this.activeDeckTitle,
    );
  }
}

class TiktokFeedNotifier extends StateNotifier<TiktokFeedState> {
  final IFlashcardRepository _repository;
  final IStorageService _storage;
  static const String _feedbackStorageKey = 'hafedh_card_priority_feedback';

  TiktokFeedNotifier(this._repository, this._storage) : super(TiktokFeedState()) {
    _loadSavedFeedbackMap();
    loadFeed();
  }

  void _loadSavedFeedbackMap() {
    try {
      final jsonStr = _storage.getString(_feedbackStorageKey);
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        final map = decoded.map((k, v) => MapEntry(k, v.toString()));
        state = state.copyWith(cardFeedbackMap: map);
      }
    } catch (_) {
      // Ignore parse failure, start with empty feedback map
    }
  }

  Future<void> _persistFeedbackMap() async {
    try {
      final jsonStr = jsonEncode(state.cardFeedbackMap);
      await _storage.setString(_feedbackStorageKey, jsonStr);
    } catch (_) {}
  }

  /// Organizes cards into 3 priority tiers with random shuffling within each tier:
  /// - Tier 1 (Top Priority): Unreviewed cards + "Not Yet" (0% / لم أحفظ) -> Randomized
  /// - Tier 2 (Middle Priority): "Partially" (50% / نصف حفظ) -> Randomized
  /// - Tier 3 (Low Priority): "Mastered" (100% / أتقنتُها) -> Randomized
  List<FlashcardModel> _organizeDeckByPriority(
    List<FlashcardModel> inputCards,
    Map<String, String> feedbackMap,
  ) {
    final tier1Top = <FlashcardModel>[];
    final tier2Middle = <FlashcardModel>[];
    final tier3Low = <FlashcardModel>[];

    for (final card in inputCards) {
      final feedback = feedbackMap[card.id];
      if (feedback == 'mastered') {
        tier3Low.add(card);
      } else if (feedback == 'partially') {
        tier2Middle.add(card);
      } else {
        // null (unreviewed) or 'notYet' (0% / لم أحفظ)
        tier1Top.add(card);
      }
    }

    // Always shuffle randomly within each tier for addictive, varied flashcard feeds
    tier1Top.shuffle();
    tier2Middle.shuffle();
    tier3Low.shuffle();

    return [...tier1Top, ...tier2Middle, ...tier3Low];
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

      // Re-order deck by memorization priority (Tier 1 Top -> Tier 2 Middle -> Tier 3 Low)
      final prioritizedCards = _organizeDeckByPriority(filteredCards, state.cardFeedbackMap);

      state = state.copyWith(
        cards: prioritizedCards,
        isLoading: false,
        currentIndex: 0,
      );

      // Auto-sync prioritized cards to the Android outside widget
      WidgetSyncService.syncFlashcards(prioritizedCards);

      // Flush any queued offline reviews in background
      _repository.flushOfflineReviews();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sets any custom multimodal deck directly into the feed screen
  void loadDeckCards(List<FlashcardModel> customCards, {String? deckTitle, String? deckId}) {
    if (customCards.isEmpty) return;
    final prioritized = _organizeDeckByPriority(customCards, state.cardFeedbackMap);
    state = state.copyWith(
      cards: prioritized,
      isLoading: false,
      currentIndex: 0,
      selectedSubject: 'all',
      activeDeckId: deckId ?? 'custom_deck',
      activeDeckTitle: deckTitle ?? 'رزمة مخصصة',
    );
  }

  /// Selects and loads any deck by its ID from the repository
  Future<void> selectDeck(String deckId, {String? title}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final deckCards = await _repository.getCardsByDeckId(deckId);
      final prioritized = _organizeDeckByPriority(deckCards, state.cardFeedbackMap);
      state = state.copyWith(
        cards: prioritized,
        isLoading: false,
        currentIndex: 0,
        selectedSubject: 'all',
        activeDeckId: deckId,
        activeDeckTitle: title ?? 'رزمة تعليمية',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableDecks() async {
    return _repository.getAvailableDecks();
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
    String levelKey = 'partially';

    switch (level) {
      case FeedbackLevel.notYet:
        rating = 1; // Again / Failed
        levelKey = 'notYet';
        break;
      case FeedbackLevel.partially:
        rating = 3; // Hard / 50%
        levelKey = 'partially';
        break;
      case FeedbackLevel.mastered:
        rating = 5; // Easy / 100%
        levelKey = 'mastered';
        break;
    }

    // 1. Submit review rating to backend / offline sync queue
    await _repository.submitCardReview(cardId, rating);

    // 2. Update and persist priority feedback status map
    final updatedMap = Map<String, String>.from(state.cardFeedbackMap);
    updatedMap[cardId] = levelKey;
    state = state.copyWith(cardFeedbackMap: updatedMap);
    _persistFeedbackMap();

    // 3. Dynamic Real-Time Deck Adjustment:
    final currentCards = List<FlashcardModel>.from(state.cards);
    final cardIdx = currentCards.indexWhere((c) => c.id == cardId);

    if (cardIdx != -1) {
      final card = currentCards[cardIdx];

      if (level == FeedbackLevel.notYet) {
        // High Priority: Re-insert card 3-4 items ahead in the active session for immediate spaced repetition!
        final reinsertIdx = (cardIdx + 4).clamp(0, currentCards.length);
        currentCards.insert(reinsertIdx, card);
        state = state.copyWith(cards: currentCards);
      } else if (level == FeedbackLevel.mastered) {
        // Low Priority: Increment mastered count and move card to the end of the deck
        state = state.copyWith(
          masteredTodayCount: state.masteredTodayCount + 1,
        );
      }
    }
  }
}

final tiktokFeedProvider = StateNotifierProvider.autoDispose<TiktokFeedNotifier, TiktokFeedState>((ref) {
  final repository = ref.watch(flashcardRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return TiktokFeedNotifier(repository, storage);
});
