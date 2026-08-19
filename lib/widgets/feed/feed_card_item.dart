import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/flashcard.dart';
import 'card_types/advice_feed_card.dart';
import 'card_types/date_feed_card.dart';
import 'card_types/flip_feed_card.dart';
import 'card_types/personality_feed_card.dart';
import 'card_types/qcm_feed_card.dart';
import 'card_types/term_feed_card.dart';
import 'feed_side_actions.dart';
import 'memorization_feedback_bar.dart';

class FeedCardItem extends StatefulWidget {
  final FlashcardModel card;
  final Function(FeedbackLevel level) onFeedback;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAudioPlay;

  const FeedCardItem({
    super.key,
    required this.card,
    required this.onFeedback,
    required this.onToggleFavorite,
    required this.onAudioPlay,
  });

  @override
  State<FeedCardItem> createState() => _FeedCardItemState();
}

class _FeedCardItemState extends State<FeedCardItem> {
  bool _isFlipped = false;
  bool _showCelebration = false;

  void _handleFeedback(FeedbackLevel level) {
    if (level == FeedbackLevel.mastered) {
      setState(() => _showCelebration = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() => _showCelebration = false);
        }
      });
    }
    widget.onFeedback(level);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background subtle ambient glow
        Positioned.fill(
          child: Container(
            color: AppColors.background,
          ),
        ),

        // 2. Central Learning Card Body
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 64, // Space for side actions
                left: 8,
                top: 54,
                bottom: 50,
              ),
              child: _buildCardByType(),
            ),
          ),
        ),

        // 3. Side Actions Column (TikTok-style floating overlay)
        Positioned(
          right: 8,
          bottom: 70,
          child: FeedSideActions(
            card: widget.card,
            isFlipped: _isFlipped,
            onFlip: () => setState(() => _isFlipped = !_isFlipped),
            onMastered: () => _handleFeedback(FeedbackLevel.mastered),
            onReviewLater: () => _handleFeedback(FeedbackLevel.notYet),
            onToggleFavorite: widget.onToggleFavorite,
            onAudioPlay: widget.onAudioPlay,
          ),
        ),

        // 4. Bottom Info Overlay (Subject, Lesson Breadcrumbs)
        Positioned(
          left: 14,
          right: 74,
          bottom: 12,
          child: _buildBottomMetaOverlay(),
        ),

        // 5. Celebration burst animation upon mastery (100%)
        if (_showCelebration)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎯 ', style: TextStyle(fontSize: 24)),
                            Text(
                              'أتقنتَها! تم تثبيت البطاقة',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardByType() {
    switch (widget.card.type) {
      case 'qcm':
        return QcmFeedCard(
          card: widget.card,
          onCorrectAnswer: () => _handleFeedback(FeedbackLevel.mastered),
          onFeedback: _handleFeedback,
        );
      case 'date':
        return DateFeedCard(
          card: widget.card,
          onFeedback: _handleFeedback,
        );
      case 'person':
        return PersonalityFeedCard(
          card: widget.card,
          onFeedback: _handleFeedback,
        );
      case 'term':
        return TermFeedCard(
          card: widget.card,
          onFeedback: _handleFeedback,
        );
      case 'advice':
        return AdviceFeedCard(
          card: widget.card,
          onFeedback: _handleFeedback,
        );
      case 'fact':
      default:
        return FlipFeedCard(
          card: widget.card,
          isFlipped: _isFlipped,
          onFlip: () => setState(() => _isFlipped = !_isFlipped),
          onFeedback: _handleFeedback,
        );
    }
  }

  Widget _buildBottomMetaOverlay() {
    final subject = widget.card.subjectName ?? 'التاريخ والجغرافيا';
    final lesson = widget.card.lessonTitle ?? 'بروز الصراع وتشكل العالم';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$subject > $lesson',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
