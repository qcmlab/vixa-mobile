import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../providers/widget_settings_provider.dart';

class WidgetSettingsSheet extends ConsumerWidget {
  const WidgetSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const WidgetSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(widgetSettingsProvider);
    final notifier = ref.read(widgetSettingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: SingleChildScrollView(
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
            SizedBox(height: 14.h),

            // Sheet Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.widgets_rounded, color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات الويدجت الخارجي (Widget Settings)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'تخصيص محتوى وترتيب بطاقات الشاشة الرئيسية وقفل الهاتف',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10.5.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 1. Reorder On Phone Lock / Unlock Switch
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentTeal.withValues(alpha: 0.12), AppColors.surfaceLight],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.screen_rotation_alt_rounded, color: AppColors.accentTeal, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إعادة الترتيب التلقائي عند فتح الهاتف',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'تغيير وعرض بطاقة جديدة في كل مرة تغلق فيها الهاتف وتفتحه',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.autoShuffleOnUnlock,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => notifier.toggleAutoShuffle(val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2. Subject Scope Section
            Text(
              '1. نطاق مادة الويدجت (Subject Scope):',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                _buildFilterChip(
                  label: '🎲 جميع المواد',
                  isSelected: settings.subjectScope == 'all',
                  onTap: () => notifier.setSubjectScope('all'),
                ),
                _buildFilterChip(
                  label: '📜 التاريخ فقط',
                  isSelected: settings.subjectScope == 'history',
                  onTap: () => notifier.setSubjectScope('history'),
                ),
                _buildFilterChip(
                  label: '🌍 الجغرافيا فقط',
                  isSelected: settings.subjectScope == 'geography',
                  onTap: () => notifier.setSubjectScope('geography'),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 3. Modality Filter Section
            Text(
              '2. نوع البطاقات المعروضة في الويدجت (Card Modality):',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                _buildFilterChip(
                  label: '🌟 جميع الأنماط',
                  isSelected: settings.modalityFilter == 'all',
                  onTap: () => notifier.setModalityFilter('all'),
                ),
                _buildFilterChip(
                  label: '📅 التواريخ فقط',
                  isSelected: settings.modalityFilter == 'date',
                  onTap: () => notifier.setModalityFilter('date'),
                ),
                _buildFilterChip(
                  label: '👤 الشخصيات فقط',
                  isSelected: settings.modalityFilter == 'person',
                  onTap: () => notifier.setModalityFilter('person'),
                ),
                _buildFilterChip(
                  label: '📖 المصطلحات فقط',
                  isSelected: settings.modalityFilter == 'term',
                  onTap: () => notifier.setModalityFilter('term'),
                ),
                _buildFilterChip(
                  label: '💡 كبسولات الذاكرة و QCM',
                  isSelected: settings.modalityFilter == 'advice',
                  onTap: () => notifier.setModalityFilter('advice'),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 4. Ordering Mode Section
            Text(
              '3. خوارزمية الترتيب في الويدجت (Ordering Strategy):',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5.sp,
              ),
            ),
            SizedBox(height: 8.h),
            _buildOrderingOption(
              title: '🧠 حسب أولوية الحفظ (Smart Priority)',
              subtitle: 'عرض البطاقات التي لم تحفظها (0%) أولاً لترسيخها، ثم المتوسطة (50%)، ثم المتقنة (100%)',
              isSelected: settings.orderingMode == 'priority',
              onTap: () => notifier.setOrderingMode('priority'),
            ),
            SizedBox(height: 8.h),
            _buildOrderingOption(
              title: '🎲 عشوائي دائم (Pure Random Shuffle)',
              subtitle: 'خلط عشوائي تام لكافة البطاقات المختارة بدون تقييد بالأولويات',
              isSelected: settings.orderingMode == 'random',
              onTap: () => notifier.setOrderingMode('random'),
            ),
            SizedBox(height: 18.h),

            // 5. Sync Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: settings.isSyncing
                    ? null
                    : () async {
                        await notifier.syncWidgetNow();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ تم تحديث ومزامنة بطاقات الويدجت الخارجي بنجاح!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                icon: settings.isSyncing
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.sync_rounded, size: 18.sp),
                label: Text(
                  settings.isSyncing ? 'جاري المزامنة...' : 'تطبيق ومزامنة الويدجت الآن 🚀',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderingOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
