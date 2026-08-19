import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stat_box.dart';
import '../../widgets/streak_badge.dart';
import '../study/study_session_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).fetchDashboard();
    });
  }

  void _startStudySession() async {
    final studyNotifier = ref.read(studyProvider.notifier);
    await studyNotifier.fetchTodayReviews();

    if (!mounted) return;

    final deck = ref.read(studyProvider).deck;
    if (deck == null || deck.dueCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 أحسنت! لقد أتممت جميع مراجعات اليوم.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudySessionScreen()),
    ).then((_) {
      if (mounted) {
        ref.read(dashboardProvider.notifier).fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final dashboard = ref.watch(dashboardProvider);
    final data = dashboard.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: User Greeting & Streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً، ${user?.firstName ?? 'طالب البكالوريا'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'شعبة: ${user?.profile?.stream ?? 'علوم تجريبية'} - 3 ثانوي',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    StreakBadge(streakDays: data?.currentStreak ?? 0),
                  ],
                ),
                const SizedBox(height: 24),

                // Daily Goal Progress Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🎯 هدف الحفظ اليومي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${data?.cardsReviewedToday ?? 0} / ${data?.dailyGoal ?? 10} بطاقات',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Linear Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (data != null && data.dailyGoal > 0)
                              ? (data.cardsReviewedToday / data.dailyGoal).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 8,
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CTA Button
                      CustomButton(
                        text: (data?.cardsRemainingToday ?? 0) > 0
                            ? 'ابدأ مراجعة اليوم (${data?.cardsRemainingToday} متبقية)'
                            : 'مراجعة بطاقات إضافية',
                        icon: Icons.play_arrow_rounded,
                        backgroundColor: Colors.white,
                        textColor: AppColors.primaryDark,
                        height: 48,
                        borderRadius: 14,
                        onPressed: _startStudySession,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // TikTok Style Quick Feed Launcher Banner
                GestureDetector(
                  onTap: () => widget.onTabChange?.call(0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPurple.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            color: AppColors.accentPurple,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📱 تلقيم الحفظ السريع (Feed)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'تصفح عمودي لانهائي بالأسئلة، التواريخ والشخصيات',
                                style: TextStyle(
                                  color: Color(0xFFC7D2FE),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.accentPurple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Learning Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                        title: 'البطاقات المتقنة',
                        value: '${data?.masteredCards ?? 0}',
                        icon: Icons.verified_rounded,
                        iconColor: AppColors.primary,
                        subtitle: 'إتقان تام للذاكرة',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatBox(
                        title: 'نسبة الدقة',
                        value: '${(data?.overallAccuracyPercentage ?? 0).toStringAsFixed(0)}%',
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.accentGold,
                        subtitle: 'معدل التذكر الصحيح',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                        title: 'قيد التثبيت',
                        value: '${data?.learningCards ?? 0}',
                        icon: Icons.timelapse_rounded,
                        iconColor: AppColors.accentBlue,
                        subtitle: 'بطاقات التكرار المتباعد',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatBox(
                        title: 'أطول سلسلة',
                        value: '${data?.longestStreak ?? 0} أيام',
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColors.accentRose,
                        subtitle: 'الرقم القياسي الشخصي',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Quick Actions: Flashcards & Curriculum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'بنك البطاقات والمناهج',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onTabChange?.call(1),
                      icon: const Icon(Icons.style_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        'استعراض البطاقات',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject Card 1: Histoire
                _buildSubjectTile(
                  title: 'التاريخ - 3 ثانوي',
                  description: 'الحرب الباردة، الثورة التحريرية، حركات التحرر',
                  icon: Icons.history_edu_rounded,
                  color: AppColors.accentGold,
                  onTap: () => widget.onTabChange?.call(2),
                ),
                const SizedBox(height: 12),

                // Subject Card 2: Geographie
                _buildSubjectTile(
                  title: 'الجغرافيا - 3 ثانوي',
                  description: 'الاقتصاد العالمي، تفاوت الشمال والجنوب، الطاقة',
                  icon: Icons.public_rounded,
                  color: AppColors.accentBlue,
                  onTap: () => widget.onTabChange?.call(2),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectTile({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      ),
    );
  }
}
