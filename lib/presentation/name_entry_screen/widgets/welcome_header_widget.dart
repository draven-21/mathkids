import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Welcome header widget with colorful pixel-style mascot and greeting
class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Pixel-style mascot illustration
        Container(
          width: 50.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.primary, width: 3),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Mascot character (pixel-style robot/owl)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Head
                  Container(
                    width: 20.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left eye
                        Container(
                          width: 4.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Right eye
                        Container(
                          width: 4.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Body
                  Container(
                    width: 15.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'school',
                        color: theme.colorScheme.surface,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              // Decorative stars
              Positioned(
                top: 2.h,
                left: 4.w,
                child: CustomIconWidget(
                  iconName: 'star',
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
              Positioned(
                top: 3.h,
                right: 5.w,
                child: CustomIconWidget(
                  iconName: 'star',
                  color: theme.colorScheme.tertiary,
                  size: 16,
                ),
              ),
              Positioned(
                bottom: 3.h,
                right: 3.w,
                child: CustomIconWidget(
                  iconName: 'star',
                  color: theme.colorScheme.secondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Welcome text
        Text(
          "What's your name?",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        // Subtitle
        Text(
          'Let\'s start your math adventure!',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
