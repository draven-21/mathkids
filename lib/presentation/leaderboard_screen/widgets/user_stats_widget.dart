import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// User statistics widget displaying current user's performance metrics
class UserStatsWidget extends StatelessWidget {
  final int quizzesCompleted;
  final int averageScore;
  final int currentStreak;

  const UserStatsWidget({
    Key? key,
    required this.quizzesCompleted,
    required this.averageScore,
    required this.currentStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section title
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'bar_chart',
                  size: 5.w,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Your Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Statistics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  theme,
                  'Quizzes',
                  '$quizzesCompleted',
                  'quiz',
                  const Color(0xFF4A90E2),
                ),
                _buildStatCard(
                  theme,
                  'Avg Score',
                  '$averageScore%',
                  'grade',
                  const Color(0xFF27AE60),
                ),
                _buildStatCard(
                  theme,
                  'Streak',
                  '$currentStreak days',
                  'local_fire_department',
                  const Color(0xFFF39C12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual stat card
  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    String iconName,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(color: accentColor, width: 2),
        ),
        child: Column(
          children: [
            CustomIconWidget(iconName: iconName, size: 6.w, color: accentColor),

            SizedBox(height: 1.h),

            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 0.5.h),

            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
