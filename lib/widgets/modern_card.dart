import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Modern card widget with glassmorphism and neumorphism effects
class ModernCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableGlassmorphism;
  final bool enableNeumorphism;
  final double borderRadius;
  final Border? border;
  final Gradient? gradient;

  const ModernCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.margin,
    this.onTap,
    this.enableGlassmorphism = false,
    this.enableNeumorphism = false,
    this.borderRadius = 16.0,
    this.border,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBgColor = backgroundColor ?? theme.colorScheme.surface;

    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: enableGlassmorphism
            ? defaultBgColor.withOpacity(0.2)
            : defaultBgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            (enableGlassmorphism
                ? Border.all(
                    color: theme.colorScheme.surface.withOpacity(0.2),
                    width: 1.5,
                  )
                : null),
        boxShadow: _buildBoxShadow(theme, defaultBgColor),
      ),
      child: enableGlassmorphism
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  theme.colorScheme.surface.withOpacity(0.1),
                  BlendMode.lighten,
                ),
                child: child,
              ),
            )
          : child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    return Container(margin: margin, child: cardContent);
  }

  List<BoxShadow> _buildBoxShadow(ThemeData theme, Color bgColor) {
    if (enableNeumorphism) {
      // Neumorphism effect with soft shadows (theme-aware)
      final isDark = theme.brightness == Brightness.dark;
      return [
        BoxShadow(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.7),
          offset: const Offset(-6, -6),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.15),
          offset: const Offset(6, 6),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
    } else if (enableGlassmorphism) {
      // Glassmorphism with subtle glow
      return [
        BoxShadow(
          color: bgColor.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
      ];
    } else {
      // Standard modern shadow
      final shadowElevation = elevation ?? 4.0;
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: shadowElevation * 4,
          offset: Offset(0, shadowElevation),
          spreadRadius: 0,
        ),
      ];
    }
  }
}

/// Floating action card with color accent
class FloatingActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final String? badge;

  const FloatingActionCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      onTap: onTap,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      elevation: 6,
      child: Row(
        children: [
          // Icon container with color accent
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(3.5.w),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimary, size: 7.w),
          ),

          SizedBox(width: 4.w),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (badge != null) ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Arrow icon
          Icon(Icons.arrow_forward_ios, color: accentColor, size: 5.w),
        ],
      ),
    );
  }
}

/// Stat card with icon and value
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool compact;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      padding: EdgeInsets.all(compact ? 3.w : 4.w),
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with colored background
          Container(
            width: compact ? 10.w : 12.w,
            height: compact ? 10.w : 12.w,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(compact ? 2.5.w : 3.w),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimary,
              size: compact ? 5.w : 6.w,
            ),
          ),

          SizedBox(height: compact ? 1.h : 1.5.h),

          // Value
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              fontSize: compact ? 18.sp : 20.sp,
            ),
          ),

          SizedBox(height: 0.5.h),

          // Label
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 9.sp : 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
