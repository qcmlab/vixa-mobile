import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class AdviceFeedCard extends StatelessWidget {
  final FlashcardModel card;
  final Function(FeedbackLevel level)? onFeedback;

  const AdviceFeedCard({super.key, required this.card, this.onFeedback});

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
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 340),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      const Color(0xFF3B1D28), // Rose gold dark tint
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.accentRose.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentRose.withValues(alpha: 0.12),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
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
                            color: AppColors.accentRose.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.psychology_rounded, size: 14, color: AppColors.accentRose),
                              SizedBox(width: 6),
                              Text(
                                'كبسولة الذاكرة الفائقة',
                                style: TextStyle(
                                  color: AppColors.accentRose,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.bolt_rounded, size: 22, color: AppColors.accentRose),
                      ],
                    ),

                    // Brain Icon & Advice Content
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accentRose.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentRose.withValues(alpha: 0.2),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            size: 32,
                            color: AppColors.accentRose,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            card.answer,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFECDD3),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              if (onFeedback != null)
                MemorizationFeedbackBar(onFeedback: onFeedback!),
            ],
          ),
        ),
      ),
    );
  }
}
