import 'package:flutter/material.dart';
import '../core/constants.dart';

class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool isLarge;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = streakDays > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 10 : 6,
      ),
      decoration: BoxDecoration(
        color: hasStreak
            ? AppColors.accentGold.withValues(alpha: 0.15)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasStreak
              ? AppColors.accentGold.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasStreak ? '🔥' : '❄️',
            style: TextStyle(fontSize: isLarge ? 20 : 14),
          ),
          const SizedBox(width: 6),
          Text(
            '$streakDays ${streakDays == 1 ? 'يوم' : 'أيام'}',
            style: TextStyle(
              color: hasStreak ? AppColors.accentGold : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
