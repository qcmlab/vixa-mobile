import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class TermFeedCard extends StatefulWidget {
  final FlashcardModel card;
  final Function(FeedbackLevel level)? onFeedback;

  const TermFeedCard({super.key, required this.card, this.onFeedback});

  @override
  State<TermFeedCard> createState() => _TermFeedCardState();
}

class _TermFeedCardState extends State<TermFeedCard> {
  bool _isAnswerRevealed = false;

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
                      const Color(0xFF0F2E28), // Emerald dark tint
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.accentTeal.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentTeal.withValues(alpha: 0.12),
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
                            color: AppColors.accentTeal.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 14, color: AppColors.accentTeal),
                              SizedBox(width: 6),
                              Text(
                                'مصطلح ومفهوم أساسي',
                                style: TextStyle(
                                  color: AppColors.accentTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.bookmark_added_rounded, size: 20, color: AppColors.accentTeal),
                      ],
                    ),

                    // Question / Term Prompt
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        widget.card.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Reveal / Definition Area
                    if (!_isAnswerRevealed)
                      GestureDetector(
                        onTap: () => setState(() => _isAnswerRevealed = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentTeal, Color(0xFF0D9488)],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentTeal.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_stories_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'إظهار التعريف والكلمات المفتاحية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.accentTeal.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.card.answer,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                              ),
                            ),
                            if (widget.card.hint != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '📌 كلمات مفتاحية: ${widget.card.hint}',
                                  style: const TextStyle(
                                    color: AppColors.accentTeal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Feedback Bar when revealed
              if (_isAnswerRevealed && widget.onFeedback != null)
                MemorizationFeedbackBar(onFeedback: widget.onFeedback!),
            ],
          ),
        ),
      ),
    );
  }
}
