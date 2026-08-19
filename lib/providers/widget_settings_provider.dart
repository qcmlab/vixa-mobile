import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/injection_container.dart';
import '../core/storage/storage_service.dart';
import '../features/feed/data/flashcard_repository.dart';
import '../models/flashcard.dart';
import '../services/widget_sync_service.dart';

class WidgetSettingsState {
  final String subjectScope; // 'all', 'history', 'geography'
  final String modalityFilter; // 'all', 'date', 'person', 'term', 'qcm', 'advice'
  final String orderingMode; // 'priority' (0% first), 'random'
  final bool autoShuffleOnUnlock;
  final int syncedCardCount;
  final bool isSyncing;

  const WidgetSettingsState({
    this.subjectScope = 'all',
    this.modalityFilter = 'all',
    this.orderingMode = 'priority',
    this.autoShuffleOnUnlock = true,
    this.syncedCardCount = 0,
    this.isSyncing = false,
  });

  WidgetSettingsState copyWith({
    String? subjectScope,
    String? modalityFilter,
    String? orderingMode,
    bool? autoShuffleOnUnlock,
    int? syncedCardCount,
    bool? isSyncing,
  }) {
    return WidgetSettingsState(
      subjectScope: subjectScope ?? this.subjectScope,
      modalityFilter: modalityFilter ?? this.modalityFilter,
      orderingMode: orderingMode ?? this.orderingMode,
      autoShuffleOnUnlock: autoShuffleOnUnlock ?? this.autoShuffleOnUnlock,
      syncedCardCount: syncedCardCount ?? this.syncedCardCount,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class WidgetSettingsNotifier extends StateNotifier<WidgetSettingsState> {
  final IStorageService _storage;
  final IFlashcardRepository _repository;
  static const String _settingsStorageKey = 'hafedh_widget_custom_settings';

  WidgetSettingsNotifier(this._storage, this._repository) : super(const WidgetSettingsState()) {
    _loadSavedSettings();
  }

  void _loadSavedSettings() {
    try {
      final jsonStr = _storage.getString(_settingsStorageKey);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = state.copyWith(
          subjectScope: map['subjectScope'] ?? 'all',
          modalityFilter: map['modalityFilter'] ?? 'all',
          orderingMode: map['orderingMode'] ?? 'priority',
          autoShuffleOnUnlock: map['autoShuffleOnUnlock'] ?? true,
        );
      }
    } catch (_) {}
  }

  Future<void> _persistSettings() async {
    try {
      final map = {
        'subjectScope': state.subjectScope,
        'modalityFilter': state.modalityFilter,
        'orderingMode': state.orderingMode,
        'autoShuffleOnUnlock': state.autoShuffleOnUnlock,
      };
      await _storage.setString(_settingsStorageKey, jsonEncode(map));
    } catch (_) {}
  }

  void setSubjectScope(String scope) {
    if (state.subjectScope == scope) return;
    state = state.copyWith(subjectScope: scope);
    _persistSettings();
    syncWidgetNow();
  }

  void setModalityFilter(String modality) {
    if (state.modalityFilter == modality) return;
    state = state.copyWith(modalityFilter: modality);
    _persistSettings();
    syncWidgetNow();
  }

  void setOrderingMode(String mode) {
    if (state.orderingMode == mode) return;
    state = state.copyWith(orderingMode: mode);
    _persistSettings();
    syncWidgetNow();
  }

  void toggleAutoShuffle(bool val) {
    state = state.copyWith(autoShuffleOnUnlock: val);
    _persistSettings();
  }

  /// Syncs flashcards to the outside Android home screen widget based on active settings
  Future<void> syncWidgetNow({List<FlashcardModel>? optionalCustomCards}) async {
    state = state.copyWith(isSyncing: true);

    try {
      List<FlashcardModel> sourceCards = optionalCustomCards ?? await _repository.getFeedCards();

      // 1. Filter by Subject Scope
      if (state.subjectScope != 'all') {
        sourceCards = sourceCards.where((c) {
          final sub = c.subjectName ?? '';
          if (state.subjectScope == 'history') {
            return sub.contains('تاريخ') || c.type == 'date' || c.type == 'person';
          } else if (state.subjectScope == 'geography') {
            return sub.contains('جغرافيا') || c.type == 'term';
          }
          return true;
        }).toList();
      }

      // 2. Filter by Modality
      if (state.modalityFilter != 'all') {
        sourceCards = sourceCards.where((c) => c.type == state.modalityFilter).toList();
      }

      // 3. Order Cards (Priority Tier vs Pure Random)
      if (state.orderingMode == 'random') {
        sourceCards.shuffle();
      } else {
        // Priority-based (0% unlearned first, 50% middle, 100% last)
        final feedbackMapJson = _storage.getString('hafedh_card_priority_feedback');
        Map<String, String> feedbackMap = {};
        if (feedbackMapJson != null) {
          try {
            feedbackMap = (jsonDecode(feedbackMapJson) as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
          } catch (_) {}
        }

        final tier1 = <FlashcardModel>[];
        final tier2 = <FlashcardModel>[];
        final tier3 = <FlashcardModel>[];

        for (final card in sourceCards) {
          final rating = feedbackMap[card.id];
          if (rating == 'mastered') {
            tier3.add(card);
          } else if (rating == 'partially') {
            tier2.add(card);
          } else {
            tier1.add(card);
          }
        }

        tier1.shuffle();
        tier2.shuffle();
        tier3.shuffle();
        sourceCards = [...tier1, ...tier2, ...tier3];
      }

      // 4. Push to Android Outside Widget
      await WidgetSyncService.syncFlashcards(sourceCards);

      state = state.copyWith(
        syncedCardCount: sourceCards.length,
        isSyncing: false,
      );
    } catch (e) {
      debugPrint('Error syncing widget: $e');
      state = state.copyWith(isSyncing: false);
    }
  }
}

final widgetSettingsProvider = StateNotifierProvider<WidgetSettingsNotifier, WidgetSettingsState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final repository = ref.watch(flashcardRepositoryProvider);
  return WidgetSettingsNotifier(storage, repository);
});
