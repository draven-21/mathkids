import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Ranking list widget displaying students from 4th place onwards with modern card design
class RankingListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rankings;

  const RankingListWidget({Key? key, required this.rankings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: rankings.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final isCurrentUser = user["isCurrentUser"] as bool;

          return Padding(
            padding: EdgeInsets.only(bottom: 2.5.h),
            child: _buildRankingCard(theme, user, isCurrentUser, index),
          );
        }).toList(),
      ),
    );
  }

  /// Builds individual ranking card with modern layered design matching reference
  Widget _buildRankingCard(
    ThemeData theme,
    Map<String, dynamic> user,
    bool isCurrentUser,
    int index,
  ) {
    // Alternating subtle background colors for visual rhythm
    final backgroundColor = isCurrentUser
        ? theme.colorScheme.primary.withOpacity(0.08)
        : theme.colorScheme.surface;

    final borderColor = isCurrentUser
        ? theme.colorScheme.primary
        : Colors.transparent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: borderColor, width: isCurrentUser ? 2.5 : 0),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? theme.colorScheme.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.06),
            blurRadius: isCurrentUser ? 20 : 15,
            offset: Offset(0, isCurrentUser ? 6.0 : 4.0),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge with color-coded design
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#${user["rank"]}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),

          SizedBox(width: 4.w),

          // Avatar with layered circular design
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (user["color"] as Color).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              // Avatar circle
              Container(
                width: 12.5.w,
                height: 12.5.w,
                decoration: BoxDecoration(
                  color: user["color"] as Color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user["avatar"] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 4.w),

          // Name and "You" indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCurrentUser) ...[
                  SizedBox(height: 0.5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.3.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(1.w),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'YOU',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 3.w),

          // Points display with modern badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${user["points"]}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    fontSize: 16.sp,
                    height: 1,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  'pts',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 9.sp,
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
