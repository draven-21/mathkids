import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Advanced animated mascot widget with multiple animation layers
class AnimatedMascotWidget extends StatefulWidget {
  const AnimatedMascotWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedMascotWidget> createState() => _AnimatedMascotWidgetState();
}

class _AnimatedMascotWidgetState extends State<AnimatedMascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late AnimationController _blinkController;
  late AnimationController _glowController;
  late AnimationController _starController;

  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _star1Animation;
  late Animation<double> _star2Animation;
  late Animation<double> _star3Animation;
  late Animation<double> _star4Animation;
  late Animation<double> _star5Animation;

  @override
  void initState() {
    super.initState();

    // Floating animation - smooth up and down
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Subtle rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Glow pulsing animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Star animations - orbital and scale
    _starController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    _star1Animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _starController,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _star2Animation = Tween<double>(begin: 0.4 * math.pi, end: 2.4 * math.pi)
        .animate(
          CurvedAnimation(
            parent: _starController,
            curve: const Interval(0.0, 1.0, curve: Curves.linear),
          ),
        );

    _star3Animation = Tween<double>(begin: 0.8 * math.pi, end: 2.8 * math.pi)
        .animate(
          CurvedAnimation(
            parent: _starController,
            curve: const Interval(0.0, 1.0, curve: Curves.linear),
          ),
        );

    _star4Animation = Tween<double>(begin: 1.2 * math.pi, end: 3.2 * math.pi)
        .animate(
          CurvedAnimation(
            parent: _starController,
            curve: const Interval(0.0, 1.0, curve: Curves.linear),
          ),
        );

    _star5Animation = Tween<double>(begin: 1.6 * math.pi, end: 3.6 * math.pi)
        .animate(
          CurvedAnimation(
            parent: _starController,
            curve: const Interval(0.0, 1.0, curve: Curves.linear),
          ),
        );

    // Start random blinking
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2000 + math.Random().nextInt(3000));
    Future.delayed(delay, () {
      if (mounted) {
        _performBlink();
      }
    });
  }

  void _performBlink() async {
    await _blinkController.forward();
    await _blinkController.reverse();
    if (mounted) {
      _scheduleNextBlink();
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _blinkController.dispose();
    _glowController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _rotateAnimation,
        _glowAnimation,
        _starController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: SizedBox(
              width: 60.w,
              height: 30.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow effect
                  Container(
                    width: 55.w,
                    height: 27.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(
                            alpha: _glowAnimation.value * 0.4,
                          ),
                          theme.colorScheme.primary.withValues(alpha: 0.0),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),

                  // Main mascot container with gradient
                  Container(
                    width: 45.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner highlight
                        Positioned(
                          top: 2.h,
                          left: 4.w,
                          child: Container(
                            width: 15.w,
                            height: 7.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        // Mascot face
                        AnimatedBuilder(
                          animation: _blinkAnimation,
                          builder: (context, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Happy eyes
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildEye(theme),
                                    SizedBox(width: 4.w),
                                    _buildEye(theme),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                // Happy smile
                                Container(
                                  width: 12.w,
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(100),
                                      bottomRight: Radius.circular(100),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Orbiting stars
                  _buildOrbitingStar(
                    theme,
                    _star1Animation.value,
                    25.w,
                    theme.colorScheme.secondary,
                    20.0,
                  ),
                  _buildOrbitingStar(
                    theme,
                    _star2Animation.value,
                    25.w,
                    theme.colorScheme.tertiary,
                    16.0,
                  ),
                  _buildOrbitingStar(
                    theme,
                    _star3Animation.value,
                    28.w,
                    theme.colorScheme.primary,
                    18.0,
                  ),
                  _buildOrbitingStar(
                    theme,
                    _star4Animation.value,
                    22.w,
                    Colors.amber,
                    14.0,
                  ),
                  _buildOrbitingStar(
                    theme,
                    _star5Animation.value,
                    26.w,
                    Colors.pinkAccent,
                    17.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEye(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 5.w,
      height: _blinkAnimation.value * 2.5.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
    );
  }

  Widget _buildOrbitingStar(
    ThemeData theme,
    double angle,
    double radius,
    Color color,
    double size,
  ) {
    final x = math.cos(angle) * radius;
    final y = math.sin(angle) * radius * 0.5; // Elliptical orbit

    // Calculate scale based on position (smaller when behind)
    final scale = 0.6 + (math.sin(angle) * 0.4 + 0.4);

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomIconWidget(iconName: 'star', color: color, size: size),
        ),
      ),
    );
  }
}
