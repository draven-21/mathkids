import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Action buttons widget for navigation after quiz completion
class ActionButtonsWidget extends StatefulWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onViewLeaderboard;

  const ActionButtonsWidget({
    Key? key,
    required this.onPlayAgain,
    required this.onViewLeaderboard,
  }) : super(key: key);

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isPlayAgainPressed = false;
  bool _isLeaderboardPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildPrimaryButton(
          context: context,
          label: 'Play Again',
          icon: 'refresh',
          onPressed: widget.onPlayAgain,
          isPressed: _isPlayAgainPressed,
          onPressedChanged: (pressed) =>
              setState(() => _isPlayAgainPressed = pressed),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        SizedBox(height: 2.h),
        _buildSecondaryButton(
          context: context,
          label: 'View Leaderboard',
          icon: 'emoji_events',
          onPressed: widget.onViewLeaderboard,
          isPressed: _isLeaderboardPressed,
          onPressedChanged: (pressed) =>
              setState(() => _isLeaderboardPressed = pressed),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String label,
    required String icon,
    required VoidCallback onPressed,
    required bool isPressed,
    required ValueChanged<bool> onPressedChanged,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) {
        onPressedChanged(false);
        onPressed();
      },
      onTapCancel: () => onPressedChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        child: Container(
          width: double.infinity,
          height: 7.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPressed
                ? []
                : [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: foregroundColor,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String label,
    required String icon,
    required VoidCallback onPressed,
    required bool isPressed,
    required ValueChanged<bool> onPressedChanged,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => onPressedChanged(true),
      onTapUp: (_) {
        onPressedChanged(false);
        onPressed();
      },
      onTapCancel: () => onPressedChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        child: Container(
          width: double.infinity,
          height: 7.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            boxShadow: isPressed
                ? []
                : [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
