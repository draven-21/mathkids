import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying individual achievement badges
class AchievementBadgeWidget extends StatelessWidget {
  final String badgeName;
  final String description;
  final String iconName;
  final Color badgeColor;
  final String unlockDate;
  final bool isUnlocked;

  const AchievementBadgeWidget({
    Key? key,
    required this.badgeName,
    required this.description,
    required this.iconName,
    required this.badgeColor,
    required this.unlockDate,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 28.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badgeColor.withValues(alpha: 0.2)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? badgeColor
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: isUnlocked
                    ? badgeColor
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            badgeName,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isUnlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked) ...[
            SizedBox(height: 0.5.h),
            Text(
              unlockDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
