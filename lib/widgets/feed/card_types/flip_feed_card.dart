import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onFlip,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (widget, anim) {
                  final rotate = Tween(begin: pi, end: 0.0).animate(anim);
                  return AnimatedBuilder(
                    animation: rotate,
                    child: widget,
                    builder: (context, child) {
                      final isUnder = (ValueKey(isFlipped) != child!.key);
                      var tilt = ((anim.value - 0.5).abs() - 0.5) * 0.0015;
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

            if (isFlipped && onFeedback != null)
              MemorizationFeedbackBar(onFeedback: onFeedback!),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 280.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.cardBorder, width: 1.2.w),
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
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.style_rounded, size: 12.sp, color: AppColors.accentBlue),
                    SizedBox(width: 4.w),
                    Text(
                      'بطاقة استذكار ذكية',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  card.difficulty == 'easy'
                      ? '🟢 سهل'
                      : card.difficulty == 'hard'
                          ? '🔴 متقدم'
                          : '🟡 متوسط',
                  style: TextStyle(fontSize: 9.sp, color: AppColors.textMuted),
                ),
              ),
            ],
          ),

          // Question Body
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Text(
              card.question,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),

          // Tap Hint
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 13.sp, color: AppColors.accentBlue),
                SizedBox(width: 5.w),
                Text(
                  'المس لقلب البطاقة وكشف الإجابة',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
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
      constraints: BoxConstraints(minHeight: 280.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 12.r,
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
                  color: AppColors.primaryDark.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12.sp, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      'الإجابة النموذجية للبكالوريا',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified_rounded, size: 15.sp, color: AppColors.primary),
            ],
          ),

          // Answer Content
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              children: [
                Text(
                  card.answer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                if (card.explanation != null && card.explanation!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            card.explanation!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.sp,
                              height: 1.3,
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

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
