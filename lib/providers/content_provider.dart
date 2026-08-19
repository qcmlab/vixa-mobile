import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/flashcard.dart';
import '../models/subject.dart';

class ContentState {
  final List<SubjectModel> subjects;
  final bool isLoading;
  final String? errorMessage;

  const ContentState({
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ContentState copyWith({
    List<SubjectModel>? subjects,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ContentState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ContentNotifier extends StateNotifier<ContentState> {
  final ApiClient _api = ApiClient();

  ContentNotifier() : super(const ContentState());

  Future<void> fetchSubjects() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.get('/subjects');
      if (res != null && res['success'] == true) {
        final list = (res['data'] as List<dynamic>)
            .map((s) => SubjectModel.fromJson(s))
            .toList();
        state = state.copyWith(subjects: list, isLoading: false, clearError: true);
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }

  Future<List<ChapterModel>> fetchChapters(String subjectId) async {
    try {
      final res = await _api.get('/subjects/$subjectId/chapters');
      if (res != null && res['success'] == true) {
        return (res['data'] as List<dynamic>)
            .map((c) => ChapterModel.fromJson(c))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
    }
    return [];
  }

  Future<List<FlashcardModel>> fetchLessonCards(String lessonId) async {
    try {
      final res = await _api.get('/cards?lesson_id=$lessonId&page_size=100');
      if (res != null) {
        dynamic rawList;
        if (res['items'] != null && res['items'] is List) {
          rawList = res['items'];
        } else if (res['data'] != null) {
          if (res['data'] is List) {
            rawList = res['data'];
          } else if (res['data']['items'] != null && res['data']['items'] is List) {
            rawList = res['data']['items'];
          } else if (res['data']['cards'] != null && res['data']['cards'] is List) {
            rawList = res['data']['cards'];
          }
        }
        if (rawList != null && rawList is List) {
          return rawList
              .map((c) => FlashcardModel.fromJson(Map<String, dynamic>.from(c as Map)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching lesson cards: $e');
    }
    return [];
  }
}

final contentProvider = StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier();
});
