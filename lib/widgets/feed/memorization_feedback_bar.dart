import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../providers/language_provider.dart';

enum FeedbackLevel {
  notYet, // 0%
  partially, // 50%
  mastered, // 100%
}

class MemorizationFeedbackBar extends ConsumerStatefulWidget {
  final Function(FeedbackLevel level) onFeedback;

  const MemorizationFeedbackBar({
    super.key,
    required this.onFeedback,
  });

  @override
  ConsumerState<MemorizationFeedbackBar> createState() => _MemorizationFeedbackBarState();
}

class _MemorizationFeedbackBarState extends ConsumerState<MemorizationFeedbackBar> {
  FeedbackLevel? _selectedLevel;

  void _selectLevel(FeedbackLevel level) {
    setState(() => _selectedLevel = level);
    widget.onFeedback(level);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(languageProvider).t;

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t('feedback.question'),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              // 1. Not Yet (0%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.notYet,
                  label: t('feedback.not_yet'),
                  percent: '0%',
                  icon: Icons.close_rounded,
                  color: AppColors.ratingAgain,
                ),
              ),
              SizedBox(width: 6.w),

              // 2. Partially (50%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.partially,
                  label: t('feedback.partially'),
                  percent: '50%',
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentGold,
                ),
              ),
              SizedBox(width: 6.w),

              // 3. Mastered (100%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.mastered,
                  label: t('feedback.mastered'),
                  percent: '100%',
                  icon: Icons.check_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required FeedbackLevel level,
    required String label,
    required String percent,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.35),
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13.sp, color: color),
                SizedBox(width: 3.w),
                Text(
                  percent,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
