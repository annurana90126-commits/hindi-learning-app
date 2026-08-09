import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;

  const LessonCard({super.key, required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.cardBg.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.3)
                : isLocked
                    ? Colors.transparent
                    : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Lesson icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.textHint.withValues(alpha: 0.1)
                    : isCompleted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock_outline,
                        color: AppColors.textHint, size: 22)
                    : isCompleted
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success, size: 26)
                        : Text(
                            lesson.titleHindi[0],
                            style: AppTextStyles.hindiMedium.copyWith(
                              color: AppColors.primary,
                              fontSize: 22,
                            ),
                          ),
              ),
            ),

            const SizedBox(width: 14),

            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lesson.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lesson.titleHindi,
                        style: AppTextStyles.hindiSmall.copyWith(
                          color: isLocked
                              ? AppColors.textHint
                              : AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isLocked
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.xpGold, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${lesson.accuracy.toInt()}% accuracy',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right side — XP or arrow
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppColors.textHint.withValues(alpha: 0.1)
                        : AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${lesson.xpReward} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: isLocked ? AppColors.textHint : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLocked) ...[
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}