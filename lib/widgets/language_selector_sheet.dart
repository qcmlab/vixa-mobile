import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../core/constants.dart';
import '../providers/language_provider.dart';

class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LanguageSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider).languageCode;
    final langNotifier = ref.read(languageProvider.notifier);
    final t = ref.watch(languageProvider).t;

    final languages = [
      {'code': 'ar', 'name': 'العربية (Arabic)', 'flag': '🇸🇦', 'sub': 'اللغة الافتراضية للبكالوريا'},
      {'code': 'fr', 'name': 'Français (French)', 'flag': '🇫🇷', 'sub': 'Version française'},
      {'code': 'en', 'name': 'English (English)', 'flag': '🇬🇧', 'sub': 'English version'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Row(
            children: [
              Icon(Icons.language_rounded, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                t('settings.select_language'),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Languages List
          ...languages.map((item) {
            final code = item['code'] as String;
            final isSelected = currentLang == code;

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: () {
                  langNotifier.setLanguage(code);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.8.w : 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        item['flag'] as String,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item['sub'] as String,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
