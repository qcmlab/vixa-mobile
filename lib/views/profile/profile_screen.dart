import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/lockscreen_service.dart';
import '../../widgets/language_selector_sheet.dart';
import '../settings/widget_settings_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLockScreenEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkLockScreenState();
  }

  void _checkLockScreenState() async {
    final enabled = await LockscreenService.isLockScreenEnabled();
    if (mounted) setState(() => _isLockScreenEnabled = enabled);
  }

  void _toggleLockScreen(bool val) async {
    setState(() => _isLockScreenEnabled = val);
    if (val) {
      await LockscreenService.startLockScreenService();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تفعيل مراجعة البطاقات عند فتح الهاتف.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      await LockscreenService.stopLockScreenService();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏸️ تم تعطيل مراجعة قفل الشاشة.'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final data = ref.watch(dashboardProvider).data;
    final t = ref.watch(languageProvider).t;
    final currentLang = ref.watch(languageProvider).languageCode;

    String langName = 'العربية (Arabic)';
    String langFlag = '🇸🇦';
    if (currentLang == 'fr') {
      langName = 'Français (French)';
      langFlag = '🇫🇷';
    } else if (currentLang == 'en') {
      langName = 'English (English)';
      langFlag = '🇬🇧';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          t('settings.title'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accentTeal],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'S',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'طالب البكالوريا',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'شعبة: ${user?.profile?.stream ?? 'علوم تجريبية'}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Language & Localization Settings
              _buildSectionHeader(t('settings.language')),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ListTile(
                  onTap: () => LanguageSelectorSheet.show(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 22),
                  ),
                  title: Text(
                    t('settings.language'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                  ),
                  subtitle: Text(
                    '$langFlag $langName',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),

              // Lock Screen Study Mode
              _buildSectionHeader(t('settings.lockscreen')),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentTeal.withValues(alpha: 0.15), AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isLockScreenEnabled,
                      activeThumbColor: AppColors.primary,
                      title: Text(
                        t('settings.lockscreen'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                      ),
                      subtitle: Text(
                        t('settings.lockscreen_desc'),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                      onChanged: _toggleLockScreen,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => LockscreenService.testLockScreen(),
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.accentTeal),
                        label: const Text(
                          'معاينة شاشة القفل الآن 👁️',
                          style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Outside Home Screen Widget Customization
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ListTile(
                  onTap: () => WidgetSettingsSheet.show(context),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.widgets_rounded, color: AppColors.accentGold, size: 22),
                  ),
                  title: const Text(
                    'تخصيص الويدجت الخارجي (Widget Settings)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'تعديل مادة ونوع البطاقات وإعادة الترتيب التلقائي عند فتح الهاتف',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 24),

              // Study Preferences
              _buildSectionHeader('إعدادات الحفظ والمراجعة'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.flag_rounded, color: AppColors.primary),
                      title: Text(t('settings.daily_goal'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      trailing: Text(
                        '${data?.dailyGoal ?? 10} بطاقات/يوم',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_rounded, color: AppColors.accentGold),
                      title: Text(t('settings.notifications'), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      trailing: Text(
                        user?.profile?.preferredNotificationTime ?? '18:00',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.accentRose.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.accentRose, size: 18),
                  label: Text(
                    t('settings.logout'),
                    style: const TextStyle(color: AppColors.accentRose, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
