import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class FlipFeedCard extends StatelessWidget {
  final FlashcardModel card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final Function(FeedbackLevel level)? onFeedback;

  const FlipFeedCard({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onFlip,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  transitionBuilder: (widget, anim) {
                    final rotate = Tween(begin: pi, end: 0.0).animate(anim);
                    return AnimatedBuilder(
                      animation: rotate,
                      child: widget,
                      builder: (context, child) {
                        final isUnder = (ValueKey(isFlipped) != child!.key);
                        var tilt = ((anim.value - 0.5).abs() - 0.5) * 0.002;
                        tilt *= isUnder ? -1.0 : 1.0;
                        final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                        return Transform(
                          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                    );
                  },
                  child: isFlipped
                      ? _buildBackCard(key: const ValueKey(true))
                      : _buildFrontCard(key: const ValueKey(false)),
                ),
              ),

              // Feedback Bar when flipped to the answer
              if (isFlipped && onFeedback != null)
                MemorizationFeedbackBar(onFeedback: onFeedback!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceLight.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.style_rounded, size: 14, color: AppColors.accentBlue),
                    SizedBox(width: 6),
                    Text(
                      'بطاقة استذكار ذكية',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.difficulty == 'easy'
                      ? '🟢 سهل'
                      : card.difficulty == 'hard'
                          ? '🔴 متقدم'
                          : '🟡 متوسط',
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ],
          ),

          // Question Body
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Text(
              card.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          ),

          // Tap Hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 16, color: AppColors.accentBlue),
                SizedBox(width: 8),
                Text(
                  'المس لقلب البطاقة وكشف الإجابة',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 340),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceLight,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'الإجابة النموذجية للبكالوريا',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
            ],
          ),

          // Answer Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  card.answer,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
                if (card.explanation != null && card.explanation!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.explanation!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
