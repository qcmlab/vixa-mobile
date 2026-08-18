import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/achievement.dart';

class AchievementsState {
  final List<AchievementModel> achievements;
  final bool isLoading;
  final String? errorMessage;

  const AchievementsState({
    this.achievements = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalPoints => achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, item) => sum + item.points);

  AchievementsState copyWith({
    List<AchievementModel>? achievements,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AchievementsNotifier extends StateNotifier<AchievementsState> {
  final ApiClient _api = ApiClient();

  AchievementsNotifier() : super(const AchievementsState());

  Future<void> fetchAchievements() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.get('/achievements');
      if (res != null && res['success'] == true) {
        final list = (res['data'] as List<dynamic>)
            .map((a) => AchievementModel.fromJson(a))
            .toList();
        state = state.copyWith(achievements: list, isLoading: false, clearError: true);
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  return AchievementsNotifier();
});
