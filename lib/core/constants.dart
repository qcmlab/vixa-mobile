import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage.dart';

class AppConstants {
  static const String appName = 'حافظ | Hafedh';
  static const String appTagline = 'رفيقك لحفظ التاريخ والجغرافيا للبكالوريا';

  static String _customBaseUrl = '';

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  // API Base URL
  // Default:
  // - Android Emulator: 10.0.2.2:8000
  // - Web / Desktop / Localhost: localhost:8000
  static String get apiBaseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    final savedUrl = AppStorage.getCustomBaseUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://localhost:8000/api/v1';
    }
  }

  // Storage Keys
  static const String tokenKey = 'hafedh_access_token';
  static const String refreshTokenKey = 'hafedh_refresh_token';
  static const String userKey = 'hafedh_user_data';
}

class AppColors {
  // Emerald & Green theme for Islamic / Algerian heritage
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald 100

  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Background & Surfaces
  static const Color background = Color(0xFF0B1120); // Dark Slate
  static const Color surface = Color(0xFF131D33);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // SM-2 Action Rating Colors
  static const Color ratingAgain = Color(0xFFEF4444); // Red
  static const Color ratingHard = Color(0xFFF97316); // Orange
  static const Color ratingGood = Color(0xFF10B981); // Emerald
  static const Color ratingEasy = Color(0xFF3B82F6); // Blue
}
