import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/tiktok_feed_provider.dart';
import '../../widgets/feed/feed_card_item.dart';
import '../../widgets/feed/feed_top_bar.dart';
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
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Auto-advance smoothly to next card after brief delay
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted && _pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
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
    final isLoading = ref.watch(tiktokFeedProvider.select((s) => s.isLoading));
    final cards = ref.watch(tiktokFeedProvider.select((s) => s.cards));
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Ultra-Smooth Full-Screen Vertical Paging Feed
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (cards.isEmpty)
            _buildEmptyFeed(feedNotifier)
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              allowImplicitScrolling: true,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return RepaintBoundary(
                  key: ValueKey(card.id),
                  child: FeedCardItem(
                    card: card,
                    onFeedback: (level) => _handleFeedbackAction(card.id, level, index),
                    onToggleFavorite: () {
                      feedNotifier.toggleFavorite(card.id);
                    },
                    onAudioPlay: () {
                      _showAudioSnackbar('🔊 جاري قراءة نص البطاقة صوتياً...');
                    },
                  ),
                );
              },
            ),

          // 2. Isolated Floating Top Header Overlay
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FeedTopBar(),
          ),
        ],
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
