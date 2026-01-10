import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Modern user statistics widget with clean card design
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
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: CustomIconWidget(
                    iconName: 'bar_chart',
                    size: 5.w,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Your Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.5.h),

            // Statistics row with modern cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  theme,
                  'Quizzes',
                  '$quizzesCompleted',
                  'quiz',
                  theme.colorScheme.primary,
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
                  '$currentStreak',
                  'local_fire_department',
                  theme.colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual stat card with modern design
  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    String iconName,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon with colored background
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: iconName,
                size: 6.w,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 1.5.h),

            // Value
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                fontSize: 20.sp,
                height: 1,
              ),
            ),

            SizedBox(height: 0.5.h),

            // Label
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
