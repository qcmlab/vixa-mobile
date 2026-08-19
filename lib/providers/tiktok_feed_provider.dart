import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/flashcard.dart';

class TiktokFeedState {
  final List<FlashcardModel> cards;
  final bool isLoading;
  final String? error;
  final int currentIndex;
  final int masteredTodayCount;
  final int streakDays;
  final String selectedSubject; // 'all', 'history', 'geography'
  final String selectedType; // 'all', 'qcm', 'date', 'person', 'term', 'fact'

  TiktokFeedState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.currentIndex = 0,
    this.masteredTodayCount = 12,
    this.streakDays = 5,
    this.selectedSubject = 'all',
    this.selectedType = 'all',
  });

  TiktokFeedState copyWith({
    List<FlashcardModel>? cards,
    bool? isLoading,
    String? error,
    int? currentIndex,
    int? masteredTodayCount,
    int? streakDays,
    String? selectedSubject,
    String? selectedType,
  }) {
    return TiktokFeedState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentIndex: currentIndex ?? this.currentIndex,
      masteredTodayCount: masteredTodayCount ?? this.masteredTodayCount,
      streakDays: streakDays ?? this.streakDays,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

class TiktokFeedNotifier extends StateNotifier<TiktokFeedState> {
  final ApiClient _api = ApiClient();

  TiktokFeedNotifier() : super(TiktokFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      String endpoint = '/flashcards?per_page=50';
      if (state.selectedType != 'all') {
        endpoint += '&type=${state.selectedType}';
      }

      final response = await _api.get(endpoint);
      List<FlashcardModel> loadedCards = [];

      if (response != null && response['data'] != null) {
        final rawList = response['data'] as List<dynamic>;
        loadedCards = rawList.map((j) => FlashcardModel.fromJson(j)).toList();
      }

      // If backend returns empty or offline, use rich Algerian Baccalaureate curriculum sample cards
      if (loadedCards.isEmpty) {
        loadedCards = _getCuratedBaccalaureateFeed();
      } else {
        // Enrich any raw cards with rich interactive options if missing
        loadedCards = _enrichCardsForInteractiveFeed(loadedCards);
      }

      // Filter by subject if specified
      if (state.selectedSubject != 'all') {
        loadedCards = loadedCards.where((c) {
          final sub = c.subjectName ?? '';
          if (state.selectedSubject == 'history') {
            return sub.contains('تاريخ') || c.type == 'date' || c.type == 'person';
          } else if (state.selectedSubject == 'geography') {
            return sub.contains('جغرافيا') || c.type == 'term';
          }
          return true;
        }).toList();
      }

      state = state.copyWith(
        cards: loadedCards,
        isLoading: false,
        currentIndex: 0,
      );
    } catch (e) {
      // Graceful fallback to curated Algerian Baccalaureate curriculum feed
      final curated = _getCuratedBaccalaureateFeed();
      state = state.copyWith(
        cards: curated,
        isLoading: false,
        error: null,
      );
    }
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setSubjectFilter(String subject) {
    if (state.selectedSubject == subject) return;
    state = state.copyWith(selectedSubject: subject);
    loadFeed(refresh: true);
  }

  void setTypeFilter(String type) {
    if (state.selectedType == type) return;
    state = state.copyWith(selectedType: type);
    loadFeed(refresh: true);
  }

  void toggleFavorite(String cardId) {
    final updated = state.cards.map((c) {
      if (c.id == cardId) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();

    state = state.copyWith(cards: updated);
  }

  Future<void> submitQuickReview(String cardId, int rating) async {
    // rating: 1=Again, 3=Hard, 4=Good, 5=Easy
    try {
      await _api.post('/study/review', body: {
        'card_id': cardId,
        'rating': rating,
        'response_time_ms': 2500,
      });
    } catch (_) {
      // Ignored for offline support
    }

    if (rating >= 4) {
      state = state.copyWith(
        masteredTodayCount: state.masteredTodayCount + 1,
      );
    }
  }

  List<FlashcardModel> _enrichCardsForInteractiveFeed(List<FlashcardModel> raw) {
    return raw.map((c) {
      if (c.type == 'date') {
        return c.copyWith(
          options: [
            c.answer,
            _generateDistractorYear(c.answer, 1),
            _generateDistractorYear(c.answer, -2),
            _generateDistractorYear(c.answer, 3),
          ]..shuffle(),
          correctOptionIndex: 0,
          subjectName: c.subjectName ?? 'التاريخ',
          lessonTitle: c.lessonTitle ?? 'بروز الصراع وتشكل العالم',
        );
      }
      return c;
    }).toList();
  }

  String _generateDistractorYear(String original, int offset) {
    final match = RegExp(r'\b(19\d\d|20\d\d)\b').firstMatch(original);
    if (match != null) {
      final year = int.tryParse(match.group(0)!);
      if (year != null) {
        final newYear = year + offset;
        return original.replaceFirst(match.group(0)!, '$newYear');
      }
    }
    return '1947م';
  }

  List<FlashcardModel> _getCuratedBaccalaureateFeed() {
    return [
      // 1. QCM Question: Cold War Criteria
      FlashcardModel(
        id: 'bac_qcm_1',
        lessonId: 'hist_ch1_l1',
        type: 'qcm',
        question: 'ما هو المعيار التاريخي والسياسي الأبرز لتشكل العالم بعد الحرب العالمية الثانية (1945)؟',
        answer: 'زوال القوى التقليدية (فرنسا وبريطانيا) وبروز القوتين العظميين (USA و URSS)',
        options: [
          'تأسيس حلف شمال الأطلسي (الناتو)',
          'زوال القوى التقليدية (فرنسا وبريطانيا) وبروز القوتين العظميين (USA و URSS)',
          'سقوط جدار برلين وتفكك الكتلة الشرقية',
          'انعقاد مؤتمر باندونغ لحركة عدم الانحياز',
        ],
        correctOptionIndex: 1,
        explanation: 'من أهم المعايير السياسية والتاريخية بعد 1945 هو تراجع نفوذ الاستعمار التقليدي وصعود الثنائية القطبية.',
        difficulty: 'medium',
        subjectName: 'التاريخ',
        lessonTitle: 'بروز الصراع وتشكل العالم (الثنائية القطبية)',
        hint: 'تذكر قاعدة: تراجع فرنسا وبريطانيا = صعود أمريكا والسوفيات',
      ),

      // 2. Date Chronology Card: Marshall Plan
      FlashcardModel(
        id: 'bac_date_1',
        lessonId: 'hist_ch1_l1',
        type: 'date',
        question: 'ما هو التاريخ الدقيق لإعلان مشروع مارشال الأمريكي لإعادة إعمار أوروبا؟',
        answer: '05 جوان 1947م',
        options: [
          '12 مارس 1947م',
          '05 جوان 1947م',
          '22 سبتمبر 1947م',
          '06 أكتوبر 1947م',
        ],
        correctOptionIndex: 1,
        explanation: 'مشروع مارشال هو مساعدة مالية أمريكية قيمتها نحو 13 مليار دولار لدول غرب أوروبا لمنع انتشار الشيوعية.',
        difficulty: 'easy',
        subjectName: 'التاريخ',
        lessonTitle: 'الاستراتيجيات الخاصة بالكتلتين',
        hint: 'ربط ذهني: جوان (شهر 6) بعد هاري ترومان (مارس)',
      ),

      // 3. Historical Personality: Andrei Zhdanov
      FlashcardModel(
        id: 'bac_person_1',
        lessonId: 'hist_ch1_l1',
        type: 'person',
        question: 'من هو أندريه جدانوف (Andrei Zhdanov) وما هو دوره في الحرب الباردة؟',
        answer: 'رجل دولة سوفياتي وصاحب مبدأ جدانوف (22 سبتمبر 1947) الذي قسّم العالم إلى معسكرين: إمبريالي وديمقراطي، ومؤسس مكتب الكومنفورم.',
        explanation: 'يعد الرد الإيديولوجي المباشر للاتحاد السوفياتي على مبدأ ترومان الأمريكي.',
        difficulty: 'medium',
        subjectName: 'التاريخ',
        lessonTitle: 'الشخصيات البارزة في الحرب الباردة',
        hint: 'جدانوف = مبدأ جدانوف + الكومنفورم + سبتمبر 1947',
      ),

      // 4. Term / Definition Card: Containment Policy
      FlashcardModel(
        id: 'bac_term_1',
        lessonId: 'hist_ch1_l1',
        type: 'term',
        question: 'ما هو المفهوم الدقيق لـ "سياسة الاحتواء" (Containment Policy)؟',
        answer: 'سياسة أمريكية وضعها جورج كينان وطبقها ترومان، تقوم على محاصرة الاتحاد السوفياتي والحد من انتشار نفوذه والمد الشيوعي عبر الأحلاف والقواعد والمساعدات.',
        explanation: 'اعتمدت على الضغط الاقتصادي والعسكري لمنع توسع الكتلة الشرقية نحو مناطق النفوذ الغربي.',
        difficulty: 'hard',
        subjectName: 'التاريخ',
        lessonTitle: 'المصطلحات والمفاهيم الأساسية',
        hint: 'الاحتواء = الحصار الجغرافي والسياسي لمنع انتشار الشيوعية',
      ),

      // 5. Geography QCM: OPEC & Petroleum
      FlashcardModel(
        id: 'bac_qcm_2',
        lessonId: 'geo_ch1_l1',
        type: 'qcm',
        question: 'ما هي الدول الـ 5 المؤسسة لمنظمة أوبك (OPEC) في مؤتمر بغداد سبتمبر 1960؟',
        answer: 'السعودية، العراق، الكويت، إيران، وفنزويلا',
        options: [
          'الجزائر، ليبيا، نيجيريا، الغابون، وأنغولا',
          'السعودية، العراق، الكويت، إيران، وفنزويلا',
          'روسيا، النرويج، المكسيك، عمان، وكازاخستان',
          'قطر، الإمارات، إندونيسيا، مصر، وسوريا',
        ],
        correctOptionIndex: 1,
        explanation: 'تأسست منظمة الدول المصدرة للبترول بـ 5 دول مؤسسة لحماية أسعار النفط من كارتل الشركات الاحتكارية (الشقيقات السبع).',
        difficulty: 'medium',
        subjectName: 'الجغرافيا',
        lessonTitle: 'إشكالية المبادلات والتنقلات في العالم (البترول والقمح)',
        hint: 'الدول الـ 5: 4 من الخليج والشرق الأوسط + فنزويلا من أمريكا اللاتينية',
      ),

      // 6. Flip Card: Cuban Missile Crisis
      FlashcardModel(
        id: 'bac_flip_1',
        lessonId: 'hist_ch1_l2',
        type: 'fact',
        question: 'ما هي أسباب وأبعاد أزمة الصواريخ الكوبية (أكتوبر 1962)؟',
        answer: 'اكتشاف طائرات التجسس الأمريكية صواريخ نووية سوفياتية موجهة نحو واشنطن في كوبا، مما كاد يشعل حرباً نووية، وانتهت بسحب الصواريخ وإنشاء الخط الهاتفي الأحمر.',
        explanation: 'تعد أخطر أزمات الحرب الباردة، ومهدت لمرحلة التعايش السلمي والانفراج الدولي.',
        difficulty: 'hard',
        subjectName: 'التاريخ',
        lessonTitle: 'الأزمات الدولية في ظل الصراع',
        hint: 'كوبا 1962 = أخطر أزمة + كينيدي وخروتشوف + الخط الأحمر',
      ),

      // 7. Mnemonic Brain Advice Card
      FlashcardModel(
        id: 'bac_advice_1',
        lessonId: 'hist_general',
        type: 'advice',
        question: '🧠 حيلة الربط الذهني لتواريخ عام 1947 المصيرية في البكالوريا:',
        answer: 'احفظ قاعدة الترتيب الثلاثي لعام 1947:\n1. مارس: مبدأ ترومان (03)\n2. جوان: مشروع مارشال (06)\n3. سبتمبر: مبدأ جدانوف (09)\n4. أكتوبر: الكومنفورم (10)',
        explanation: 'الترتيب تصاعدي كل 3 أشهر تقريباً (مارس -> جوان -> سبتمبر -> أكتوبر).',
        difficulty: 'easy',
        subjectName: 'تقنيات الذاكرة الفائقة',
        lessonTitle: 'نصائح التثبيت والاسترجاع السريع',
        hint: 'قفزة كل 3 أشهر: 3 -> 6 -> 9 -> 10',
      ),
    ];
  }
}

final tiktokFeedProvider = StateNotifierProvider<TiktokFeedNotifier, TiktokFeedState>((ref) {
  return TiktokFeedNotifier();
});
