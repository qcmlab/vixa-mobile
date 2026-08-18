package dz.hafedh.hafedh_mobile

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Random

class LockScreenFlashcardActivity : Activity() {

    private val defaultCards = listOf(
        Triple("ما هو تاريخ اندلاع الثورة التحريرية الجزائرية الكبرى؟", "01 نوفمبر 1954م على الساعة الصفر بعمليات عسكرية شملت كامل التراب الوطني.", "📅 تاريخ مهم"),
        Triple("ما هو مؤتمر الصومام وما تاريخ انعقاده؟", "20 أوت 1956م، مؤتمر تاريخي بجبال الصومام لإعادة تنظيم وهيكلة الثورة سياسياً وعسكرياً.", "📅 تاريخ مهم"),
        Triple("من هو مصطفى بن بولعيد؟", "أحد مفجري الثورة التحريرية وقائد المنطقة الأولى (الأوراس)، لُقب بـ 'أب الثورة'.", "👤 شخصية تاريخية"),
        Triple("ما هو تعريف منظمة الأوبك (OPEC)؟", "منظمة الدول المصدرة للبترول، تأسست سنة 1960 في بغداد لتوحيد السياسات البترولية وضمان استقرار الأسواق.", "📖 مصطلح ومفهوم"),
        Triple("ما هو تاريخ استرجاع السيادة الوطنية والاستقلال؟", "05 جويلية 1962م بعد استفتاء تقرير المصير بنسبة ساحقة.", "📅 تاريخ مهم")
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Configure Lock Screen Window Visibility Flags
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            keyguardManager?.requestDismissKeyguard(this, null)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        setContentView(R.layout.activity_lockscreen_flashcard)

        // Load Card Data
        val widgetPrefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        var totalCount = widgetPrefs.getInt("fc_count", 0)
        var sourcePrefs = widgetPrefs
        if (totalCount == 0) {
            totalCount = flutterPrefs.getInt("flutter.fc_count", 0)
            if (totalCount > 0) sourcePrefs = flutterPrefs
        }

        val question: String
        val answer: String
        val category: String

        if (totalCount > 0) {
            val randomIndex = Random().nextInt(totalCount)
            question = sourcePrefs.getString("fc_q_$randomIndex", defaultCards[0].first) ?: defaultCards[0].first
            answer = sourcePrefs.getString("fc_a_$randomIndex", defaultCards[0].second) ?: defaultCards[0].second
            category = sourcePrefs.getString("fc_type_$randomIndex", defaultCards[0].third) ?: defaultCards[0].third
        } else {
            val randomCard = defaultCards[Random().nextInt(defaultCards.size)]
            question = randomCard.first
            answer = randomCard.second
            category = randomCard.third
        }

        // View Bindings
        val tvQuestion = findViewById<TextView>(R.id.lock_question)
        val tvAnswer = findViewById<TextView>(R.id.lock_answer)
        val tvCategory = findViewById<TextView>(R.id.lock_category)
        val btnReveal = findViewById<Button>(R.id.btn_lock_reveal)
        val layoutRatings = findViewById<LinearLayout>(R.id.layout_lock_ratings)
        val btnAgain = findViewById<Button>(R.id.btn_lock_again)
        val btnGood = findViewById<Button>(R.id.btn_lock_good)
        val btnDismiss = findViewById<TextView>(R.id.btn_dismiss)

        tvQuestion.text = question
        tvAnswer.text = answer
        tvCategory.text = category

        // Reveal Answer
        btnReveal.setOnClickListener {
            tvAnswer.visibility = View.VISIBLE
            btnReveal.visibility = View.GONE
            layoutRatings.visibility = View.VISIBLE
        }

        // Ratings & Dismiss
        btnAgain.setOnClickListener { dismissLockScreen() }
        btnGood.setOnClickListener { dismissLockScreen() }
        btnDismiss.setOnClickListener { dismissLockScreen() }
    }

    private fun dismissLockScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
            finish()
        }
    }
}
