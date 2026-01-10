import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Podium widget displaying top 3 performers with modern design inspired by reference image
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

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8.w),
        bottomRight: Radius.circular(8.w),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      theme.colorScheme.primary.withOpacity(0.4),
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.3),
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.7),
                      theme.colorScheme.primary.withOpacity(0.5),
                      theme.colorScheme.secondary.withOpacity(0.4),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.3 : 0.2,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top 3 players in horizontal layout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd place
                  Expanded(
                    child: _buildPodiumPlace(
                      context,
                      theme,
                      topThree[1],
                      2,
                      '#2',
                      theme.colorScheme.surface,
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // 1st place (larger)
                  Expanded(
                    child: _buildPodiumPlace(
                      context,
                      theme,
                      topThree[0],
                      1,
                      '#1',
                      theme.colorScheme.secondary,
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // 3rd place
                  Expanded(
                    child: _buildPodiumPlace(
                      context,
                      theme,
                      topThree[2],
                      3,
                      '#3',
                      theme.colorScheme.surface.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual podium place with layered circular design
  Widget _buildPodiumPlace(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> user,
    int place,
    String placeLabel,
    Color borderColor,
  ) {
    final bool isFirst = place == 1;
    final double avatarSize = isFirst ? 28.w : 22.w;
    final double rankBadgeSize = isFirst ? 10.w : 8.w;

    return Column(
      children: [
        // Rank badge at top
        Container(
          width: rankBadgeSize,
          height: rankBadgeSize,
          decoration: BoxDecoration(
            color: borderColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.6 : 0.4,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              placeLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                fontSize: isFirst ? 16.sp : 14.sp,
              ),
            ),
          ),
        ),

        SizedBox(height: 1.5.h),

        // Avatar with layered circles and glow effect
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow for 1st place
            if (isFirst)
              AnimatedBuilder(
                animation: celebrationController,
                builder: (context, child) {
                  return Container(
                    width: avatarSize + 4.w,
                    height: avatarSize + 4.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(
                            0.3 + (celebrationController.value * 0.2),
                          ),
                          blurRadius: 20 + (celebrationController.value * 15),
                          spreadRadius: 5 + (celebrationController.value * 5),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Outer decorative ring
            Container(
              width: avatarSize + 2.w,
              height: avatarSize + 2.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),

            // Main avatar circle with theme-aware border
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isFirst ? 4 : 3),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: avatarSize - 4.w,
                  height: avatarSize - 4.w,
                  decoration: BoxDecoration(
                    color: user["color"] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user["avatar"] as String,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: isFirst ? 24.sp : 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Crown/Trophy icon for 1st place
            if (isFirst)
              Positioned(
                top: -1.h,
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    size: 6.w,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 1.5.h),

        // Name in theme-aware container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2.w),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            user["name"] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: isFirst ? 12.sp : 11.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: 1.h),

        // Points display
        Text(
          '${user["points"]}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onPrimary,
            fontSize: isFirst ? 22.sp : 18.sp,
            shadows: [
              Shadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.6)
                    : Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        // Trophy icon or laurel decoration
        if (isFirst) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'emoji_events',
              size: 7.w,
              color: borderColor,
            ),
          ),
        ] else ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  place == 2 ? Icons.military_tech : Icons.workspace_premium,
                  color: borderColor,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Icon(
                  place == 2 ? Icons.military_tech : Icons.workspace_premium,
                  color: borderColor,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
