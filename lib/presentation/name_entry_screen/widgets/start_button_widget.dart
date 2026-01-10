import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Enhanced start button with gradient, glow effects, and advanced animations
class StartButtonWidget extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const StartButtonWidget({
    Key? key,
    required this.isEnabled,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<StartButtonWidget> createState() => _StartButtonWidgetState();
}

class _StartButtonWidgetState extends State<StartButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late AnimationController _iconBounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _iconBounceAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Icon bounce animation
    _iconBounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _iconBounceAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _iconBounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _shimmerController.dispose();
    _iconBounceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = true);
      _pressController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _pressController.reverse();
      HapticFeedback.mediumImpact();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _shimmerAnimation,
        _iconBounceAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Stack(
              children: [
                // Main button container
                Container(
                  width: double.infinity,
                  height: 7.5.h,
                  decoration: BoxDecoration(
                    gradient: widget.isEnabled
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.secondary,
                              theme.colorScheme.secondary.withValues(
                                alpha: 0.8,
                              ),
                              theme.colorScheme.tertiary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                              theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.2,
                              ),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isEnabled
                          ? theme.colorScheme.surface
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.3,
                            ),
                      width: 3,
                    ),
                    boxShadow: widget.isEnabled && !_isPressed
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: theme.colorScheme.tertiary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : widget.isEnabled
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        // Shimmer overlay (only when enabled)
                        if (widget.isEnabled)
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(
                                _shimmerAnimation.value * 100.w,
                                0,
                              ),
                              child: Container(
                                width: 30.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Button content
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated rocket icon
                              Transform.translate(
                                offset: widget.isEnabled
                                    ? Offset(0, _iconBounceAnimation.value)
                                    : Offset.zero,
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: widget.isEnabled
                                        ? theme.colorScheme.surface.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'rocket_launch',
                                    color: widget.isEnabled
                                        ? theme.colorScheme.surface
                                        : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                    size: 32,
                                  ),
                                ),
                              ),

                              SizedBox(width: 3.w),

                              // Button text
                              Text(
                                'Start Learning!',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: widget.isEnabled
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  fontSize: 20.sp,
                                  shadows: widget.isEnabled
                                      ? [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Glow effect when enabled
                if (widget.isEnabled && !_isPressed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.secondary.withValues(alpha: 0.0),
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
