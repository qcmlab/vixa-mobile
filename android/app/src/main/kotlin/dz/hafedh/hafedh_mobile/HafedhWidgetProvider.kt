package dz.hafedh.hafedh_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews

class HafedhWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_NEXT_CARD = "dz.hafedh.hafedh_mobile.ACTION_NEXT_CARD"
        const val ACTION_PREV_CARD = "dz.hafedh.hafedh_mobile.ACTION_PREV_CARD"
        const val ACTION_FLIP_CARD = "dz.hafedh.hafedh_mobile.ACTION_FLIP_CARD"
        private const val PREFS_NAME = "HafedhWidgetState"
        private const val KEY_CURRENT_INDEX = "current_card_index"
        private const val KEY_IS_FLIPPED = "current_card_is_flipped"

        // Built-in Algerian Baccalaureate Flashcards (Instant display on placement)
        private val DEFAULT_CARDS = listOf(
            Triple(
                "ما هو تاريخ اندلاع الثورة التحريرية الجزائرية الكبرى؟",
                "01 نوفمبر 1954م على الساعة الصفر بعمليات عسكرية شملت كامل التراب الوطني.",
                "📅 تاريخ مهم"
            ),
            Triple(
                "ما هو مؤتمر الصومام وما تاريخ انعقاده؟",
                "20 أوت 1956م، مؤتمر تاريخي بجبال الصومام لإعادة تنظيم وهيكلة الثورة سياسياً وعسكرياً.",
                "📅 تاريخ مهم"
            ),
            Triple(
                "من هو مصطفى بن بولعيد؟",
                "أحد مفجري الثورة التحريرية وقائد المنطقة الأولى (الأوراس)، لُقب بـ 'أب الثورة'.",
                "👤 شخصية تاريخية"
            ),
            Triple(
                "ما هو تعريف منظمة الأوبك (OPEC)؟",
                "منظمة الدول المصدرة للبترول، تأسست سنة 1960 في بغداد لتوحيد السياسات البترولية وضمان استقرار الأسواق.",
                "📖 مصطلح ومفهوم"
            ),
            Triple(
                "ما هو تاريخ استرجاع السيادة الوطنية والاستقلال؟",
                "05 جويلية 1962م بعد استفتاء تقرير المصير بنسبة ساحقة.",
                "📅 تاريخ مهم"
            )
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        when (intent.action) {
            ACTION_NEXT_CARD -> {
                val totalCount = intent.getIntExtra("total_count", DEFAULT_CARDS.size)
                val current = prefs.getInt(KEY_CURRENT_INDEX, 0)
                val next = if (totalCount > 0) (current + 1) % totalCount else 0
                prefs.edit().putInt(KEY_CURRENT_INDEX, next).putBoolean(KEY_IS_FLIPPED, false).apply()
                updateAllWidgets(context)
            }
            ACTION_PREV_CARD -> {
                val totalCount = intent.getIntExtra("total_count", DEFAULT_CARDS.size)
                val current = prefs.getInt(KEY_CURRENT_INDEX, 0)
                val prev = if (totalCount > 0) (current - 1 + totalCount) % totalCount else 0
                prefs.edit().putInt(KEY_CURRENT_INDEX, prev).putBoolean(KEY_IS_FLIPPED, false).apply()
                updateAllWidgets(context)
            }
            ACTION_FLIP_CARD -> {
                val isFlipped = prefs.getBoolean(KEY_IS_FLIPPED, false)
                prefs.edit().putBoolean(KEY_IS_FLIPPED, !isFlipped).apply()
                updateAllWidgets(context)
            }
        }
    }

    private fun updateAllWidgets(context: Context) {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisAppWidget = ComponentName(context.packageName, HafedhWidgetProvider::class.java.name)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val localPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Try HomeWidgetPreferences first, then FlutterSharedPreferences
        val widgetPrefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.hafedh_flashcard_widget)

                var totalCount = widgetPrefs.getInt("fc_count", 0)
                var sourcePrefs: SharedPreferences = widgetPrefs

                if (totalCount == 0) {
                    totalCount = flutterPrefs.getInt("flutter.fc_count", 0)
                    if (totalCount > 0) {
                        sourcePrefs = flutterPrefs
                    }
                }

                val hasData = totalCount > 0
                val effectiveTotal = if (hasData) totalCount else DEFAULT_CARDS.size

                var currentIndex = localPrefs.getInt(KEY_CURRENT_INDEX, 0)
                if (currentIndex >= effectiveTotal || currentIndex < 0) {
                    currentIndex = 0
                    localPrefs.edit().putInt(KEY_CURRENT_INDEX, 0).apply()
                }

                val isFlipped = localPrefs.getBoolean(KEY_IS_FLIPPED, false)

                val question: String
                val answer: String
                val category: String

                if (hasData) {
                    question = sourcePrefs.getString("fc_q_$currentIndex", null)
                        ?: sourcePrefs.getString("flutter.fc_q_$currentIndex", DEFAULT_CARDS[0].first)
                        ?: DEFAULT_CARDS[0].first

                    answer = sourcePrefs.getString("fc_a_$currentIndex", null)
                        ?: sourcePrefs.getString("flutter.fc_a_$currentIndex", DEFAULT_CARDS[0].second)
                        ?: DEFAULT_CARDS[0].second

                    category = sourcePrefs.getString("fc_type_$currentIndex", null)
                        ?: sourcePrefs.getString("flutter.fc_type_$currentIndex", DEFAULT_CARDS[0].third)
                        ?: DEFAULT_CARDS[0].third
                } else {
                    val defaultCard = DEFAULT_CARDS[currentIndex % DEFAULT_CARDS.size]
                    question = defaultCard.first
                    answer = defaultCard.second
                    category = defaultCard.third
                }

                views.setTextViewText(R.id.widget_question, question)
                views.setTextViewText(R.id.widget_answer, answer)
                views.setTextViewText(R.id.widget_category, category)
                views.setTextViewText(R.id.widget_counter, "${currentIndex + 1}/$effectiveTotal")

                if (isFlipped) {
                    views.setViewVisibility(R.id.widget_answer, View.VISIBLE)
                    views.setTextViewText(R.id.btn_flip, "🙈 إخفاء الإجابة")
                } else {
                    views.setViewVisibility(R.id.widget_answer, View.GONE)
                    views.setTextViewText(R.id.btn_flip, "👁️ كشف الإجابة")
                }

                // Next Button Intent
                val nextIntent = Intent(context, HafedhWidgetProvider::class.java).apply {
                    action = ACTION_NEXT_CARD
                    putExtra("total_count", effectiveTotal)
                }
                val nextPendingIntent = PendingIntent.getBroadcast(
                    context, 101, nextIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_next, nextPendingIntent)

                // Prev Button Intent
                val prevIntent = Intent(context, HafedhWidgetProvider::class.java).apply {
                    action = ACTION_PREV_CARD
                    putExtra("total_count", effectiveTotal)
                }
                val prevPendingIntent = PendingIntent.getBroadcast(
                    context, 102, prevIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_prev, prevPendingIntent)

                // Flip Button Intent
                val flipIntent = Intent(context, HafedhWidgetProvider::class.java).apply {
                    action = ACTION_FLIP_CARD
                }
                val flipPendingIntent = PendingIntent.getBroadcast(
                    context, 103, flipIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_flip, flipPendingIntent)

                // Launch App on tap on the question area
                val appIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val appPendingIntent = PendingIntent.getActivity(
                    context, 0, appIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_content_container, appPendingIntent)

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
