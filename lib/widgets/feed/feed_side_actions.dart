import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../models/flashcard.dart';

class FeedSideActions extends StatelessWidget {
  final FlashcardModel card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onMastered;
  final VoidCallback onReviewLater;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAudioPlay;

  const FeedSideActions({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    required this.onMastered,
    required this.onReviewLater,
    required this.onToggleFavorite,
    required this.onAudioPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Mastered Button (SM-2 Good/Easy rating)
          _buildActionButton(
            icon: Icons.check_circle_rounded,
            color: AppColors.primary,
            label: 'حفظتُها',
            onTap: onMastered,
            isGlowing: true,
          ),
          SizedBox(height: 14.h),

          // 2. Review Later (SM-2 Hard/Again rating)
          _buildActionButton(
            icon: Icons.replay_rounded,
            color: AppColors.accentGold,
            label: 'إعادة',
            onTap: onReviewLater,
          ),
          SizedBox(height: 14.h),

          // 3. Flip Card Action
          _buildActionButton(
            icon: isFlipped ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
            color: AppColors.accentBlue,
            label: isFlipped ? 'السؤال' : 'الإجابة',
            onTap: onFlip,
          ),
          SizedBox(height: 14.h),

          // 4. Favorite / Bookmark (Heart)
          _buildActionButton(
            icon: card.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: card.isFavorite ? AppColors.accentRose : AppColors.textSecondary,
            label: card.isFavorite ? 'مفضلة' : 'حفظ',
            onTap: onToggleFavorite,
          ),
          SizedBox(height: 14.h),

          // 5. Audio / Pronunciation
          _buildActionButton(
            icon: Icons.volume_up_rounded,
            color: AppColors.textSecondary,
            label: 'استماع',
            onTap: onAudioPlay,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool isGlowing = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: isGlowing ? color.withValues(alpha: 0.6) : AppColors.cardBorder,
                width: isGlowing ? 1.6.w : 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: isGlowing ? color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                  blurRadius: isGlowing ? 10.r : 6.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: color,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: color == AppColors.textSecondary ? AppColors.textMuted : color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
