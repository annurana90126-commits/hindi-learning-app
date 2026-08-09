import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DailyGoalCard extends StatelessWidget {
  final int currentXp;
  final int goalXp;

  const DailyGoalCard({
    super.key,
    required this.currentXp,
    required this.goalXp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / goalXp).clamp(0.0, 1.0);
    final isComplete = currentXp >= goalXp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ring indicator
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cardBg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppColors.success : AppColors.primary,
                  ),
                  strokeWidth: 5,
                ),
                Center(
                  child: Text(
                    isComplete ? '✓' : '${(progress * 100).toInt()}%',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isComplete ? AppColors.success : AppColors.primary,
                      fontSize: isComplete ? 16 : 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Daily goal complete! 🎉' : 'Daily Goal',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'Amazing work today!'
                      : '$currentXp / $goalXp XP earned today',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          if (!isComplete)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Go', style: AppTextStyles.button.copyWith(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}