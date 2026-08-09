import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum OptionState { idle, selected, correct, wrong }

class AnswerOption extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback? onTap;
  final bool isHindi;

  const AnswerOption({
    super.key,
    required this.text,
    required this.state,
    this.onTap,
    this.isHindi = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    switch (state) {
      case OptionState.idle:
        bgColor = AppColors.surface;
        borderColor = AppColors.cardBg;
        textColor = AppColors.textPrimary;
        break;
      case OptionState.selected:
        bgColor = AppColors.primary.withValues(alpha: 0.08);
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
        break;
      case OptionState.correct:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        trailingIcon = const Icon(Icons.check_circle,
            color: AppColors.success, size: 22);
        break;
      case OptionState.wrong:
        bgColor = AppColors.error.withValues(alpha: 0.08);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        trailingIcon =
            const Icon(Icons.cancel, color: AppColors.error, size: 22);
        break;
    }

    return GestureDetector(
      onTap: state == OptionState.idle ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: state == OptionState.idle
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: isHindi
                    ? AppTextStyles.hindiSmall.copyWith(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )
                    : AppTextStyles.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}