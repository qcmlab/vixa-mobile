import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum FeedbackLevel {
  notYet, // 0% - لم أحفظ بعد / نسيتها
  partially, // 50% - نصف حفظ / تذكرت بصعوبة
  mastered, // 100% - حفظتُها تماماً
}

class MemorizationFeedbackBar extends StatefulWidget {
  final Function(FeedbackLevel level) onFeedback;

  const MemorizationFeedbackBar({
    super.key,
    required this.onFeedback,
  });

  @override
  State<MemorizationFeedbackBar> createState() => _MemorizationFeedbackBarState();
}

class _MemorizationFeedbackBarState extends State<MemorizationFeedbackBar> {
  FeedbackLevel? _selectedLevel;

  void _selectLevel(FeedbackLevel level) {
    setState(() => _selectedLevel = level);
    widget.onFeedback(level);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ما مدى استيعابك وتذكرك لهذه المعلومة؟ 🤔',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. Not Yet (0%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.notYet,
                  label: 'لم أحفظ',
                  percent: '0%',
                  icon: Icons.close_rounded,
                  color: AppColors.ratingAgain,
                ),
              ),
              const SizedBox(width: 8),

              // 2. Partially (50%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.partially,
                  label: 'نصف حفظ',
                  percent: '50%',
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 8),

              // 3. Mastered (100%)
              Expanded(
                child: _buildFeedbackButton(
                  level: FeedbackLevel.mastered,
                  label: 'أتقنتُها',
                  percent: '100%',
                  icon: Icons.check_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton({
    required FeedbackLevel level,
    required String label,
    required String percent,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  percent,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
