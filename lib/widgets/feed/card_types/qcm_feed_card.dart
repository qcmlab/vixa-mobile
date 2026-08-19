import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class QcmFeedCard extends StatefulWidget {
  final FlashcardModel card;
  final VoidCallback onCorrectAnswer;
  final Function(FeedbackLevel level)? onFeedback;

  const QcmFeedCard({
    super.key,
    required this.card,
    required this.onCorrectAnswer,
    this.onFeedback,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Question Card Container
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.quiz_rounded, size: 12.sp, color: AppColors.primary),
                            SizedBox(width: 4.w),
                            Text(
                              'سؤال تفاعلي (QCM)',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.card.hint != null && widget.card.hint!.isNotEmpty)
                        Tooltip(
                          message: widget.card.hint!,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lightbulb_rounded,
                              size: 12.sp,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.card.question,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            // 2. Interactive Options List
            ...List.generate(options.length, (index) {
              final optionText = options[index];
              final prefix = index < optionPrefixes.length ? optionPrefixes[index] : '${index + 1}';

              final isSelected = _selectedOptionIndex == index;
              final isCorrect = index == correctIdx;

              Color bgColor = AppColors.surface;
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
                padding: EdgeInsets.only(bottom: 5.h),
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrect) ? 1.5.w : 1.w),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22.w,
                          height: 22.w,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11.5.sp,
                              fontWeight: isSelected || (_hasAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(
                            trailingIcon,
                            color: isCorrect ? AppColors.primary : AppColors.ratingAgain,
                            size: 15.sp,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // 3. Explanation upon answering
            if (_hasAnswered && widget.card.explanation != null && widget.card.explanation!.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: TextStyle(fontSize: 12.sp)),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التفسير البيداغوجي:',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.card.explanation!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.sp,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Memorization Feedback Bar when answered
            if (_hasAnswered && widget.onFeedback != null)
              MemorizationFeedbackBar(onFeedback: widget.onFeedback!),
          ],
        ),
      ),
    );
  }
}
