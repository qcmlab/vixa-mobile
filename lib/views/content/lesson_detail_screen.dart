import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../core/constants.dart';
import '../../models/flashcard.dart';
import '../../models/subject.dart';
import '../../providers/content_provider.dart';
import '../../providers/tiktok_feed_provider.dart';
import '../feed/tiktok_feed_screen.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;
  final String subjectName;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.subjectName,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  List<FlashcardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    final cards = await ref.read(contentProvider.notifier).fetchLessonCards(widget.lesson.id);
    if (mounted) {
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    }
  }

  void _startTikTokStudyMode() {
    if (_cards.isEmpty) return;
    // Set this multimodal deck directly into the TikTok feed notifier
    ref.read(tiktokFeedProvider.notifier).loadDeckCards(_cards);
    
    // Navigate to full-screen TikTok feed
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TiktokFeedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lesson.name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      bottomNavigationBar: _cards.isNotEmpty
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1.w)),
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _startTikTokStudyMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  icon: Icon(Icons.bolt_rounded, size: 20.sp, color: AppColors.accentGold),
                  label: Text(
                    '🚀 بدء المراجعة بأسلوب التيك توك (${_cards.length} بطاقات)',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _cards.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد بطاقات منشأة لهذا الدرس بعد.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _cards.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: _getModalityColor(card.type).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    '${_getModalityLabel(card.type)} #${index + 1}',
                                    style: TextStyle(
                                      color: _getModalityColor(card.type),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Text(
                                    card.difficulty == 'easy'
                                        ? '🟢 سهل'
                                        : card.difficulty == 'hard'
                                            ? '🔴 متقدم'
                                            : '🟡 متوسط',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              card.question,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              card.answer,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5.sp,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getModalityColor(String type) {
    switch (type) {
      case 'qcm':
        return AppColors.primary;
      case 'date':
        return AppColors.accentGold;
      case 'person':
        return AppColors.accentPurple;
      case 'term':
        return AppColors.accentTeal;
      case 'advice':
        return AppColors.accentRose;
      case 'fact':
      default:
        return AppColors.accentBlue;
    }
  }

  String _getModalityLabel(String type) {
    switch (type) {
      case 'qcm':
        return 'سؤال تفاعلي QCM';
      case 'date':
        return 'تاريخ ومحطة';
      case 'person':
        return 'شخصية بارزة';
      case 'term':
        return 'مصطلح ومفهوم';
      case 'advice':
        return 'كبسولة الذاكرة';
      case 'fact':
      default:
        return 'بطاقة ذكية';
    }
  }
}
