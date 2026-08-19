import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/tiktok_feed_provider.dart';

class FeedTopBar extends ConsumerWidget {
  const FeedTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakDays = ref.watch(tiktokFeedProvider.select((s) => s.streakDays));
    final masteredTodayCount = ref.watch(tiktokFeedProvider.select((s) => s.masteredTodayCount));
    final selectedSubject = ref.watch(tiktokFeedProvider.select((s) => s.selectedSubject));
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 14,
        right: 14,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Streak + Daily Goal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays أيام مستمرة',
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Daily Mastered Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '$masteredTodayCount بطاقة أتقنتها',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: Subject Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubjectTab(
                label: '🎲 عشوائي',
                keyName: 'all',
                isSelected: selectedSubject == 'all',
                onTap: () => feedNotifier.setSubjectFilter('all'),
              ),
              const SizedBox(width: 8),
              _buildSubjectTab(
                label: '📜 التاريخ',
                keyName: 'history',
                isSelected: selectedSubject == 'history',
                onTap: () => feedNotifier.setSubjectFilter('history'),
              ),
              const SizedBox(width: 8),
              _buildSubjectTab(
                label: '🌍 الجغرافيا',
                keyName: 'geography',
                isSelected: selectedSubject == 'geography',
                onTap: () => feedNotifier.setSubjectFilter('geography'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTab({
    required String label,
    required String keyName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
