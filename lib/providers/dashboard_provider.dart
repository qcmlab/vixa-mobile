import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/dashboard_data.dart';

class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiClient _api = ApiClient();

  DashboardNotifier() : super(const DashboardState());

  Future<void> fetchDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.get('/dashboard');
      if (res != null && res['success'] == true) {
        final data = DashboardData.fromJson(res['data']);
        state = state.copyWith(data: data, isLoading: false, clearError: true);
        return;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return;
    }

    state = state.copyWith(isLoading: false);
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
