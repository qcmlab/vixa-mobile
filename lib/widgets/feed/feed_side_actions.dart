import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
          const SizedBox(height: 18),

          // 2. Review Later (SM-2 Hard/Again rating)
          _buildActionButton(
            icon: Icons.replay_rounded,
            color: AppColors.accentGold,
            label: 'إعادة',
            onTap: onReviewLater,
          ),
          const SizedBox(height: 18),

          // 3. Flip Card Action (if applicable)
          _buildActionButton(
            icon: isFlipped ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
            color: AppColors.accentBlue,
            label: isFlipped ? 'السؤال' : 'الإجابة',
            onTap: onFlip,
          ),
          const SizedBox(height: 18),

          // 4. Favorite / Bookmark (Heart)
          _buildActionButton(
            icon: card.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: card.isFavorite ? AppColors.accentRose : AppColors.textSecondary,
            label: card.isFavorite ? 'مفضلة' : 'حفظ',
            onTap: onToggleFavorite,
          ),
          const SizedBox(height: 18),

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: isGlowing ? color.withValues(alpha: 0.6) : AppColors.cardBorder,
                width: isGlowing ? 1.8 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isGlowing ? color.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.25),
                  blurRadius: isGlowing ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 26,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color == AppColors.textSecondary ? AppColors.textMuted : color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
