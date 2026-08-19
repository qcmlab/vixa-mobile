import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../../core/constants.dart';
import '../../../models/flashcard.dart';
import '../memorization_feedback_bar.dart';

class PersonalityFeedCard extends StatefulWidget {
  final FlashcardModel card;
  final Function(FeedbackLevel level)? onFeedback;

  const PersonalityFeedCard({super.key, required this.card, this.onFeedback});

  @override
  State<PersonalityFeedCard> createState() => _PersonalityFeedCardState();
}

class _PersonalityFeedCardState extends State<PersonalityFeedCard> {
  bool _isAnswerRevealed = false;

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
                  color: AppColors.accentPurple.withValues(alpha: 0.35),
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
                          color: AppColors.accentPurple.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_pin_rounded, size: 12.sp, color: AppColors.accentPurple),
                            SizedBox(width: 4.w),
                            Text(
                              'شخصية تاريخية بارزة',
                              style: TextStyle(
                                color: AppColors.accentPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.stars_rounded, size: 16.sp, color: AppColors.accentPurple),
                    ],
                  ),

                  // Avatar & Question
                  Column(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentPurple.withValues(alpha: 0.5),
                            width: 1.5.w,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 28.sp,
                          color: AppColors.accentPurple,
                        ),
                      ),
                      SizedBox(height: 10.h),
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

                  // Reveal / Answer Section
                  if (!_isAnswerRevealed)
                    GestureDetector(
                      onTap: () => setState(() => _isAnswerRevealed = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPurple, Color(0xFF6D28D9)],
                          ),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.badge_rounded, size: 14.sp, color: Colors.white),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: Text(
                                'كشف بطاقة الشخصية',
                                style: TextStyle(
                                  color: Colors.white,
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
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.accentPurple.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.card.answer,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          if (widget.card.hint != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              '🔑 ${widget.card.hint}',
                              style: TextStyle(
                                color: AppColors.accentPurple,
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
            if (_isAnswerRevealed && widget.onFeedback != null)
              MemorizationFeedbackBar(onFeedback: widget.onFeedback!),
          ],
        ),
      ),
    );
  }
}
