import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Ranking list widget displaying students from 4th place onwards
class RankingListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rankings;

  const RankingListWidget({Key? key, required this.rankings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Row(
              children: [
                Container(
                  width: 1.w,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(0.5.w),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'All Rankings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Ranking cards
          ...rankings.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final isCurrentUser = user["isCurrentUser"] as bool;
            final isEven = index % 2 == 0;

            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: _buildRankingCard(theme, user, isCurrentUser, isEven),
            );
          }),
        ],
      ),
    );
  }

  /// Builds individual ranking card
  Widget _buildRankingCard(
    ThemeData theme,
    Map<String, dynamic> user,
    bool isCurrentUser,
    bool isEven,
  ) {
    final backgroundColor = isCurrentUser
        ? theme.colorScheme.primary.withValues(alpha: 0.1)
        : isEven
        ? theme.colorScheme.surface
        : theme.colorScheme.surface.withValues(alpha: 0.5);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isCurrentUser
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: isCurrentUser ? 3 : 2,
        ),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: Text(
                '${user["rank"]}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Avatar
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: user["color"] as Color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                user["avatar"] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Name and current user indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCurrentUser) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        size: 3.w,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'You',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Points with animated counter effect
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'functions',
                  size: 4.w,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${user["points"]}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
