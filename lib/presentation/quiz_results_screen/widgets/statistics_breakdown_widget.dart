import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Statistics breakdown widget showing detailed performance metrics
class StatisticsBreakdownWidget extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int pointsEarned;
  final int currentStreak;

  const StatisticsBreakdownWidget({
    Key? key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.pointsEarned,
    required this.currentStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (correctAnswers / totalQuestions * 100).toInt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            context: context,
            icon: 'check_circle',
            label: 'Accuracy',
            value: '$percentage%',
            color: const Color(0xFF27AE60),
          ),
          SizedBox(height: 2.h),
          _buildProgressBar(
            context: context,
            progress: percentage / 100,
            color: const Color(0xFF27AE60),
          ),
          SizedBox(height: 3.h),
          _buildStatRow(
            context: context,
            icon: 'stars',
            label: 'Points Earned',
            value: '+$pointsEarned',
            color: const Color(0xFFF39C12),
          ),
          SizedBox(height: 2.h),
          _buildStatRow(
            context: context,
            icon: 'local_fire_department',
            label: 'Current Streak',
            value: '$currentStreak days',
            color: const Color(0xFFE74C3C),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(iconName: icon, color: color, size: 24),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required double progress,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
