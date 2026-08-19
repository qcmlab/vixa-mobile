import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class WidgetSyncService {
  static const String androidWidgetName = 'HafedhWidgetProvider';

  static String _formatTypeLabel(String type) {
    switch (type) {
      case 'qcm':
        return '❓ سؤال تفاعلي QCM';
      case 'date':
        return '📅 تاريخ مهم';
      case 'person':
        return '👤 شخصية تاريخية';
      case 'term':
        return '📖 مصطلح ومفهوم';
      case 'advice':
        return '💡 كبسولة الذاكرة';
      case 'event':
        return '🚩 حدث تاريخي';
      case 'fact':
      default:
        return '📝 بطاقة حفظ';
    }
  }

  /// Syncs flashcards to the Android Home Screen widget
  static Future<void> syncFlashcards(List<FlashcardModel> cards) async {
    if (kIsWeb) return;

    try {
      final total = cards.length;

      // 1. Save via HomeWidget (writes to HomeWidgetPreferences)
      await HomeWidget.saveWidgetData<int>('fc_count', total);

      for (int i = 0; i < cards.length; i++) {
        final card = cards[i];
        final typeLabel = _formatTypeLabel(card.type);
        await HomeWidget.saveWidgetData<String>('fc_q_$i', card.question);
        await HomeWidget.saveWidgetData<String>('fc_a_$i', card.answer);
        await HomeWidget.saveWidgetData<String>('fc_type_$i', typeLabel);
      }

      // 2. Also mirror to SharedPreferences for direct fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('fc_count', total);
      for (int i = 0; i < cards.length; i++) {
        final card = cards[i];
        final typeLabel = _formatTypeLabel(card.type);
        await prefs.setString('fc_q_$i', card.question);
        await prefs.setString('fc_a_$i', card.answer);
        await prefs.setString('fc_type_$i', typeLabel);
      }

      // 3. Trigger widget update
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: 'dz.hafedh.hafedh_mobile.HafedhWidgetProvider',
      );

      debugPrint('✅ Widget synchronized with $total cards');
    } catch (e) {
      debugPrint('⚠️ Failed to sync cards to Android widget: $e');
    }
  }
}
