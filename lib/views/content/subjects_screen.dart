import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/subject.dart';
import '../../providers/content_provider.dart';
import 'lesson_detail_screen.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  String? _expandedSubjectId;
  final Map<String, List<ChapterModel>> _chaptersCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentProvider.notifier).fetchSubjects();
    });
  }

  void _toggleSubject(String subjectId) async {
    if (_expandedSubjectId == subjectId) {
      setState(() => _expandedSubjectId = null);
      return;
    }

    setState(() => _expandedSubjectId = subjectId);

    if (!_chaptersCache.containsKey(subjectId)) {
      final chapters = await ref.read(contentProvider.notifier).fetchChapters(subjectId);
      if (mounted) {
        setState(() => _chaptersCache[subjectId] = chapters);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'المناهج والوحدات التعليمية',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: content.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: () => ref.read(contentProvider.notifier).fetchSubjects(),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: content.subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final subject = content.subjects[index];
                    final isExpanded = _expandedSubjectId == subject.id;
                    final chapters = _chaptersCache[subject.id] ?? [];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          // Subject Header Tile
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            onTap: () => _toggleSubject(subject.id),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (index == 0 ? AppColors.accentGold : AppColors.accentBlue)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                index == 0 ? Icons.history_edu_rounded : Icons.public_rounded,
                                color: index == 0 ? AppColors.accentGold : AppColors.accentBlue,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              subject.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${subject.chaptersCount} وحدات • ${subject.totalCardsCount} بطاقة',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),

                          // Chapters & Lessons List
                          if (isExpanded) ...[
                            const Divider(color: AppColors.cardBorder, height: 1),
                            if (chapters.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'جاري تحميل الوحدات...',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chapters.length,
                                itemBuilder: (context, cIdx) {
                                  final chapter = chapters[cIdx];
                                  return ExpansionTile(
                                    title: Text(
                                      chapter.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    iconColor: AppColors.primary,
                                    collapsedIconColor: AppColors.textMuted,
                                    children: chapter.lessons.map((lesson) {
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                                        leading: const Icon(Icons.bookmark_outline_rounded, size: 16, color: AppColors.primary),
                                        title: Text(
                                          lesson.name,
                                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => LessonDetailScreen(
                                                lesson: lesson,
                                                subjectName: subject.name,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
