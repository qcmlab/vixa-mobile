import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';

class QcmFeedCard extends StatefulWidget {
  final FlashcardModel card;
  final VoidCallback onCorrectAnswer;

  const QcmFeedCard({
    super.key,
    required this.card,
    required this.onCorrectAnswer,
  });

  @override
  State<QcmFeedCard> createState() => _QcmFeedCardState();
}

class _QcmFeedCardState extends State<QcmFeedCard> {
  int? _selectedOptionIndex;
  bool _hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final options = widget.card.options ?? [
      widget.card.answer,
      'الخيار البديل الأول',
      'الخيار البديل الثاني',
      'الخيار البديل الثالث',
    ];
    final correctIdx = widget.card.correctOptionIndex ?? 0;

    final optionPrefixes = ['أ', 'ب', 'ج', 'د'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Question Card Container
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surfaceLight.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_rounded, size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'سؤال تفاعلي (QCM)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.card.hint != null && widget.card.hint!.isNotEmpty)
                      Tooltip(
                        message: widget.card.hint!,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lightbulb_rounded,
                            size: 14,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.card.question,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Interactive Options List
          ...List.generate(options.length, (index) {
            final optionText = options[index];
            final prefix = index < optionPrefixes.length ? optionPrefixes[index] : '${index + 1}';

            final isSelected = _selectedOptionIndex == index;
            final isCorrect = index == correctIdx;

            Color bgColor = AppColors.surface.withValues(alpha: 0.85);
            Color borderColor = AppColors.cardBorder;
            Color textColor = AppColors.textPrimary;
            IconData? trailingIcon;

            if (_hasAnswered) {
              if (isCorrect) {
                bgColor = AppColors.primary.withValues(alpha: 0.2);
                borderColor = AppColors.primary;
                textColor = AppColors.primaryLight;
                trailingIcon = Icons.check_circle_rounded;
              } else if (isSelected && !isCorrect) {
                bgColor = AppColors.ratingAgain.withValues(alpha: 0.2);
                borderColor = AppColors.ratingAgain;
                textColor = const Color(0xFFFCA5A5);
                trailingIcon = Icons.cancel_rounded;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _hasAnswered
                    ? null
                    : () {
                        setState(() {
                          _selectedOptionIndex = index;
                          _hasAnswered = true;
                        });
                        if (index == correctIdx) {
                          widget.onCorrectAnswer();
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrect) ? 1.8 : 1.2),
                    boxShadow: [
                      if (_hasAnswered && isCorrect)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _hasAnswered && isCorrect
                              ? AppColors.primary
                              : _hasAnswered && isSelected
                                  ? AppColors.ratingAgain
                                  : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            prefix,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: isSelected || (_hasAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(
                          trailingIcon,
                          color: isCorrect ? AppColors.primary : AppColors.ratingAgain,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 3. Explanation Dropdown upon answering
          if (_hasAnswered && widget.card.explanation != null && widget.card.explanation!.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التفسير البيداغوجي المعتمد:',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.card.explanation!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
