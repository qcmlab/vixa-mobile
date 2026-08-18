import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/flashcard_view.dart';

class StudySessionScreen extends ConsumerWidget {
  const StudySessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final study = ref.watch(studyProvider);
    final studyNotifier = ref.read(studyProvider.notifier);

    if (study.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (study.isSessionCompleted) {
      return _buildCompletedScreen(context, study);
    }

    final currentItem = study.currentCardItem;
    if (currentItem == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text(
            'لا توجد بطاقات للمراجعة حالياً',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final currentCard = currentItem.card;
    final progress = (study.currentIndex + 1) / study.totalCardsInSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'بطاقة ${study.currentIndex + 1} من ${study.totalCardsInSession}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // Interactive 3D Flip Card
              Expanded(
                child: Center(
                  child: FlashcardView(
                    card: currentCard,
                    isFlipped: study.isCardFlipped,
                    onFlip: studyNotifier.flipCard,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Action Section
              if (!study.isCardFlipped)
                CustomButton(
                  text: 'إظهار الإجابة',
                  icon: Icons.visibility_rounded,
                  backgroundColor: AppColors.surfaceLight,
                  textColor: AppColors.primary,
                  onPressed: studyNotifier.flipCard,
                )
              else
                // 4 SM-2 Spaced Repetition Buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildRatingButton(
                            label: 'أعد (Again)',
                            timeHint: '15 دقيقة',
                            color: AppColors.ratingAgain,
                            onTap: () => studyNotifier.submitRating('again'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRatingButton(
                            label: 'صعب (Hard)',
                            timeHint: '1 يوم',
                            color: AppColors.ratingHard,
                            onTap: () => studyNotifier.submitRating('hard'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRatingButton(
                            label: 'جيد (Good)',
                            timeHint: '3 أيام',
                            color: AppColors.ratingGood,
                            onTap: () => studyNotifier.submitRating('good'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildRatingButton(
                            label: 'سهل (Easy)',
                            timeHint: '7 أيام',
                            color: AppColors.ratingEasy,
                            onTap: () => studyNotifier.submitRating('easy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required String timeHint,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeHint,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedScreen(BuildContext context, StudyState study) {
    final accuracy = study.sessionReviewedCount > 0
        ? ((study.sessionCorrectCount / study.sessionReviewedCount) * 100).toStringAsFixed(0)
        : '100';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'اكتملت جلسة المراجعة بنجاح!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'تمت جدولة البطاقات تلقائياً وفق خوارزمية التكرار المتباعد.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Summary Stats Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${study.sessionReviewedCount}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('بطاقات مراجعة', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    Container(width: 1, height: 36, color: AppColors.cardBorder),
                    Column(
                      children: [
                        Text(
                          '$accuracy%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('دقة التذكر', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              if (study.sessionUnlockedAchievements.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.military_tech_rounded, color: AppColors.accentGold),
                      const SizedBox(width: 8),
                      Text(
                        'مبروك! فتحت ${study.sessionUnlockedAchievements.length} شارة جديدة 🏆',
                        style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),
              CustomButton(
                text: 'العودة للرئيسية',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
