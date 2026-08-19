import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/language_provider.dart';
import 'content/subjects_screen.dart';
import 'dashboard/home_screen.dart';
import 'feed/tiktok_feed_screen.dart';
import 'profile/profile_screen.dart';
import 'quizzes/quizzes_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(languageProvider).t;

    final screens = [
      const TiktokFeedScreen(),
      HomeScreen(onTabChange: (idx) => setState(() => _currentIndex = idx)),
      const SubjectsScreen(),
      const QuizzesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.style_outlined),
              activeIcon: const Icon(Icons.style_rounded),
              label: t('nav.feed'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard_rounded),
              label: t('nav.home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book_outlined),
              activeIcon: const Icon(Icons.book_rounded),
              label: t('nav.curriculum'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz_outlined),
              activeIcon: const Icon(Icons.quiz_rounded),
              label: t('nav.quizzes'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: t('nav.profile'),
            ),
          ],
        ),
      ),
    );
  }
}
