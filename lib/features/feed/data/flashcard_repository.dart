import '../../../core/cache/cache_manager.dart';
import '../../../core/cache/offline_sync_service.dart';
import '../../../core/network/api_client.dart';
import '../../../models/flashcard.dart';

abstract class IFlashcardRepository {
  Future<List<FlashcardModel>> getFeedCards({String type = 'all', bool forceRefresh = false});
  Future<void> submitCardReview(String cardId, int rating, {int responseTimeMs = 2500});
  Future<void> flushOfflineReviews();
}

class FlashcardRepository implements IFlashcardRepository {
  final ApiClient _api;
  final CacheManager _cache;
  final OfflineSyncService _offlineSync;

  FlashcardRepository({
    required ApiClient api,
    required CacheManager cache,
    required OfflineSyncService offlineSync,
  })  : _api = api,
        _cache = cache,
        _offlineSync = offlineSync;

  @override
  Future<List<FlashcardModel>> getFeedCards({String type = 'all', bool forceRefresh = false}) async {
    final cacheKey = 'feed_cards_$type';

    // 1. Cache-First check if not forcing refresh
    if (!forceRefresh) {
      final cachedData = _cache.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        try {
          return cachedData.map((j) => FlashcardModel.fromJson(j as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
    }

    // 2. Fetch from Network
    try {
      String endpoint = '/flashcards?per_page=50';
      if (type != 'all') {
        endpoint += '&type=$type';
      }

      final response = await _api.get(endpoint);
      if (response != null && response['data'] != null) {
        final rawList = response['data'] as List<dynamic>;
        final cards = rawList.map((j) => FlashcardModel.fromJson(j)).toList();

        // Save to Cache with 24 hours TTL
        await _cache.put(cacheKey, cards.map((c) => c.toJson()).toList(), ttl: const Duration(hours: 24));
        return cards;
      }
    } catch (_) {
      // 3. Fallback to expired cache or curated offline deck
      final fallbackData = _cache.get(cacheKey, ignoreExpiration: true);
      if (fallbackData != null && fallbackData is List) {
        try {
          return fallbackData.map((j) => FlashcardModel.fromJson(j as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
    }

    // Default Curated Offline Deck
    final curated = _getCuratedBaccalaureateFeed();
    await _cache.put(cacheKey, curated.map((c) => c.toJson()).toList(), ttl: const Duration(hours: 48));
    return curated;
  }

  @override
  Future<void> submitCardReview(String cardId, int rating, {int responseTimeMs = 2500}) async {
    try {
      await _api.post('/study/review', body: {
        'card_id': cardId,
        'rating': rating,
        'response_time_ms': responseTimeMs,
      });
    } catch (_) {
      // Offline fallback: Queue review to be synced later
      await _offlineSync.enqueueReview(cardId, rating, responseTimeMs: responseTimeMs);
    }
  }

  @override
  Future<void> flushOfflineReviews() async {
    final pending = _offlineSync.getPendingReviews();
    if (pending.isEmpty) return;

    for (final review in pending) {
      try {
        await _api.post('/study/review', body: review.toJson());
      } catch (_) {
        return; // Network still unavailable, retry on next sync
      }
    }
    await _offlineSync.clearQueue();
  }

  List<FlashcardModel> _getCuratedBaccalaureateFeed() {
    return [
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
