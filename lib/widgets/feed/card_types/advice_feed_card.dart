import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
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
                  color: AppColors.accentRose.withValues(alpha: 0.35),
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
                          color: AppColors.accentRose.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.psychology_rounded, size: 12.sp, color: AppColors.accentRose),
                            SizedBox(width: 4.w),
                            Text(
                              'كبسولة الذاكرة الفائقة',
                              style: TextStyle(
                                color: AppColors.accentRose,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.bolt_rounded, size: 18.sp, color: AppColors.accentRose),
                    ],
                  ),

                  // Brain Icon & Advice Content
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentRose.withValues(alpha: 0.4),
                            width: 1.2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          size: 26.sp,
                          color: AppColors.accentRose,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        card.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          card.answer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFFECDD3),
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),

            if (onFeedback != null)
              MemorizationFeedbackBar(onFeedback: onFeedback!),
          ],
        ),
      ),
    );
  }
}
