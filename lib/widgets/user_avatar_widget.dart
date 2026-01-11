import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

/// Reusable avatar widget that displays user avatar or initials as fallback
class UserAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final Color backgroundColor;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    Key? key,
    this.avatarUrl,
    required this.initials,
    required this.backgroundColor,
    this.size = 50.0,
    this.borderWidth = 0,
    this.borderColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor = borderColor ?? theme.colorScheme.primary;

    Widget avatarContent;

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // Display uploaded avatar image
      avatarContent = ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            color: backgroundColor.withOpacity(0.3),
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildInitialsAvatar(),
        ),
      );
    } else {
      // Display initials as fallback
      avatarContent = _buildInitialsAvatar();
    }

    // Wrap in border if needed
    Widget avatar = borderWidth > 0
        ? Container(
            width: size + (borderWidth * 2),
            height: size + (borderWidth * 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveBorderColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: avatarContent),
          )
        : avatarContent;

    // Make tappable if onTap provided
    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Responsive avatar widget using Sizer units
class ResponsiveUserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final Color backgroundColor;
  final double sizePercentage; // Width percentage
  final double borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ResponsiveUserAvatar({
    Key? key,
    this.avatarUrl,
    required this.initials,
    required this.backgroundColor,
    this.sizePercentage = 20.0,
    this.borderWidth = 3.0,
    this.borderColor,
    this.onTap,
    this.showEditIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = sizePercentage.w;

    Widget avatar = UserAvatarWidget(
      avatarUrl: avatarUrl,
      initials: initials,
      backgroundColor: backgroundColor,
      size: avatarSize,
      borderWidth: borderWidth,
      borderColor: borderColor,
      onTap: onTap,
    );

    // Add edit icon overlay if enabled
    if (showEditIcon) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: avatarSize * 0.3,
              height: avatarSize * 0.3,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: avatarSize * 0.15,
              ),
            ),
          ),
        ],
      );
    }

    return avatar;
  }
}

/// Leaderboard avatar widget with rank indicator
class LeaderboardAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final Color backgroundColor;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardAvatarWidget({
    Key? key,
    this.avatarUrl,
    required this.initials,
    required this.backgroundColor,
    required this.rank,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer decorative ring
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: backgroundColor.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        // Main avatar
        UserAvatarWidget(
          avatarUrl: avatarUrl,
          initials: initials,
          backgroundColor: backgroundColor,
          size: 12.5.w,
          borderWidth: 0,
        ),
      ],
    );
  }
}

/// Podium avatar widget for top 3 players
class PodiumAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final Color backgroundColor;
  final Color borderColor;
  final bool isFirst;

  const PodiumAvatarWidget({
    Key? key,
    this.avatarUrl,
    required this.initials,
    required this.backgroundColor,
    required this.borderColor,
    this.isFirst = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarSize = isFirst ? 28.w : 22.w;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer decorative ring
        Container(
          width: avatarSize + 2.w,
          height: avatarSize + 2.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor.withOpacity(0.5), width: 2),
          ),
        ),
        // Border ring - transparent background to not cover trophy
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            // Removed: color: theme.colorScheme.surface - was creating yellow square
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
          child: ClipOval(
            child: Container(
              color:
                  theme.colorScheme.surface, // Background only for avatar area
              child: Center(
                child: UserAvatarWidget(
                  avatarUrl: avatarUrl,
                  initials: initials,
                  backgroundColor: backgroundColor,
                  size: avatarSize - 4.w,
                  borderWidth: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
