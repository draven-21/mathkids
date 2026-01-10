import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Glassmorphism card widget with blur effects and transparency
/// Provides a modern, frosted glass appearance
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderColor,
    this.borderWidth = 1.5,
    this.gradientColors,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default gradient colors based on theme
    final defaultGradientColors = isDark
        ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
        : [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.3)];

    final effectiveGradientColors = gradientColors ?? defaultGradientColors;
    final effectiveBorderColor =
        borderColor ??
        (isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.3));

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: effectiveGradientColors,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: effectiveBorderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: content,
        ),
      );
    }

    return Container(margin: margin, child: content);
  }
}

/// Frosted glass effect card with more pronounced blur
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tintColor;
  final VoidCallback? onTap;

  const FrostedGlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.tintColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveTintColor =
        tintColor ??
        (isDark ? theme.colorScheme.surface : theme.colorScheme.primary);

    return GlassCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      blur: 15.0,
      opacity: 0.15,
      borderColor: isDark
          ? Colors.white.withOpacity(0.15)
          : Colors.white.withOpacity(0.4),
      borderWidth: 2.0,
      gradientColors: isDark
          ? [
              effectiveTintColor.withOpacity(0.1),
              effectiveTintColor.withOpacity(0.05),
            ]
          : [
              effectiveTintColor.withOpacity(0.2),
              effectiveTintColor.withOpacity(0.1),
            ],
      onTap: onTap,
      child: child,
    );
  }
}

/// Animated glass card that responds to user interaction
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const AnimatedGlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassCard(
              padding: widget.padding,
              margin: widget.margin,
              borderRadius: widget.borderRadius,
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Glass header with gradient overlay
class GlassHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final List<Color>? gradientColors;

  const GlassHeader({
    Key? key,
    required this.child,
    this.height = 120.0,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultGradient = isDark
        ? [
            theme.colorScheme.primary.withOpacity(0.3),
            theme.colorScheme.primary.withOpacity(0.1),
          ]
        : [
            theme.colorScheme.primary.withOpacity(0.5),
            theme.colorScheme.primary.withOpacity(0.2),
          ];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors ?? defaultGradient,
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shimmer glass effect for loading states
class ShimmerGlassCard extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerGlassCard({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  State<ShimmerGlassCard> createState() => _ShimmerGlassCardState();
}

class _ShimmerGlassCardState extends State<ShimmerGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: widget.borderRadius,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.3),
                      ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
