import 'package:flutter/material.dart';
import 'dart:math';

class CelebrationWidget extends StatelessWidget {
  final Animation<double> animation;

  const CelebrationWidget({Key? key, required this.animation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final random = Random();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3 * animation.value),
              ),
            ),
            ...List.generate(20, (index) {
              final startX = random.nextDouble();
              final startY = random.nextDouble() * 0.3;
              final endY = 1.0 + random.nextDouble() * 0.2;
              final rotation = random.nextDouble() * 4 * pi;

              return Positioned(
                left: MediaQuery.of(context).size.width * startX,
                top:
                    MediaQuery.of(context).size.height *
                    (startY + (endY - startY) * animation.value),
                child: Transform.rotate(
                  angle: rotation * animation.value,
                  child: Icon(
                    Icons.star,
                    color: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.primary,
                      const Color(0xFF27AE60),
                      const Color(0xFF9B59B6),
                    ][index % 4].withValues(alpha: 1 - animation.value),
                    size: 24 + random.nextDouble() * 16,
                  ),
                ),
              );
            }),
            Center(
              child: Transform.scale(
                scale: animation.value < 0.5
                    ? animation.value * 2
                    : 2 - animation.value * 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF27AE60),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Correct!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF27AE60),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+10 Points',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
