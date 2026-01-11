import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/user_avatar_widget.dart';

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
                      const Color(0xFFC0C0C0), // Silver
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
                      const Color(0xFFFFD700), // Gold
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
                      const Color(0xFFCD7F32), // Bronze
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
        // Rank badge at top - modern design
        Container(
          width: rankBadgeSize,
          height: rankBadgeSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [borderColor, borderColor.withOpacity(0.7)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              placeLabel,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: isFirst ? 18.sp : 15.sp,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
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
            PodiumAvatarWidget(
              avatarUrl: user["avatarUrl"] as String?,
              initials: user["avatar"] as String,
              backgroundColor: user["color"] as Color,
              borderColor: borderColor,
              isFirst: isFirst,
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

        // Name in modern container
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4), // Changed offset
              ),
            ],
          ),
          child: Text(
            user["name"] as String,
            style: TextStyle(
              // Changed to direct TextStyle
              fontWeight: FontWeight.w800, // Changed from w700
              color: theme.colorScheme.onSurface,
              fontSize: isFirst
                  ? 13.sp
                  : 11.sp, // Changed from 12.sp for isFirst
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: 1.h),

        // Points display - bold and prominent // Changed comment
        Text(
          '${user["points"]}',
          style: TextStyle(
            // Changed to direct TextStyle
            fontWeight: FontWeight.w900,
            color: borderColor, // Changed from theme.colorScheme.onPrimary
            fontSize: isFirst ? 24.sp : 19.sp,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
              Shadow(
                color: borderColor.withOpacity(0.5),
                offset: const Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
        ),

        // Trophy icon - more prominent for 1st place
        if (isFirst) ...[
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  borderColor.withOpacity(0.4),
                  borderColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: 'emoji_events',
              size: 8.w,
              color: borderColor,
            ),
          ),
        ] else ...[
          SizedBox(height: 1.2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  borderColor.withOpacity(0.2),
                  borderColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: borderColor.withOpacity(0.3),
                width: 1.5,
              ),
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
