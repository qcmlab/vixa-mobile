import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../providers/tiktok_feed_provider.dart';

class DeckSelectorSheet extends ConsumerStatefulWidget {
  const DeckSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DeckSelectorSheet(),
    );
  }

  @override
  ConsumerState<DeckSelectorSheet> createState() => _DeckSelectorSheetState();
}

class _DeckSelectorSheetState extends ConsumerState<DeckSelectorSheet> {
  List<Map<String, dynamic>> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  void _loadDecks() async {
    final decks = await ref.read(tiktokFeedProvider.notifier).getAvailableDecks();
    if (mounted) {
      setState(() {
        _decks = decks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDeckId = ref.watch(tiktokFeedProvider.select((s) => s.activeDeckId));
    final feedNotifier = ref.read(tiktokFeedProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.cardBorder, width: 1.w),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.style_rounded, color: AppColors.primary, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'اختر الرزمة التعليمية (Choose Deck)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, size: 18.sp, color: AppColors.textMuted),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadDecks();
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Deck List
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_decks.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(
                child: Text('لا توجد رزم متاحة حالياً.', style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _decks.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  final id = deck['id']?.toString() ?? '';
                  final title = deck['title']?.toString() ?? 'رزمة تعليمية';
                  final subject = deck['subject']?.toString() ?? deck['subject_name']?.toString() ?? 'منهاج البكالوريا';
                  final cardCount = deck['card_count'] ?? deck['cards_count'] ?? 10;
                  final badge = deck['badge']?.toString();
                  final isSelected = activeDeckId == id;

                  return GestureDetector(
                    onTap: () {
                      feedNotifier.selectDeck(id, title: title);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          width: isSelected ? 1.6.w : 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              isSelected ? Icons.play_arrow_rounded : Icons.folder_special_rounded,
                              color: isSelected ? Colors.white : AppColors.primary,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                                    fontSize: 13.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 3.h),
                                Row(
                                  children: [
                                    Text(
                                      '$subject • $cardCount بطاقة',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10.5.sp,
                                      ),
                                    ),
                                    if (badge != null) ...[
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          badge,
                                          style: TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
