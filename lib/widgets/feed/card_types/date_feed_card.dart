import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class DateFeedCard extends StatefulWidget {
  final FlashcardModel card;
  final Function(FeedbackLevel level)? onFeedback;

  const DateFeedCard({super.key, required this.card, this.onFeedback});

  @override
  State<DateFeedCard> createState() => _DateFeedCardState();
}

class _DateFeedCardState extends State<DateFeedCard> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 280.h),
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.35),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_note_rounded, size: 12.sp, color: AppColors.accentGold),
                            SizedBox(width: 4.w),
                            Text(
                              'محطة وتاريخ مصيري',
                              style: TextStyle(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.history_edu_rounded, size: 16.sp, color: AppColors.accentGold),
                    ],
                  ),

                  // Date Highlight Box
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.4),
                            width: 1.2.w,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 24.sp, color: AppColors.accentGold),
                            SizedBox(height: 4.h),
                            Text(
                              widget.card.answer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        widget.card.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),

                  // Reveal Button / Expanded Explanation
                  if (!_isRevealed)
                    GestureDetector(
                      onTap: () => setState(() => _isRevealed = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_rounded, size: 14.sp, color: Colors.black),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                'كشف الأهمية التاريخية',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          if (widget.card.explanation != null)
                            Text(
                              widget.card.explanation!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.sp,
                                height: 1.3,
                              ),
                            ),
                          if (widget.card.hint != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '🧠 ${widget.card.hint!}',
                              style: TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.bold,
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
            if (_isRevealed && widget.onFeedback != null)
              MemorizationFeedbackBar(onFeedback: widget.onFeedback!),
          ],
        ),
      ),
    );
  }
}
