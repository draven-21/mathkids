import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Podium widget displaying top 3 performers with pixel-style design
class PodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;
  final AnimationController celebrationController;

  const PodiumWidget({
    Key? key,
    required this.topThree,
    required this.celebrationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (topThree.length < 3) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        children: [
          // Top row with 1st place
          _buildPodiumPlace(context, theme, topThree[0], 1, 20.h, true),

          SizedBox(height: 2.h),

          // Bottom row with 2nd and 3rd place
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildPodiumPlace(
                  context,
                  theme,
                  topThree[1],
                  2,
                  16.h,
                  false,
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: _buildPodiumPlace(
                  context,
                  theme,
                  topThree[2],
                  3,
                  14.h,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual podium place
  Widget _buildPodiumPlace(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> user,
    int place,
    double height,
    bool isFirst,
  ) {
    final Color placeColor = place == 1
        ? const Color(0xFFF39C12)
        : place == 2
        ? const Color(0xFF95A5A6)
        : const Color(0xFFCD7F32);

    return Column(
      children: [
        // Avatar with celebration effect for 1st place
        Stack(
          alignment: Alignment.center,
          children: [
            // Celebration glow for 1st place
            if (isFirst)
              AnimatedBuilder(
                animation: celebrationController,
                builder: (context, child) {
                  return Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: placeColor.withValues(
                            alpha: 0.3 + (celebrationController.value * 0.3),
                          ),
                          blurRadius: 20 + (celebrationController.value * 10),
                          spreadRadius: 5 + (celebrationController.value * 5),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Avatar circle
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: user["color"] as Color,
                shape: BoxShape.circle,
                border: Border.all(color: placeColor, width: 3),
              ),
              child: Center(
                child: Text(
                  user["avatar"] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Crown for 1st place
            if (isFirst)
              Positioned(
                top: -2.h,
                child: CustomIconWidget(
                  iconName: 'workspace_premium',
                  size: 8.w,
                  color: placeColor,
                ),
              ),
          ],
        ),

        SizedBox(height: 1.h),

        // Name
        Text(
          user["name"] as String,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 0.5.h),

        // Points with math symbol decoration
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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

        SizedBox(height: 1.h),

        // Podium base
        Container(
          height: height,
          decoration: BoxDecoration(
            color: placeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(2.w)),
            border: Border.all(color: placeColor, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Place number
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: placeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$place',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              // Trophy icon
              CustomIconWidget(
                iconName: 'emoji_events',
                size: 8.w,
                color: placeColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
