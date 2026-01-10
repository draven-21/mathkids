import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Welcome header widget with colorful pixel-style mascot and greeting
class WelcomeHeaderWidget extends StatefulWidget {
  const WelcomeHeaderWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _floatController;
  late AnimationController _starTwinkleController;
  late AnimationController _headTiltController;

  late Animation<double> _blinkAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _starTwinkle1;
  late Animation<double> _starTwinkle2;
  late Animation<double> _starTwinkle3;
  late Animation<double> _starTwinkle4;
  late Animation<double> _headTiltAnimation;

  int _blinkCount = 0;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();

    // Natural blinking animation (varies in timing and pattern)
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Gentle floating animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Star twinkling animations (staggered)
    _starTwinkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _starTwinkle1 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _starTwinkleController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _starTwinkle2 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _starTwinkleController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );

    _starTwinkle3 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _starTwinkleController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    _starTwinkle4 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _starTwinkleController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Subtle head tilt animation
    _headTiltController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    _headTiltAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _headTiltController, curve: Curves.easeInOut),
    );

    // Start natural blinking cycle
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    if (!mounted) return;

    // Vary the delay between blinks (2-5 seconds)
    final delay = Duration(milliseconds: 2000 + math.Random().nextInt(3000));

    Future.delayed(delay, () {
      if (!mounted || _isBlinking) return;
      _performBlink();
    });
  }

  void _performBlink() async {
    if (!mounted || _isBlinking) return;

    setState(() => _isBlinking = true);
    _blinkCount++;

    // Decide blink pattern based on count
    if (_blinkCount % 7 == 0) {
      // Double blink (every 7th blink)
      await _blinkController.forward();
      await _blinkController.reverse();
      await Future.delayed(const Duration(milliseconds: 150));
      await _blinkController.forward();
      await _blinkController.reverse();
    } else if (_blinkCount % 11 == 0) {
      // Slow blink (every 11th blink)
      _blinkController.duration = const Duration(milliseconds: 250);
      await _blinkController.forward();
      await Future.delayed(const Duration(milliseconds: 50));
      await _blinkController.reverse();
      _blinkController.duration = const Duration(milliseconds: 150);
    } else {
      // Normal blink
      await _blinkController.forward();
      await _blinkController.reverse();
    }

    if (mounted) {
      setState(() => _isBlinking = false);
      _scheduleNextBlink();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _floatController.dispose();
    _starTwinkleController.dispose();
    _headTiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Pixel-style mascot illustration with animations
        AnimatedBuilder(
          animation: Listenable.merge([
            _floatAnimation,
            _starTwinkleController,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Container(
                width: 50.w,
                height: 25.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Mascot character (pixel-style robot) with tilt
                    AnimatedBuilder(
                      animation: _headTiltAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _headTiltAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Head with blinking eyes
                              AnimatedBuilder(
                                animation: _blinkAnimation,
                                builder: (context, child) {
                                  return Container(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Left eye
                                        _buildEye(theme),
                                        // Right eye
                                        _buildEye(theme),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Decorative stars with twinkling
                    Positioned(
                      top: 2.h,
                      left: 4.w,
                      child: Opacity(
                        opacity: _starTwinkle1.value,
                        child: Transform.scale(
                          scale: 0.8 + (_starTwinkle1.value * 0.2),
                          child: CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 3.h,
                      right: 5.w,
                      child: Opacity(
                        opacity: _starTwinkle2.value,
                        child: Transform.scale(
                          scale: 0.8 + (_starTwinkle2.value * 0.2),
                          child: CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.tertiary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 3.h,
                      left: 4.w,
                      child: Opacity(
                        opacity: _starTwinkle3.value,
                        child: Transform.scale(
                          scale: 0.8 + (_starTwinkle3.value * 0.2),
                          child: CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.tertiary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 3.h,
                      right: 3.w,
                      child: Opacity(
                        opacity: _starTwinkle4.value,
                        child: Transform.scale(
                          scale: 0.8 + (_starTwinkle4.value * 0.2),
                          child: CustomIconWidget(
                            iconName: 'star',
                            color: theme.colorScheme.secondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 3.h),

        // Welcome text with subtle fade-in
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            "What's your name?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 1.h),

        // Subtitle with delayed fade-in
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Text(
            'Let\'s start your math adventure!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEye(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 4.w,
      height: _blinkAnimation.value * 2.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
