import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui' as ui;

/// Animated title widget with gradient shimmer effect
class AnimatedTitleWidget extends StatelessWidget {
  final double shimmerValue;

  const AnimatedTitleWidget({Key? key, required this.shimmerValue})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return ui.Gradient.linear(
          Offset(bounds.width * shimmerValue, 0),
          Offset(bounds.width * shimmerValue + bounds.width, 0),
          [
            Colors.white.withValues(alpha: 0.3),
            Colors.white,
            Colors.white.withValues(alpha: 0.3),
          ],
          [0.0, 0.5, 1.0],
        );
      },
      blendMode: BlendMode.srcATop,
      child: Column(
        children: [
          // Main title
          Text(
            'MathKids',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 48.sp,
              letterSpacing: 2,
              color: theme.colorScheme.primary,
              shadows: [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Subtitle with gradient
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.2),
                  theme.colorScheme.tertiary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              'Math Quiz Adventure',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
