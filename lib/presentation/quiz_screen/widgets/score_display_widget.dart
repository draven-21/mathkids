import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final int score;
  final int streak;

  const ScoreDisplayWidget({
    Key? key,
    required this.score,
    required this.streak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
            context: context,
            icon: 'stars',
            label: 'Score',
            value: score.toString(),
            color: theme.colorScheme.secondary,
          ),
          Container(
            width: 2,
            height: 6.h,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildScoreItem(
            context: context,
            icon: 'local_fire_department',
            label: 'Streak',
            value: streak.toString(),
            color: const Color(0xFFE74C3C),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 32),
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                )
                .animate(key: ValueKey(value))
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ],
    );
  }
}
