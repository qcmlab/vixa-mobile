import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/di/injection_container.dart';
import '../core/localization/app_translations.dart';
import '../core/storage/storage_service.dart';

class LanguageState {
  final String languageCode; // 'ar', 'fr', 'en'

  const LanguageState({this.languageCode = 'ar'});

  bool get isRtl => languageCode == 'ar';
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;
  Locale get locale => Locale(languageCode);

  String t(String key) {
    return AppTranslations.translations[languageCode]?[key] ??
        AppTranslations.translations['ar']?[key] ??
        key;
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  final IStorageService _storage;
  static const String _languageKey = 'hafedh_selected_language';

  LanguageNotifier(this._storage) : super(const LanguageState()) {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final saved = _storage.getString(_languageKey);
    if (saved != null && (saved == 'ar' || saved == 'fr' || saved == 'en')) {
      state = LanguageState(languageCode: saved);
    }
  }

  Future<void> setLanguage(String langCode) async {
    if (langCode == state.languageCode) return;
    state = LanguageState(languageCode: langCode);
    await _storage.setString(_languageKey, langCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LanguageNotifier(storage);
});
