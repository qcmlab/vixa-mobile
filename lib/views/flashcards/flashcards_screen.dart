import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/content_provider.dart';
import '../../providers/flashcard_browser_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/flashcard_view.dart';
import '../study/study_session_screen.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _flippedCardIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentProvider.notifier).fetchSubjects();
      ref.read(flashcardBrowserProvider.notifier).fetchCards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startStudySession() async {
    final studyNotifier = ref.read(studyProvider.notifier);
    await studyNotifier.fetchTodayReviews();

    if (!mounted) return;

    final deck = ref.read(studyProvider).deck;
    if (deck == null || deck.dueCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 أحسنت! لا توجد بطاقات مستحقة للمراجعة حالياً.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudySessionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(flashcardBrowserProvider);
    final browserNotifier = ref.read(flashcardBrowserProvider.notifier);
    final subjects = ref.watch(contentProvider).subjects;

    final typeFilters = [
      {'key': 'all', 'label': '🌟 الكل'},
      {'key': 'date', 'label': '📅 تواريخ'},
      {'key': 'person', 'label': '👤 شخصيات'},
      {'key': 'term', 'label': '📖 مصطلحات'},
      {'key': 'fact', 'label': '💡 حقائق'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'بنك بطاقات الحفظ',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${browserState.totalCount} بطاقة',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () => browserNotifier.fetchCards(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث في الأسئلة، الإجابات، والمفاهيم...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            browserNotifier.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (val) => browserNotifier.setSearchQuery(val),
              ),
            ),

            // 2. Type Filter Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: typeFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tf = typeFilters[index];
                  final isSelected = browserState.selectedType == tf['key'];

                  return ChoiceChip(
                    label: Text(
                      tf['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => browserNotifier.setTypeFilter(tf['key']!),
                  );
                },
              ),
            ),

            // 3. Subject Selector Tabs
            if (subjects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  children: [
                    _buildSubjectPill(
                      label: 'جميع المواد',
                      isSelected: browserState.selectedSubjectId == null,
                      onTap: () => browserNotifier.setSubjectFilter(null),
                    ),
                    const SizedBox(width: 8),
                    ...subjects.map((sub) {
                      final isSelected = browserState.selectedSubjectId == sub.id;
                      final shortName = sub.name.contains('التاريخ') ? 'التاريخ' : 'الجغرافيا';
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildSubjectPill(
                          label: shortName,
                          isSelected: isSelected,
                          onTap: () => browserNotifier.setSubjectFilter(sub.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            // 4. Cards List or Empty State
            Expanded(
              child: browserState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : browserState.cards.isEmpty
                      ? _buildEmptyState(browserNotifier)
                      : RefreshIndicator(
                          onRefresh: () => browserNotifier.fetchCards(),
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(18),
                            itemCount: browserState.cards.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final card = browserState.cards[index];
                              final isFlipped = _flippedCardIds.contains(card.id);

                              return FlashcardView(
                                card: card,
                                isFlipped: isFlipped,
                                onFlip: () {
                                  setState(() {
                                    if (isFlipped) {
                                      _flippedCardIds.remove(card.id);
                                    } else {
                                      _flippedCardIds.add(card.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startStudySession,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.psychology_rounded),
        label: const Text(
          'جلسة حفظ ذكية (SM-2)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSubjectPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(FlashcardBrowserNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'لم يتم العثور على بطاقات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'جرب تغيير معايير البحث أو اختيار نوع بطاقة آخر.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                notifier.setTypeFilter('all');
                notifier.setSubjectFilter(null);
                notifier.setSearchQuery('');
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('إعادة ضبط الفلاتر'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
