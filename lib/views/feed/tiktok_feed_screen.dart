import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/tiktok_feed_provider.dart';
import '../../widgets/feed/feed_card_item.dart';
import '../../widgets/feed/memorization_feedback_bar.dart';

class TiktokFeedScreen extends ConsumerStatefulWidget {
  const TiktokFeedScreen({super.key});

  @override
  ConsumerState<TiktokFeedScreen> createState() => _TiktokFeedScreenState();
}

class _TiktokFeedScreenState extends ConsumerState<TiktokFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleFeedbackAction(String cardId, FeedbackLevel level, int currentIndex) {
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);
    feedNotifier.submitFeedback(cardId, level);

    String message = '';
    Color bgColor = AppColors.primary;

    switch (level) {
      case FeedbackLevel.notYet:
        message = '🔁 لم تحفظها بعد (0%) - تمت إضافتها للتكرار القريب!';
        bgColor = AppColors.ratingAgain;
        break;
      case FeedbackLevel.partially:
        message = '⚡ استيعاب جزئي (50%) - تمت جدولة التثبيت';
        bgColor = AppColors.accentGold;
        break;
      case FeedbackLevel.mastered:
        message = '🎉 ممتاز! تم إتقان البطاقة بنجاح (100%)';
        bgColor = AppColors.primary;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(milliseconds: 1400),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Auto-advance smoothly to next card after brief delay for smooth addictive learning
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _showAudioSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(tiktokFeedProvider);
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Full-Screen Vertical Paging Feed
          if (feedState.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (feedState.cards.isEmpty)
            _buildEmptyFeed(feedNotifier)
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: feedState.cards.length,
              onPageChanged: (index) {
                feedNotifier.setCurrentIndex(index);
              },
              itemBuilder: (context, index) {
                final card = feedState.cards[index];
                return FeedCardItem(
                  card: card,
                  onFeedback: (level) => _handleFeedbackAction(card.id, level, index),
                  onToggleFavorite: () {
                    feedNotifier.toggleFavorite(card.id);
                  },
                  onAudioPlay: () {
                    _showAudioSnackbar('🔊 جاري قراءة نص البطاقة صوتياً...');
                  },
                );
              },
            ),

          // 2. Floating Top Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopHeaderOverlay(feedState, feedNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderOverlay(TiktokFeedState feedState, TiktokFeedNotifier feedNotifier) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Streak + Daily Goal Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${feedState.streakDays} أيام مستمرة',
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Daily Mastered Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${feedState.masteredTodayCount} بطاقة أتقنتها',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Subject Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubjectTab(
                label: '🎲 عشوائي (الكل)',
                keyName: 'all',
                isSelected: feedState.selectedSubject == 'all',
                onTap: () => feedNotifier.setSubjectFilter('all'),
              ),
              const SizedBox(width: 8),
              _buildSubjectTab(
                label: '📜 التاريخ',
                keyName: 'history',
                isSelected: feedState.selectedSubject == 'history',
                onTap: () => feedNotifier.setSubjectFilter('history'),
              ),
              const SizedBox(width: 8),
              _buildSubjectTab(
                label: '🌍 الجغرافيا',
                keyName: 'geography',
                isSelected: feedState.selectedSubject == 'geography',
                onTap: () => feedNotifier.setSubjectFilter('geography'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTab({
    required String label,
    required String keyName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFeed(TiktokFeedNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shuffle_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'لا توجد بطاقات في هذا التصنيف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر تصنيفاً آخر أو اضغط لتحديث التلقيم العشوائي.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => notifier.loadFeed(forceRefresh: true),
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('تلقيم عشوائي جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
