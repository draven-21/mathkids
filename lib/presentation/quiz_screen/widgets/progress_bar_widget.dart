import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProgressBarWidget extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Animation<double> timerAnimation;

  const ProgressBarWidget({
    Key? key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.timerAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((currentQuestion / totalQuestions) * 100).toInt()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          AnimatedBuilder(
            animation: timerAnimation,
            builder: (context, child) {
              final progress = 1 - timerAnimation.value;
              final color = progress > 0.5
                  ? const Color(0xFF27AE60)
                  : progress > 0.25
                  ? const Color(0xFFF39C12)
                  : const Color(0xFFE74C3C);

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 1.h,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
