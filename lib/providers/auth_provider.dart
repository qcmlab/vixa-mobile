import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/storage.dart';
import '../models/user.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(const AuthState()) {
    initAuth();
  }

  Future<void> initAuth() async {
    final token = AppStorage.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _api.get('/auth/me');
        if (res != null && res['success'] == true) {
          final user = UserModel.fromJson(res['data']);
          state = state.copyWith(user: user, isLoading: false, clearError: true);
          return;
        } else {
          await AppStorage.clearAuth();
        }
      } catch (_) {
        await AppStorage.clearAuth();
      }
    }
    state = state.copyWith(clearUser: true, isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.post('/auth/login', body: {
        'email': email.trim(),
        'password': password,
      }, includeAuth: false);

      if (res != null && res['success'] == true) {
        final data = res['data'];
        final accessToken = data['tokens']['access_token'];
        final refreshToken = data['tokens']['refresh_token'];

        await AppStorage.saveToken(accessToken);
        await AppStorage.saveRefreshToken(refreshToken);

        final user = UserModel.fromJson(data['user']);
        await AppStorage.saveUserData(jsonEncode(data['user']));

        state = state.copyWith(user: user, isLoading: false, clearError: true);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? stream,
    int? grade,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _api.post('/auth/register', body: {
        'email': email.trim(),
        'password': password,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'stream': stream ?? 'sciences',
        'grade': grade ?? 3,
        'education_level': 'high_school',
      }, includeAuth: false);

      if (res != null && res['success'] == true) {
        final data = res['data'];
        final accessToken = data['tokens']['access_token'];
        final refreshToken = data['tokens']['refresh_token'];

        await AppStorage.saveToken(accessToken);
        await AppStorage.saveRefreshToken(refreshToken);

        final user = UserModel.fromJson(data['user']);
        state = state.copyWith(user: user, isLoading: false, clearError: true);
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> logout() async {
    await AppStorage.clearAuth();
    state = state.copyWith(clearUser: true, isLoading: false, clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
