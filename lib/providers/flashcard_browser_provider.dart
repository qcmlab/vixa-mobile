import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/flashcard.dart';
import '../services/widget_sync_service.dart';

class FlashcardBrowserState {
  final List<FlashcardModel> cards;
  final bool isLoading;
  final String? errorMessage;
  final String selectedType; // 'all', 'date', 'person', 'term', 'fact'
  final String? selectedSubjectId;
  final String searchQuery;
  final int totalCount;

  const FlashcardBrowserState({
    this.cards = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedType = 'all',
    this.selectedSubjectId,
    this.searchQuery = '',
    this.totalCount = 0,
  });

  FlashcardBrowserState copyWith({
    List<FlashcardModel>? cards,
    bool? isLoading,
    String? errorMessage,
    String? selectedType,
    String? selectedSubjectId,
    bool clearSubject = false,
    String? searchQuery,
    int? totalCount,
    bool clearError = false,
  }) {
    return FlashcardBrowserState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedType: selectedType ?? this.selectedType,
      selectedSubjectId: clearSubject ? null : (selectedSubjectId ?? this.selectedSubjectId),
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class FlashcardBrowserNotifier extends StateNotifier<FlashcardBrowserState> {
  final ApiClient _api = ApiClient();

  FlashcardBrowserNotifier() : super(const FlashcardBrowserState()) {
    fetchCards();
  }

  Future<void> fetchCards() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final queryParams = <String>[];
      queryParams.add('page_size=100');

      if (state.selectedType != 'all') {
        queryParams.add('card_type=${state.selectedType}');
      }
      if (state.selectedSubjectId != null && state.selectedSubjectId!.isNotEmpty) {
        queryParams.add('subject_id=${state.selectedSubjectId}');
      }
      if (state.searchQuery.trim().isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(state.searchQuery.trim())}');
      }

      final url = '/cards?${queryParams.join('&')}';
      final res = await _api.get(url);

      if (res != null && res['success'] == true) {
        final rawList = (res['data'] as List<dynamic>?) ?? [];
        final items = rawList.map((c) => FlashcardModel.fromJson(c)).toList();
        final total = res['meta'] != null ? (res['meta']['total'] ?? items.length) : items.length;

        // Sync to Android Home Screen Widget
        WidgetSyncService.syncFlashcards(items);

        state = state.copyWith(
          cards: items,
          totalCount: total,
          isLoading: false,
          clearError: true,
        );
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  void setTypeFilter(String type) {
    if (state.selectedType != type) {
      state = state.copyWith(selectedType: type);
      fetchCards();
    }
  }

  void setSubjectFilter(String? subjectId) {
    if (state.selectedSubjectId != subjectId) {
      if (subjectId == null) {
        state = state.copyWith(clearSubject: true);
      } else {
        state = state.copyWith(selectedSubjectId: subjectId);
      }
      fetchCards();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchCards();
  }
}

final flashcardBrowserProvider =
    StateNotifierProvider<FlashcardBrowserNotifier, FlashcardBrowserState>((ref) {
  return FlashcardBrowserNotifier();
});
