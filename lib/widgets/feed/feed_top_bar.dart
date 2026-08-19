import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/tiktok_feed_provider.dart';
import '../language_selector_sheet.dart';
import 'deck_selector_sheet.dart';

class FeedTopBar extends ConsumerWidget {
  const FeedTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakDays = ref.watch(tiktokFeedProvider.select((s) => s.streakDays));
    final masteredTodayCount = ref.watch(tiktokFeedProvider.select((s) => s.masteredTodayCount));
    final selectedSubject = ref.watch(tiktokFeedProvider.select((s) => s.selectedSubject));
    final activeDeckTitle = ref.watch(tiktokFeedProvider.select((s) => s.activeDeckTitle));
    final currentLang = ref.watch(languageProvider).languageCode.toUpperCase();
    final t = ref.watch(languageProvider).t;
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4.h,
        left: 12.w,
        right: 12.w,
        bottom: 4.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Streak + Deck Switcher + Daily Mastered + Language
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Streak Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 12.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '$streakDays ${t('feed.streak')}',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Active Deck Switcher Pill (Tap to select any deck)
              GestureDetector(
                onTap: () => DeckSelectorSheet.show(context),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 150.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.style_rounded, size: 11.sp, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          activeDeckTitle,
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down_rounded, size: 14.sp, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              // Daily Mastered Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 13.sp, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text(
                      '$masteredTodayCount',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Language Quick Switcher Pill
              GestureDetector(
                onTap: () => LanguageSelectorSheet.show(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded, size: 11.sp, color: AppColors.primary),
                      SizedBox(width: 3.w),
                      Text(
                        currentLang,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          // Row 2: Subject Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubjectTab(
                label: t('feed.random'),
                keyName: 'all',
                isSelected: selectedSubject == 'all',
                onTap: () => feedNotifier.setSubjectFilter('all'),
              ),
              SizedBox(width: 6.w),
              _buildSubjectTab(
                label: t('feed.history'),
                keyName: 'history',
                isSelected: selectedSubject == 'history',
                onTap: () => feedNotifier.setSubjectFilter('history'),
              ),
              SizedBox(width: 6.w),
              _buildSubjectTab(
                label: t('feed.geography'),
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
